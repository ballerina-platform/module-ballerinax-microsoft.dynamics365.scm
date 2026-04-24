#!/usr/bin/env python3
"""CSDL (EDMX) -> OpenAPI 3.0 converter for the D365 F&O Ballerina connectors.

One pass over the 50MB metadata.xml produces two OpenAPI specs:
  - finance.json  (bucket: finance + shared)
  - scm.json      (bucket: scm + shared)

Classification rule (documented in sanitations.md for both connectors):

  1. If the entity's name matches an EXCLUDED name-prefix (HR/Retail/EAM),
     drop it regardless of labels.
  2. Count label-file prefixes (`@Ledger`, `@Invent`, ...) across all the
     entity's property LabelId annotations. Ignore the generic `@SYS`.
     - Excluded-label hits >= other hits  -> EXCLUDED
     - Finance-label hits > 0 and SCM-label hits = 0  -> FINANCE
     - SCM-label hits > 0 and Finance-label hits = 0  -> SCM
     - Both Finance AND SCM hits present  -> SHARED (both connectors)
  3. No domain-specific labels at all -> name-prefix fallback.
  4. Unclassifiable entities default to SHARED so they reach both connectors.
"""

from __future__ import annotations

import json
import re
import sys
import time
from collections import Counter, defaultdict
from xml.etree import ElementTree as ET

EDMX_NS = "http://docs.oasis-open.org/odata/ns/edmx"
EDM_NS = "http://docs.oasis-open.org/odata/ns/edm"
DATA_NS = "Microsoft.Dynamics.DataEntities"

# --- Classification rules ---------------------------------------------------

FIN_LABELS = {
    "Ledger", "LedgerJournal", "TRX", "Tax", "TaxIntegration", "VAT",
    "Bank", "BankFoundation", "FixedAsset", "FixedAssets", "AssetLeasing",
    "AccountsReceivable", "AccountsPayable", "Expense", "ExpenseManagement",
    "Budget", "Budgeting", "Payment", "Invoice", "Voucher", "Currency",
    "ExchangeRate", "GLS", "SYP", "FiscalCalendar", "CreditAndCollections",
    "CreditManagement", "Consolidation", "AccountingDistribution",
    "CostAccounting", "CostAccountingService", "Collections", "Dunning",
    "Reimbursement", "PublicSector", "ProjectAccounting", "Project",
    "TaxDeclaration", "LedgerSettlement", "AccountStructure", "MainAccount",
    "GeneralLedger", "SubBill", "TrvExpense", "TRV",
}
SCM_LABELS = {
    "Invent", "Inventory", "InventoryManagement", "InventoryJournal",
    "Warehouse", "WarehouseOrders", "WAX", "WMS", "PRO", "Production",
    "ProductionControl", "Route", "BOM", "Transfer", "SCM", "MasterPlanning",
    "InboundTransportationManagement", "OutboundTransportation",
    "OutboundTransportationManagement", "LTM", "Kanban", "Quality",
    "QualityManagement", "QMS", "DemandForecasting", "ProductInformation",
    "ReleasedProductVariant", "CatchWeight", "Shipping", "LoadBuilding",
    "WaveAndWarehouseWork", "ItemArrival", "CycleCount", "ENG", "Engineering",
}
EXCLUDED_LABELS = {
    "HCM", "Payroll", "Benefit", "Benefits", "Talent", "Recruitment",
    "EmployeeSelfService", "EmployeeTraining", "HumanResources",
    "PersonnelCore", "PersonnelManagement", "Leave", "PerformanceManagement",
    "CaseManagement", "Retail", "RET", "REX", "RetailAssortment",
    "RetailCDX", "RetailFiscalIntegration", "RetailHeadquarters", "Commerce",
    "CommerceRuntime", "POS", "MCR", "GlobalUnifiedPricing",
    "RebatesAndDeductions", "EnterpriseAssetManagement",
    "EnterpriseAssetManagementAppSuite", "AssetMaintenance",
    "IoTIntelligenceCore", "CLMIntegration",
}

FIN_NAME_PREFIXES = (
    "Cust", "Vend", "Ledger", "GeneralLedger", "GeneralJournal",
    "MainAccount", "ChartOfAccounts", "FixedAsset", "AssetLease",
    "Bank", "Cash", "CreditCollections", "Dunning", "Tax", "VAT",
    "Invoice", "Payment", "Voucher", "ExchangeRate", "Currency",
    "AccountingDistribution", "Budget", "Expense", "Reimbursement",
    "Trial", "Posting", "JournalName", "JournalControl",
    "LedgerJournal", "LedgerTransSettlement", "FiscalCalendar",
    "AccountingCurrency", "Intercompany", "Financial",
    "Trv", "IndirectCost", "AggregatedCost", "CostCenter",
    "Project", "Proj", "AccrualScheme", "WithholdConcession",
)
SCM_NAME_PREFIXES = (
    "Invent", "Warehouse", "WHS", "WMS", "BOM", "BillOfMaterial",
    "Prod", "Production", "Route", "Transfer", "TransferOrder",
    "ItemGroup", "UnitOfMeasure", "UnitClass",
    "ProductDimension", "TrackingDimension", "StorageDimension",
    "QualityOrder", "Kanban", "EnterpriseAsset", "AssetManagement",
    "DemandForecast", "MasterPlan", "CatchWeight", "WaveLabel",
    "LoadTemplate", "ShipCarrier", "ShippingCarrier", "PurchRFQ",
    "Item", "Product", "ReleasedDistinctProduct", "ReleasedProduct",
)
SHARED_NAME_PREFIXES = (
    "LegalEntity", "Company", "SystemUser", "DirParty", "Party",
    "Address", "LogisticsPostalAddress", "LogisticsElectronicAddress",
    "Country", "CountryRegion", "LanguageCode", "OrganizationContactInfo",
    "OperatingUnit", "Department", "SalesOrder", "SalesLine",
    "SalesQuotation", "SalesInvoice", "SalesTable", "SalesShipment",
    "SalesConfirm", "PurchaseOrder", "PurchaseLine", "PurchaseInvoice",
    "PurchTable", "PurchLine", "CustomerGroup", "VendorGroup",
    "Customer", "Vendor",
)
EXCLUDED_NAME_PREFIXES = (
    "HR", "Hcm", "Worker", "Employee", "Payroll", "Benefit", "Leave",
    "Personnel", "Talent", "Recruit", "Applicant", "Education",
    "PersonCertificate", "Contractor", "TotalComp", "Retail", "POS",
    "Commerce", "Assortment", "AssetMaintenance", "AssetFault",
    "WorkOrder", "AssetObject", "SMAService", "SMA", "BusinessPartner",
    "BusinessPartnerOperation",
)

LABEL_RE = re.compile(r"@([A-Za-z]+)")


def classify_by_name(name: str, default: str = "unclassified") -> str:
    for p in EXCLUDED_NAME_PREFIXES:
        if name.startswith(p):
            return "excluded"
    for p in SHARED_NAME_PREFIXES:
        if name.startswith(p):
            return "shared"
    for p in FIN_NAME_PREFIXES:
        if name.startswith(p):
            return "finance"
    for p in SCM_NAME_PREFIXES:
        if name.startswith(p):
            return "scm"
    return default


def classify(name: str, label_counts: Counter) -> str:
    for p in EXCLUDED_NAME_PREFIXES:
        if name.startswith(p):
            return "excluded"

    fin_hits = sum(v for k, v in label_counts.items() if k in FIN_LABELS)
    scm_hits = sum(v for k, v in label_counts.items() if k in SCM_LABELS)
    excl_hits = sum(v for k, v in label_counts.items() if k in EXCLUDED_LABELS)

    if excl_hits > 0 and excl_hits >= fin_hits and excl_hits >= scm_hits:
        return "excluded"
    if fin_hits > 0 and scm_hits == 0:
        return "finance"
    if scm_hits > 0 and fin_hits == 0:
        return "scm"
    if fin_hits > 0 and scm_hits > 0:
        return "shared"

    result = classify_by_name(name)
    return "shared" if result == "unclassified" else result


# --- EDM type -> OpenAPI schema mapping ------------------------------------

EDM_TYPE_MAP = {
    "Edm.String": {"type": "string"},
    "Edm.Boolean": {"type": "boolean"},
    "Edm.Byte": {"type": "integer", "format": "int32"},
    "Edm.SByte": {"type": "integer", "format": "int32"},
    "Edm.Int16": {"type": "integer", "format": "int32"},
    "Edm.Int32": {"type": "integer", "format": "int32"},
    "Edm.Int64": {"type": "integer", "format": "int64"},
    "Edm.Single": {"type": "number", "format": "float"},
    "Edm.Double": {"type": "number", "format": "double"},
    "Edm.Decimal": {"type": "number", "format": "double"},
    "Edm.DateTimeOffset": {"type": "string", "format": "date-time"},
    "Edm.Date": {"type": "string", "format": "date"},
    "Edm.TimeOfDay": {"type": "string"},
    "Edm.Duration": {"type": "string"},
    "Edm.Guid": {"type": "string", "format": "uuid"},
    "Edm.Binary": {"type": "string", "format": "byte"},
    "Edm.Stream": {"type": "string", "format": "binary"},
    "Edm.Geography": {"type": "object"},
    "Edm.GeographyPoint": {"type": "object"},
}


def edm_to_schema(type_str: str, known_schemas: set[str]) -> dict:
    """Convert an EDM Type attribute to an OpenAPI schema fragment."""
    is_collection = False
    t = type_str
    if t.startswith("Collection(") and t.endswith(")"):
        is_collection = True
        t = t[len("Collection("):-1]

    if t in EDM_TYPE_MAP:
        inner = dict(EDM_TYPE_MAP[t])
    elif t.startswith(DATA_NS + "."):
        simple = t.rsplit(".", 1)[1]
        if simple in known_schemas:
            inner = {"$ref": f"#/components/schemas/{simple}"}
        else:
            # forward reference or not kept in this spec; treat as opaque
            inner = {"type": "string"}
    else:
        inner = {"type": "string"}

    if is_collection:
        return {"type": "array", "items": inner}
    return inner


# --- Reusable OpenAPI bits --------------------------------------------------

REUSABLE_PARAMETERS = {
    "select": {
        "name": "$select",
        "in": "query",
        "description": "OData `$select`: comma-separated list of properties to return.",
        "required": False,
        "schema": {"type": "string"},
        "x-ballerina-name": "selectFields",
    },
    "filter": {
        "name": "$filter",
        "in": "query",
        "description": "OData `$filter` expression.",
        "required": False,
        "schema": {"type": "string"},
        "x-ballerina-name": "filter",
    },
    "top": {
        "name": "$top",
        "in": "query",
        "description": "Maximum number of records to return.",
        "required": False,
        "schema": {"type": "integer", "format": "int32", "minimum": 0},
        "x-ballerina-name": "top",
    },
    "skip": {
        "name": "$skip",
        "in": "query",
        "description": "Number of records to skip.",
        "required": False,
        "schema": {"type": "integer", "format": "int32", "minimum": 0},
        "x-ballerina-name": "skip",
    },
    "orderBy": {
        "name": "$orderby",
        "in": "query",
        "description": "OData `$orderby` expression.",
        "required": False,
        "schema": {"type": "string"},
        "x-ballerina-name": "orderBy",
    },
    "expand": {
        "name": "$expand",
        "in": "query",
        "description": "OData `$expand`: comma-separated navigation properties.",
        "required": False,
        "schema": {"type": "string"},
        "x-ballerina-name": "expand",
    },
    "count": {
        "name": "$count",
        "in": "query",
        "description": "When true, the response includes `@odata.count`.",
        "required": False,
        "schema": {"type": "boolean"},
        "x-ballerina-name": "count",
    },
    "crossCompany": {
        "name": "cross-company",
        "in": "query",
        "description": "Query across legal entities instead of the caller's default.",
        "required": False,
        "schema": {"type": "boolean"},
        "x-ballerina-name": "crossCompany",
    },
    "ifMatch": {
        "name": "If-Match",
        "in": "header",
        "description": "Optimistic concurrency token (matches `@odata.etag`).",
        "required": False,
        "schema": {"type": "string"},
    },
}

ODATA_COLLECTION_SCHEMA = {
    "type": "object",
    "description": "Standard OData collection envelope.",
    "properties": {
        "@odata.context": {"type": "string"},
        "@odata.count": {"type": "integer", "format": "int64"},
        "@odata.nextLink": {"type": "string"},
    },
}

ODATA_ERROR_SCHEMA = {
    "type": "object",
    "description": "Standard OData error payload.",
    "properties": {
        "error": {
            "type": "object",
            "properties": {
                "code": {"type": "string"},
                "message": {"type": "string"},
                "target": {"type": "string"},
                "innererror": {"type": "object", "additionalProperties": True},
            },
        }
    },
}

SECURITY_SCHEMES = {
    "oAuth2": {
        "type": "oauth2",
        "description": "Azure AD OAuth 2.0 client-credentials flow.",
        "flows": {
            "clientCredentials": {
                "tokenUrl": "https://login.microsoftonline.com/common/oauth2/v2.0/token",
                "scopes": {
                    "https://erp.dynamics.com/.default": "Access Dynamics 365 Finance and Operations on behalf of the application"
                },
            }
        },
    },
    "bearerAuth": {
        "type": "http",
        "scheme": "bearer",
        "bearerFormat": "JWT",
        "description": "A pre-acquired Azure AD access token passed as `Authorization: Bearer <token>`.",
    },
}


# --- Parser -----------------------------------------------------------------

def parse_edmx(path: str) -> dict:
    """Parse the CSDL and return a dict with entities/enums/entity-sets."""
    t0 = time.time()
    sys.stderr.write(f"Parsing {path} ...\n")
    tree = ET.parse(path)
    root = tree.getroot()
    schema = root.find(f"./{{{EDMX_NS}}}DataServices/{{{EDM_NS}}}Schema")
    if schema is None:
        raise SystemExit("No Schema found in EDMX")

    entity_types: dict[str, dict] = {}
    for et in schema.findall(f"{{{EDM_NS}}}EntityType"):
        name = et.get("Name")
        entry = {
            "baseType": et.get("BaseType"),
            "abstract": et.get("Abstract") == "true",
            "keys": [k.get("Name") for k in et.findall(f"{{{EDM_NS}}}Key/{{{EDM_NS}}}PropertyRef")],
            "properties": [],
            "navigationProperties": [],
            "labelCounts": Counter(),
        }
        for prop in et.findall(f"{{{EDM_NS}}}Property"):
            entry["properties"].append({
                "name": prop.get("Name"),
                "type": prop.get("Type"),
                "nullable": prop.get("Nullable", "true").lower() != "false",
                "maxLength": prop.get("MaxLength"),
                "precision": prop.get("Precision"),
                "scale": prop.get("Scale"),
            })
            for ann in prop.findall(f"{{{EDM_NS}}}Annotation"):
                if ann.get("Term") == "Microsoft.Dynamics.OData.Core.V1.LabelId":
                    m = LABEL_RE.match(ann.get("String", ""))
                    if m:
                        entry["labelCounts"][m.group(1)] += 1
        for nav in et.findall(f"{{{EDM_NS}}}NavigationProperty"):
            entry["navigationProperties"].append({
                "name": nav.get("Name"),
                "type": nav.get("Type"),
                "nullable": nav.get("Nullable", "true").lower() != "false",
            })
        entity_types[name] = entry

    enum_types: dict[str, list[str]] = {}
    for et in schema.findall(f"{{{EDM_NS}}}EnumType"):
        members = [m.get("Name") for m in et.findall(f"{{{EDM_NS}}}Member")]
        enum_types[et.get("Name")] = members

    entity_sets: dict[str, str] = {}
    container = schema.find(f"{{{EDM_NS}}}EntityContainer")
    if container is not None:
        for es in container.findall(f"{{{EDM_NS}}}EntitySet"):
            et_ref = es.get("EntityType", "")
            entity_sets[es.get("Name")] = et_ref.rsplit(".", 1)[-1]

    sys.stderr.write(
        f"  {len(entity_types)} EntityTypes, "
        f"{len(entity_sets)} EntitySets, "
        f"{len(enum_types)} EnumTypes, "
        f"parsed in {time.time() - t0:.1f}s\n"
    )
    return {
        "entityTypes": entity_types,
        "entitySets": entity_sets,
        "enumTypes": enum_types,
    }


def resolve_inherited(name: str, entity_types: dict) -> list[dict]:
    """Walk BaseType chain and collect all properties + keys."""
    chain: list[str] = []
    cur: str | None = name
    while cur:
        chain.append(cur)
        et = entity_types.get(cur)
        if et is None or not et["baseType"]:
            break
        cur = et["baseType"].rsplit(".", 1)[-1]
    return list(reversed(chain))  # root first


def keys_for(name: str, entity_types: dict) -> list[str]:
    for n in reversed(resolve_inherited(name, entity_types)):
        et = entity_types.get(n)
        if et and et["keys"]:
            return et["keys"]
    return []


def key_type_for(entity: str, key_name: str, entity_types: dict) -> str:
    for n in resolve_inherited(entity, entity_types):
        et = entity_types.get(n)
        if et is None:
            continue
        for p in et["properties"]:
            if p["name"] == key_name:
                return p["type"]
    return "Edm.String"


# --- Spec builder -----------------------------------------------------------

def first_snake(name: str) -> str:
    """Lower the first letter: CustomerV3 -> customerV3."""
    if not name:
        return name
    return name[0].lower() + name[1:]


def build_schema(entity_name: str, parsed: dict, known_schemas: set[str]) -> dict:
    """Build the OpenAPI schema for one entity type, using allOf for inheritance."""
    et = parsed["entityTypes"][entity_name]
    props_obj: dict[str, dict] = {"@odata.etag": {"type": "string"}}
    for p in et["properties"]:
        s = edm_to_schema(p["type"], known_schemas)
        if p["maxLength"] and p["maxLength"].isdigit():
            s["maxLength"] = int(p["maxLength"])
        props_obj[p["name"]] = s

    own = {"type": "object", "properties": props_obj}

    if et["baseType"]:
        base_simple = et["baseType"].rsplit(".", 1)[-1]
        if base_simple in known_schemas:
            return {"allOf": [
                {"$ref": f"#/components/schemas/{base_simple}"},
                own,
            ]}
    return own


def camel_case(name: str) -> str:
    """Lower the first char: VoucherType -> voucherType, so path params can't
    shadow PascalCase type names in the generated Ballerina client."""
    return name[:1].lower() + name[1:] if name else name


def path_parameter(name: str, edm_type: str) -> dict:
    schema = edm_to_schema(edm_type, set())
    schema = schema.get("items") if schema.get("type") == "array" else schema
    return {
        "name": name,
        "in": "path",
        "required": True,
        "schema": schema if schema else {"type": "string"},
    }


def composite_key_path(entity_set: str, keys: list[str], key_types: list[str]) -> tuple[str, list[dict]]:
    """Emit `EntitySet(keyA='{keyA}',keyB='{keyB}')` plus matching path params.
    The URL keeps the PascalCase OData key name; the path-param name is
    camelCase so it can't shadow entity-type names in the generated client."""
    if not keys:
        return "", []

    parts = []
    params = []
    for k, t in zip(keys, key_types):
        param_name = camel_case(k)
        qualifier = "'" if (t == "Edm.String" or not t.startswith("Edm.")) else ""
        parts.append(f"{k}={qualifier}{{{param_name}}}{qualifier}")
        params.append(path_parameter(param_name, t))
    return f"/{entity_set}(" + ",".join(parts) + ")", params


VARIANT_SUBSTRINGS = (
    "BiEntit", "CDREntit", "CDSEntit", "ForAI", "DualWrite", "Hash",
)

# Must-include entity set names per connector. These land in the spec no
# matter where they fall in the length ranking.
FIN_PRIORITY: tuple[str, ...] = (
    "CustomersV3", "CustomersV2", "CustomerGroups", "CustomerParameters",
    "CustomerPaymentMethods", "CustomerPaymentTerms", "CustomerPostalAddressesV2",
    "CustomerPaymentJournalHeaders", "CustomerPaymentJournalLines",
    "CustomerPostingProfiles", "CustomerElectronicAddresses",
    "VendorsV3", "VendorsV2", "VendorGroups", "VendorParameters",
    "VendorPaymentMethods", "VendorPaymentTerms",
    "VendorPaymentJournalHeaders", "VendorPaymentJournalLines",
    "VendorPostingProfiles", "VendorInvoiceDeclarations",
    "MainAccounts", "MainAccountLegalEntities", "Ledgers",
    "LedgerAccountGroups", "LedgerJournalHeaders", "LedgerJournalLines",
    "LedgerJournalDescriptions", "LedgerJournalCostLinesPurchTables",
    "LedgerTransSettlements", "LedgerTransSettlementsV2", "LedgerIntervals",
    "FinancialDimensionValues", "FinancialDimensionSets",
    "DimensionAttributes", "DimensionParameters", "DimensionRules",
    "FiscalCalendars", "PostingDefinitions", "PostingJournals",
    "FixedAssetsV2", "FixedAssetValueModels",
    "BankGroups", "BankAccounts",
    "PaymentTerms", "PaymentMethods", "PaymentSchedules",
    "PaymentCalendarRules", "PaymentInstructions",
    "Currencies", "ExchangeRates", "ExchangeRatesNonISO",
    "TaxPostingGroups", "TaxTables",
    "BudgetPlanProcesses", "ExpenseParameters",
)

SCM_PRIORITY: tuple[str, ...] = (
    "ReleasedProductsV2", "Warehouses", "WarehouseLocations",
    "WarehousesOnHand", "WarehousesOnHandV2",
    "WarehouseInventoryStatusesOnHand", "WarehouseInventoryStatusesOnHandV2",
    "WarehouseInventoryOwners",
    "WarehouseWorkHeaders", "WarehouseWorkPolicies", "WarehouseZones",
    "WarehouseZoneGroups",
    "BillOfMaterialsHeaders", "BillOfMaterialsLines",
    "BillOfMaterialsVersions", "BillOfMaterialsVersionsV2",
    "BillOfMaterialsVersionsV3", "BillOfMaterialsVersionsV4",
    "BillOfMaterialsLinesV2",
    "ProductionOrderHeaders", "ProductionOrderRouteOperations",
    "TransferOrderHeaders", "TransferOrderLines",
    "TransferOrderLandedCostGroups", "TransferOrderLineAutoCostHeaders",
    "InventoryMovementJournalHeaders", "InventoryTagCountingJournalHeaders",
    "InventoryTransferJournalHeaders", "InventoryCountingReasonCodes",
    "InventoryCountingReasonCodesV2", "InventoryOwners", "InventoryPolicies",
    "InventoryProjectConsumptionJournalNames",
    "PurchaseOrderHeadersV2", "PurchaseOrderLines", "PurchaseOrderLinesV2",
    "PurchaseOrderResponseLines", "PurchaseOrderAutoCostHeaders",
    "SalesOrderHeaders", "SalesOrderHeadersV2", "SalesOrderLines",
    "SalesOrderHoldCodes",
    "UnitsOfMeasure", "RouteOperations",
)
COUNTRY_SUFFIX_RE = re.compile(
    r"("
    r"RU|BR|IN|MX|CN|DE|FR|JP|NL|IT|PL|ES|TH|MY|AE|CZ|HU|EE|LT|LV|"
    r"BE|CH|AT|SE|NO|FI|DK|SA|KR|HK|MA|LB|EG|GR|IS|TR|UK|US|CA|AU"
    r")$"
)


def is_variant(name: str) -> bool:
    """Specialized BI/CDR/CDS/DualWrite/country-localized variant → skip."""
    if any(sub in name for sub in VARIANT_SUBSTRINGS):
        return True
    # Country-localized entities: suffix is a 2-letter country code.
    # Only trip if the name has significant non-country content (len > 4).
    if len(name) > 4 and COUNTRY_SUFFIX_RE.search(name):
        return True
    return False


def priority_key(name: str) -> tuple:
    """Sort key: primary entities first, shorter names first, alphabetical tiebreak."""
    return (is_variant(name), len(name), name)


def build_spec(
    title: str,
    description: str,
    primary_bucket: str,
    classifications: dict[str, str],
    parsed: dict,
    max_entity_sets: int,
) -> dict:
    entity_types = parsed["entityTypes"]
    entity_sets = parsed["entitySets"]
    enum_types = parsed["enumTypes"]

    priority_list = FIN_PRIORITY if primary_bucket == "finance" else SCM_PRIORITY

    # Candidates: "primary" (finance or scm) + "shared" buckets, minus variants.
    candidates: dict[str, str] = {}  # es_name -> et_name
    for es_name, et_name in entity_sets.items():
        if is_variant(es_name):
            continue
        bucket = classifications.get(et_name, "unclassified")
        if bucket == primary_bucket or bucket == "shared":
            candidates[es_name] = et_name

    # Tier 1: priority hard-list (only those that actually exist)
    kept_sets: list[tuple[str, str]] = []
    taken: set[str] = set()
    for name in priority_list:
        if name in candidates:
            kept_sets.append((name, candidates[name]))
            taken.add(name)

    # Tier 2: fill to max_entity_sets, ranked by (is_variant, len, alpha).
    remaining = [(es, et) for es, et in candidates.items() if es not in taken]
    remaining.sort(key=lambda x: priority_key(x[0]))
    for es_name, et_name in remaining:
        if len(kept_sets) >= max_entity_sets:
            break
        kept_sets.append((es_name, et_name))

    kept_sets.sort()  # final alphabetical ordering for deterministic output

    kept_types: set[str] = {et for _, et in kept_sets}

    # Enums used by kept types
    used_enums: set[str] = set()
    for t in kept_types:
        et = entity_types.get(t)
        if et is None:
            continue
        for p in et["properties"]:
            ref = p["type"]
            if ref.startswith("Collection("):
                ref = ref[len("Collection("):-1]
            if ref.startswith(DATA_NS + "."):
                simple = ref.rsplit(".", 1)[-1]
                if simple in enum_types:
                    used_enums.add(simple)

    # Build schemas map
    known_schemas = kept_types | used_enums | {"ODataCollection", "ODataError"}
    schemas: dict[str, dict] = {
        "ODataCollection": ODATA_COLLECTION_SCHEMA,
        "ODataError": ODATA_ERROR_SCHEMA,
    }

    # Entity-type schemas (including transitive base types even if they
    # belong to other buckets, for inheritance resolution).
    def emit_type(name: str) -> None:
        if name in schemas:
            return
        if name not in entity_types:
            return
        # Emit base first
        base = entity_types[name].get("baseType")
        if base:
            emit_type(base.rsplit(".", 1)[-1])
        schemas[name] = build_schema(name, parsed, known_schemas)
        known_schemas.add(name)

    for t in kept_types:
        emit_type(t)

    # Enum schemas
    for name in used_enums:
        schemas[name] = {"type": "string", "enum": list(enum_types[name])}

    # Collection envelope schemas, one per kept entity-set
    for es, t in kept_sets:
        if t not in entity_types:
            continue
        cname = f"{es}Collection"
        schemas[cname] = {
            "allOf": [
                {"$ref": "#/components/schemas/ODataCollection"},
                {
                    "type": "object",
                    "properties": {
                        "value": {
                            "type": "array",
                            "items": {"$ref": f"#/components/schemas/{t}"},
                        }
                    },
                },
            ]
        }

    # Paths
    paths: dict[str, dict] = {}
    for es, t in kept_sets:
        coll_schema_ref = f"#/components/schemas/{es}Collection"
        entity_schema_ref = f"#/components/schemas/{t}"

        op_suffix = es  # reuse the entity-set name as the operation suffix

        # Collection path: GET list, POST create
        collection_item = {
            "get": {
                "tags": [es],
                "summary": f"List {es}",
                "operationId": f"list{op_suffix}",
                "parameters": [
                    {"$ref": "#/components/parameters/select"},
                    {"$ref": "#/components/parameters/filter"},
                    {"$ref": "#/components/parameters/top"},
                    {"$ref": "#/components/parameters/skip"},
                    {"$ref": "#/components/parameters/orderBy"},
                    {"$ref": "#/components/parameters/expand"},
                    {"$ref": "#/components/parameters/count"},
                    {"$ref": "#/components/parameters/crossCompany"},
                ],
                "responses": {
                    "200": {
                        "description": f"Collection of {t}",
                        "content": {
                            "application/json": {"schema": {"$ref": coll_schema_ref}}
                        },
                    },
                    "default": {"$ref": "#/components/responses/ODataError"},
                },
            },
            "post": {
                "tags": [es],
                "summary": f"Create {t}",
                "operationId": f"create{op_suffix}",
                "requestBody": {
                    "required": True,
                    "content": {
                        "application/json": {"schema": {"$ref": entity_schema_ref}}
                    },
                },
                "responses": {
                    "201": {
                        "description": f"{t} created",
                        "content": {
                            "application/json": {"schema": {"$ref": entity_schema_ref}}
                        },
                    },
                    "default": {"$ref": "#/components/responses/ODataError"},
                },
            },
        }
        paths[f"/{es}"] = collection_item

        # Entity-by-key path: GET, PATCH, DELETE
        keys = keys_for(t, entity_types)
        if keys:
            key_types = [key_type_for(t, k, entity_types) for k in keys]
            path_str, path_params = composite_key_path(es, keys, key_types)
            paths[path_str] = {
                "parameters": path_params,
                "get": {
                    "tags": [es],
                    "summary": f"Get {t} by key",
                    "operationId": f"get{op_suffix}",
                    "parameters": [
                        {"$ref": "#/components/parameters/select"},
                        {"$ref": "#/components/parameters/expand"},
                    ],
                    "responses": {
                        "200": {
                            "description": f"{t} record",
                            "content": {
                                "application/json": {"schema": {"$ref": entity_schema_ref}}
                            },
                        },
                        "default": {"$ref": "#/components/responses/ODataError"},
                    },
                },
                "patch": {
                    "tags": [es],
                    "summary": f"Update {t}",
                    "operationId": f"update{op_suffix}",
                    "parameters": [{"$ref": "#/components/parameters/ifMatch"}],
                    "requestBody": {
                        "required": True,
                        "content": {
                            "application/json": {"schema": {"$ref": entity_schema_ref}}
                        },
                    },
                    "responses": {
                        "200": {
                            "description": f"{t} updated",
                            "content": {
                                "application/json": {"schema": {"$ref": entity_schema_ref}}
                            },
                        },
                        "default": {"$ref": "#/components/responses/ODataError"},
                    },
                },
                "delete": {
                    "tags": [es],
                    "summary": f"Delete {t}",
                    "operationId": f"delete{op_suffix}",
                    "parameters": [{"$ref": "#/components/parameters/ifMatch"}],
                    "responses": {
                        "204": {"description": f"{t} deleted"},
                        "default": {"$ref": "#/components/responses/ODataError"},
                    },
                },
            }

    spec = {
        "openapi": "3.0.3",
        "info": {
            "title": title,
            "version": "1.0.0",
            "description": description,
            "license": {
                "name": "Apache-2.0",
                "url": "https://www.apache.org/licenses/LICENSE-2.0",
            },
            "contact": {"name": "Ballerina", "url": "https://ballerina.io"},
        },
        "servers": [
            {
                "url": "https://{tenant}.operations.dynamics.com/data",
                "description": "Dynamics 365 tenant",
                "variables": {
                    "tenant": {
                        "default": "your-org",
                        "description": "Tenant-specific subdomain",
                    }
                },
            }
        ],
        "security": [{"oAuth2": []}, {"bearerAuth": []}],
        "paths": paths,
        "components": {
            "securitySchemes": SECURITY_SCHEMES,
            "parameters": REUSABLE_PARAMETERS,
            "responses": {
                "ODataError": {
                    "description": "OData error response",
                    "content": {
                        "application/json": {
                            "schema": {"$ref": "#/components/schemas/ODataError"}
                        }
                    },
                }
            },
            "schemas": schemas,
        },
    }
    return spec


# --- Main -------------------------------------------------------------------

def main() -> None:
    if len(sys.argv) < 5:
        print(
            "usage: edmx2oas.py <metadata.xml> <finance-out.json> <scm-out.json> <max-entities>",
            file=sys.stderr,
        )
        sys.exit(2)

    edmx_path = sys.argv[1]
    fin_out = sys.argv[2]
    scm_out = sys.argv[3]
    max_entities = int(sys.argv[4])
    parsed = parse_edmx(edmx_path)

    classifications: dict[str, str] = {}
    for name, et in parsed["entityTypes"].items():
        classifications[name] = classify(name, et["labelCounts"])

    counts: Counter = Counter(classifications.values())
    sys.stderr.write("Classification counts:\n")
    for k in ("finance", "scm", "shared", "excluded"):
        sys.stderr.write(f"  {k:10s} {counts[k]:6d}\n")

    fin_spec = build_spec(
        "Microsoft Dynamics 365 Finance and Operations",
        "Ballerina connector exposing the Finance surface of the Microsoft "
        "Dynamics 365 Finance and Operations OData REST API, generated from "
        "the live tenant CSDL metadata.",
        "finance",
        classifications,
        parsed,
        max_entities,
    )
    sys.stderr.write(f"Finance: {len(fin_spec['paths'])} paths, "
                      f"{len(fin_spec['components']['schemas'])} schemas\n")
    with open(fin_out, "w") as f:
        json.dump(fin_spec, f, separators=(",", ":"))
    sys.stderr.write(f"Wrote {fin_out}\n")

    scm_spec = build_spec(
        "Microsoft Dynamics 365 Supply Chain Management",
        "Ballerina connector exposing the Supply Chain surface of the Microsoft "
        "Dynamics 365 Finance and Operations OData REST API, generated from "
        "the live tenant CSDL metadata.",
        "scm",
        classifications,
        parsed,
        max_entities,
    )
    sys.stderr.write(f"SCM: {len(scm_spec['paths'])} paths, "
                      f"{len(scm_spec['components']['schemas'])} schemas\n")
    with open(scm_out, "w") as f:
        json.dump(scm_spec, f, separators=(",", ":"))
    sys.stderr.write(f"Wrote {scm_out}\n")


if __name__ == "__main__":
    main()

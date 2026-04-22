_Author_: Ballerina \
_Created_: 2026-04-21 \
_Edition_: Swan Lake

# OpenAPI specification — reconstruction notes

Microsoft does not publish an OpenAPI document for the Dynamics 365 Supply Chain Management OData REST API; the schema is expressed as a CSDL metadata document at `/$metadata`. Because we did not have access to a metadata dump for this connector, the spec under `openapi.json` was **reconstructed by hand** to match the shape of the real API closely enough to demonstrate the connector end-to-end against a Ballerina mock server.

This document records what was reconstructed, the deliberate trade-offs, and the parameter-name sanitations applied for Ballerina codegen.

## Scope

The spec intentionally covers **20 operations** — enough to showcase the breadth of the Supply Chain Management surface while keeping the generated Ballerina client compact for demo purposes. Entities that overlap with the sibling `ballerinax/microsoft.dynamics365.finance` connector (customers, vendors, released products, sales/purchase order headers, GL entries) are **deliberately excluded** from this spec to keep the two connectors complementary.

| Entity set | Operations |
|---|---|
| `Warehouses` | list, get, create, update |
| `WarehouseLocations` | list |
| `Sites` | list |
| `ItemGroups` | list |
| `UnitsOfMeasure` | list |
| `BillsOfMaterials` | list, get, create |
| `BillOfMaterialLines` | list |
| `ProductionOrderHeaders` | list, get, create |
| `TransferOrderHeaders` | list, get |
| `InventoryOnHand` | list |
| `InventoryJournalHeaders` | list |
| `SalesShipmentHeaders` | list |

Everything else offered by a full D365 SCM tenant (hundreds of additional entity sets — routes, resources, WMS work, load planning, demand forecast, quality orders, master planning, data-management batch APIs, bound actions, etc.) is out of scope.

## Shape choices that mirror the real API

1. **Entity set names and paths.** Resource paths use Microsoft's published data-entity names (`Warehouses`, `WarehouseLocations`, `Sites`, `ItemGroups`, `UnitsOfMeasure`, `BillsOfMaterials`, `BillOfMaterialLines`, `ProductionOrderHeaders`, `TransferOrderHeaders`, `InventoryOnHand`, `InventoryJournalHeaders`, `SalesShipmentHeaders`).
2. **Composite keys in the URL.** Single-record endpoints use the OData literal-key syntax, e.g. `/Warehouses(dataAreaId='{dataAreaId}',WarehouseId='{warehouseId}')`. Keys are PascalCase in the URL and mapped to camelCase path parameters via the OpenAPI parameter name.
3. **Field casing.** Property names inside each entity use D365 F&O's PascalCase (`WarehouseId`, `ItemNumber`, `ProductionOrderNumber`, `TransferOrderNumber`, `BillOfMaterialsId`). The only camelCase field is `dataAreaId`, which is how the service actually returns it.
4. **OData collection envelope.** Every list response inherits from `ODataCollection` — `@odata.context`, `@odata.count` (returned when `$count=true`), and `@odata.nextLink` (for server-driven paging) — with a `value` array of the entity.
5. **ETag concurrency.** Every entity schema carries `@odata.etag`, and PATCH operations accept `If-Match`.
6. **OData error payload.** Errors use the standard `{ "error": { "code", "message", "target", "innererror" } }` envelope as the `default` response on every operation.
7. **Cross-company queries.** List endpoints expose the `cross-company` boolean; omitting it returns only the caller's default company. The sole exception is `/UnitsOfMeasure`: units of measure in D365 F&O are system-wide reference data, not scoped to a legal entity (the `UnitOfMeasure` schema intentionally has no `dataAreaId` field), so `cross-company` would be meaningless there and is omitted.
8. **Azure AD OAuth 2.0.** The security scheme is a client-credentials flow against `login.microsoftonline.com` with the `https://erp.dynamics.com/.default` scope, which is what a real Azure AD-protected D365 endpoint requires. The tenant URL shape matches the Finance connector — Finance and SCM share the same tenant in D365 F&O.

## Parameter-name sanitations

Several OData query options contain characters that are not valid Ballerina identifiers, and some collide with reserved words. Each reusable parameter in `components.parameters` carries an `x-ballerina-name` extension so the Ballerina OpenAPI tool emits clean field names on the generated `*Queries` records:

| OData / HTTP name | `x-ballerina-name` | Reason |
|---|---|---|
| `$select` | `selectFields` | `$` is invalid; `select` collides with the Ballerina reserved word |
| `$filter` | `filter` | `$` is invalid |
| `$top` | `top` | `$` is invalid |
| `$skip` | `skip` | `$` is invalid |
| `$orderby` | `orderBy` | `$` is invalid; camelCase is idiomatic |
| `$expand` | `expand` | `$` is invalid |
| `$count` | `count` | `$` is invalid |
| `cross-company` | `crossCompany` | Hyphens are invalid |

Path parameters bound to composite keys (e.g. `dataAreaId`, `warehouseId`, `billOfMaterialsId`, `productionOrderNumber`, `transferOrderNumber`) are defined in camelCase so the generated Ballerina function signatures read naturally even though the URL segments preserve the PascalCase property names the service expects.

## Known departures from a real metadata dump

The reconstruction is a demo-grade approximation, not a faithful transliteration of the CSDL:

- **Entity fields are a curated subset.** Each entity includes the 8–15 properties most useful for a demo. A real data entity typically has 40–150 fields and nested inventory-dimension structures; those are not modelled.
- **Inventory dimensions are flattened.** Real on-hand queries return nested `InventoryDimensions` / `StorageDimensions` / `TrackingDimensions` sub-structures. `InventoryOnHand` here flattens the most common dimensions (site, warehouse, location, batch, serial) into top-level fields.
- **Navigation properties / `$expand`.** `$expand` is exposed as a free-form string because we do not model the entity graph. No individual navigation properties are declared as schemas. In particular, the BOM header→lines relationship is represented as two independent entity sets rather than a parent-with-children graph.
- **Enums are loose.** Several properties that are true OData enums on the server (`ProductionStatus`, `TransferStatus`, `WarehouseTypeId`, `JournalType`) are declared as `string` with documented possible values, to avoid hard-coding enum sets that may diverge from the live API.
- **`$count` path endpoints are omitted.** Real D365 exposes `/Warehouses/$count` style endpoints that return a raw integer. These were dropped to stay within the 20-operation budget; the `$count=true` query option on list endpoints covers the same use case for the demo.
- **No data-management (batch / package) APIs.** DIXF endpoints such as `/data/DataManagementDefinitionGroups` are not in scope.
- **No bound actions.** Workflow transitions such as posting an inventory journal or updating a transfer order status are not modelled — only the direct OData CRUD on data entities is.
- **Field types are best-effort.** Quantity fields are `number/double` (the CSDL uses `Edm.Decimal` with an explicit scale). Yes/No fields are modelled as enums rather than the service's `Edm.Enum` type.

When a live metadata dump becomes available, regenerate the spec from CSDL and replace this file — do not try to reconcile by hand.

## Regeneration command

From the repository root:

```bash
bal openapi -i docs/spec/openapi.json --mode client --client-methods remote -o ballerina
```

## Overview

Microsoft Dynamics 365 Supply Chain Management is Microsoft's cloud enterprise-resource-planning application for end-to-end supply chain operations, covering warehousing, inventory, manufacturing, planning, transportation, and procurement. The Dynamics 365 Supply Chain Management connector enables integration with the Supply Chain OData REST API, providing programmatic access to master and transactional data including warehouses and locations, sites, item groups, units of measure, bills of materials, production orders, transfer orders, on-hand inventory, inventory journals, and sales shipments.

### Key Features

- Warehouse, location, and site master-data management
- Bill-of-materials (BOM) header and line access for manufacturing integration
- Production order and transfer order workflows
- Real-time on-hand inventory lookups by item, site, warehouse, location, batch, and serial
- Inventory journal and sales shipment (packing slip) visibility
- Cross-company queries spanning multiple legal entities (`dataAreaId`)
- OAuth 2.0 client-credentials and bearer-token authentication against Microsoft Entra ID (Azure AD)

## Setup

Dynamics 365 Supply Chain Management is protected by Azure Active Directory. Acquire an access token via the client-credentials flow (or pass one in directly via a bearer-token config) and point the client at your tenant's `/data` endpoint.

## Quickstart

```ballerina
import ballerinax/microsoft.dynamics365.scm;

public function main() returns error? {
    scm:Client scmClient = check new (
        config = {
            auth: {
                tokenUrl: "https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/token",
                clientId: "<client-id>",
                clientSecret: "<client-secret>",
                scopes: ["https://<tenant>.operations.dynamics.com/.default"]
            }
        },
        serviceUrl = "https://<tenant>.operations.dynamics.com/data"
    );

    scm:WarehousesCollection warehouses = check scmClient->listWarehouses(queries = {top: 5});
    // ...
}
```

## Examples

Runnable examples live in [`examples/`](../examples) at the repository root. They use the bundled mock server so they can run without a live tenant.

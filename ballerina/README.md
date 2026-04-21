## Overview

The `ballerinax/microsoft.dynamics365.scm` connector wraps a curated subset of the Microsoft Dynamics 365 Supply Chain Management OData REST API: warehouses, warehouse locations, sites, item groups, units of measure, bills of materials, production orders, transfer orders, inventory on-hand, inventory journals, and sales shipments. It is generated from the OpenAPI spec in `docs/spec/openapi.json`.

Entities that overlap with the sibling `ballerinax/microsoft.dynamics365.finance` connector (customers, vendors, released products, sales/purchase order headers, GL entries) are intentionally not duplicated here.

The repository also ships an in-process mock server (`modules/mock.server`) useful for tests and UI demos without a live D365 tenant.

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

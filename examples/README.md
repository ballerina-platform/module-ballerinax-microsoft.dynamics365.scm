# Examples

Self-contained Ballerina programs that exercise the `ballerinax/microsoft.dynamics365.scm` connector against an in-process mock server. Each example starts the mock on port 9091, points the client at it, runs a flow, prints the result, and shuts the mock down.

No real D365 tenant is required to run these.

## Setup (once)

From the repository root, build and publish the connector (and its `mock.server` sub-module) to your local Ballerina repository:

```bash
cd ballerina
bal pack
bal push --repository=local
cd ..
```

The examples declare `repository = "local"` on their dependency, so they will pick the just-published package up.

## Run

```bash
cd examples/list-warehouses
bal run
```

Swap the directory for any of the three examples:

| Example | What it demonstrates |
| --- | --- |
| `list-warehouses` | Default-company scoping, cross-company override, `$filter` on enum-like fields |
| `create-bill-of-materials` | Look up an existing BOM template, list its lines, then POST a new BOM header |
| `check-inventory-on-hand` | `$filter` by `ItemNumber`, `$orderby desc`, cross-company aggregation, summing quantity across locations |

## Pointing at a real tenant

Each example constructs the client with:

```ballerina
scm:Client fo = check new (
    config = {auth: {token: "demo-bearer-token"}},
    serviceUrl = "http://localhost:9091/data"
);
```

To hit a real tenant, drop the `server:startMock()` / `mockListener.gracefulStop()` calls and swap the client config for a live one:

```ballerina
scm:Client fo = check new (
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
```

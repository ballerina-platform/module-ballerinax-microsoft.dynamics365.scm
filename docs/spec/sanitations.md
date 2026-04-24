_Author_: Ballerina \
_Edition_: Swan Lake

# OpenAPI specification — derivation notes

`docs/spec/openapi.json` is **generated from a real Dynamics 365 Finance and Operations CSDL (EDMX) metadata dump**. The source CSDL itself is not in the repo — it is customer-derived data. The generator is a maintenance tool held outside the repository; contact the maintainers if you need to regenerate from a fresh metadata dump.

## What the spec contains

- **~300 entity sets** from the D365 F&O Supply Chain domain, each with `list` / `get-by-key` / `create` / `update` / `delete` operations.
- **Azure AD OAuth 2.0** security (client-credentials flow) plus a bearer-token scheme for callers that already have a token.
- **OData envelope** types — `ODataCollection` (`@odata.context`, `@odata.count`, `@odata.nextLink`, `value[]`) and the standard `ODataError` shape.
- **ETag concurrency** via `@odata.etag` on every entity and `If-Match` on PATCH / DELETE.
- **OData query parameters** (`$select`, `$filter`, `$top`, `$skip`, `$orderby`, `$expand`, `$count`, `cross-company`) as reusable references, with `x-ballerina-name` extensions so the generated Ballerina `*Queries` records have idiomatic field names.
- **Composite-key paths** (`/Warehouses(dataAreaId='USMF',WarehouseId='11')`) using PascalCase OData property names in the URL and camelCase parameter names in the generated client (so they don't shadow PascalCase type names).

## Why ~300 and not the full ~2,000

The full Supply-Chain-relevant surface from the CSDL is ~2,000 entities. Generating all of them produces a single module the Ballerina compiler cannot type-check within reasonable JVM heap. The 300-entity cap is a compile-survivable subset that still covers the common integration surface.

## How the split between Finance and SCM was decided

Each EntityType in the CSDL is classified by the dominant **label-file prefix** (`@Ledger`, `@Invent`, etc.) across its property `LabelId` annotations. Entities with SCM-side labels go to this connector; Finance-side labels go to the sibling `ballerinax/microsoft.dynamics365.finance`; entities using both (e.g. customers, vendors, products) are shared and appear in both connectors. HR, Retail, Commerce, and Enterprise Asset Management entities are excluded entirely.

## Known departures

- **No bound actions** (Post, Cancel, Confirm, etc. on transactional entities). Not modelled as OpenAPI operations in this release.
- **Navigation-property response schemas** are not individually declared; `$expand` is a free-form string.
- **Country-localized entity variants** (`*_RU`, `*_BR`, etc.) and `*BiEntities` / `*CDREntities` / `*ForAI` / `*DualWrite` specialized variants are filtered out as integration noise.

## Regeneration command

From the repository root, to regenerate the Ballerina client from the committed spec:

```bash
bal openapi -i docs/spec/openapi.json --mode client --client-methods remote -o ballerina
```

Do not hand-edit `client.bal`, `types.bal`, or `utils.bal` — they are regenerated from the spec.

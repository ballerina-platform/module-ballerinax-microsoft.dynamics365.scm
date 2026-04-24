# Changelog
This file contains all the notable changes done to the Ballerina Microsoft Dynamics 365 Supply Chain Management package through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0]

### Changed
- OpenAPI spec is now generated from a real D365 F&O CSDL metadata dump (`docs/spec/tooling/edmx2oas.py`), replacing the earlier hand-reconstructed spec.
- Operation names, types, keys, and field names now match the live D365 F&O surface. `0.1.0`'s surface is entirely superseded; consumers upgrading from `0.1.0` must pin that version explicitly if their code depends on the old operation names.
- Surface expanded from ~20 entity sets to ~300 (a compile-survivable curated subset of the full Supply Chain domain; see `docs/spec/sanitations.md`).

### Added
- `docs/spec/tooling/edmx2oas.py` — deterministic regeneration tool that classifies CSDL entities into Finance / SCM / shared / excluded buckets and emits a scoped OpenAPI spec.
- Bearer-token authentication option alongside the OAuth 2.0 client-credentials flow.
- Updated mock server, integration tests, and runnable examples aligned with the new surface.

## [0.1.0] - 2026-04-22

### Added
- Initial implementation of the Microsoft Dynamics 365 Supply Chain Management connector (20 hand-curated operations from a reconstructed spec).

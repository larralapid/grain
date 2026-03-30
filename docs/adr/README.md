# Architecture Decision Records

This directory contains the Architecture Decision Records (ADRs) for the Grain iOS app. ADRs document significant technical decisions, the context that drove them, and the trade-offs accepted.

## Format

Each ADR uses the lightweight format:
- **Status**: Proposed / Accepted / Deprecated / Superseded
- **Context**: What situation or problem prompted this decision
- **Decision**: What was decided
- **Consequences**: What becomes easier or harder as a result

## Index

<!-- adrlog -->

* [ADR-0001](0001-swiftui-swiftdata.md) - ADR-0001: Use SwiftUI + SwiftData as the app framework
* [ADR-0002](0002-vision-framework-ocr.md) - ADR-0002: Use Apple Vision framework for on-device OCR
* [ADR-0003](0003-zero-external-dependencies.md) - ADR-0003: Zero external dependencies — Apple frameworks only
* [ADR-0004](0004-swift-charts.md) - ADR-0004: Use Swift Charts for analytics visualization
* [ADR-0005](0005-local-only-storage.md) - ADR-0005: Local-only storage; defer CloudKit sync
* [ADR-0006](0006-launch-experience.md) - ADR-0006: Add Launch Experience to Mask Cold Start

<!-- adrlogstop -->

## Adding a New ADR

Use `adr new "Decision Title"` (from [npryce/adr-tools](https://github.com/npryce/adr-tools)) to create the next numbered ADR, or create the file manually:

1. Create `docs/adr/NNNN-short-title.md` (next: `0007-...`), using the format above.
2. Open a PR; the CI workflow auto-updates this index via `adr-log` on merge.

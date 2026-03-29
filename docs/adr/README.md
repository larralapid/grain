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

* [ADR-1](ADR-0001-swiftui-swiftdata.md) - ADR-0001: Use SwiftUI + SwiftData as the app framework
* [ADR-2](ADR-0002-vision-framework-ocr.md) - ADR-0002: Use Apple Vision framework for on-device OCR
* [ADR-3](ADR-0003-zero-external-dependencies.md) - ADR-0003: Zero external dependencies — Apple frameworks only
* [ADR-4](ADR-0004-swift-charts.md) - ADR-0004: Use Swift Charts for analytics visualization
* [ADR-5](ADR-0005-local-only-storage.md) - ADR-0005: Local-only storage; defer CloudKit sync
* [ADR-6](ADR-0006-launch-experience.md) - ADR-0006: Add Launch Experience to Mask Cold Start

<!-- adrlogstop -->

## Adding a New ADR

1. Copy `ADR-0000-template.md` (if present) or use the format above.
2. Number sequentially (next: `ADR-0007-...`).
3. Add a row to the index table in this file.
4. Open a PR; the ADR is merged when the decision is confirmed.

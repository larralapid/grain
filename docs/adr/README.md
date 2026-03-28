# Architecture Decision Records

This directory contains the Architecture Decision Records (ADRs) for the Grain iOS app. ADRs document significant technical decisions, the context that drove them, and the trade-offs accepted.

## Format

Each ADR uses the lightweight format:
- **Status**: Proposed / Accepted / Deprecated / Superseded
- **Context**: What situation or problem prompted this decision
- **Decision**: What was decided
- **Consequences**: What becomes easier or harder as a result

## Index

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [ADR-0001](ADR-0001-swiftui-swiftdata.md) | Use SwiftUI + SwiftData as the app framework | Accepted | 2025 |
| [ADR-0002](ADR-0002-vision-framework-ocr.md) | Use Apple Vision framework for on-device OCR | Accepted | 2025 |
| [ADR-0003](ADR-0003-zero-external-dependencies.md) | Zero external dependencies — Apple frameworks only | Accepted | 2025 |
| [ADR-0004](ADR-0004-swift-charts.md) | Use Swift Charts for analytics visualization | Accepted | 2025 |
| [ADR-0005](ADR-0005-local-only-storage.md) | Local-only storage; defer CloudKit sync | Accepted | 2025 |
| [ADR-0006](ADR-0006-launch-experience.md) | Add Launch Experience to Mask Cold Start | Proposed | 2026-03-23 |

## Adding a New ADR

1. Copy `ADR-0000-template.md` (if present) or use the format above.
2. Number sequentially (next: `ADR-0007-...`).
3. Add a row to the index table in this file.
4. Open a PR; the ADR is merged when the decision is confirmed.

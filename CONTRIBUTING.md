# Contributing to Grain

Grain is a native iOS receipt scanner and granular expense tracker (SwiftUI + SwiftData, iOS 17+). It uses **Apple frameworks only** — no third-party dependencies (see [ADR-0003](docs/adr/0003-zero-external-dependencies.md)).

## Getting started

- Xcode 16+ (developed against Xcode 26.5 / iOS 26 SDK). Deployment target: **iOS 17.0**.
- Open `grain.xcodeproj` (or `grain.xcworkspace`) and run the **`grain`** scheme on an iPhone 17 simulator or a device.
- No SPM / CocoaPods / CLI build tooling — it's a pure Xcode project using file-system synchronized groups, so new files under `grain/` are picked up automatically (no project-file edits needed).

### Build & test from the CLI

```bash
xcodebuild build -scheme grain -project grain.xcodeproj \
  -destination 'platform=iOS Simulator,name=iPhone 17' -configuration Debug CODE_SIGNING_ALLOWED=NO

xcodebuild test -scheme grain -project grain.xcodeproj \
  -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:grainTests
```

A clean run ends with `** BUILD SUCCEEDED **` / `** TEST SUCCEEDED **`. Piping to `tail` can mask the real exit code — read the final line, or write to a log and `grep`.

## Project layout

- `grain/Models/` — SwiftData `@Model` types: Receipt, ReceiptItem, Product, PricePoint, Brand, BankTransaction.
- `grain/Services/` — OCR + extraction (`ReceiptScannerService`, the `ReceiptExtractor` tiers, `ExtractorCoordinator`), analytics (`AnalyticsService`), demo data (`DemoDataSeeder`).
- `grain/Views/` — SwiftUI screens. Root is `MainTabView` (receipts / scan / analytics / index / settings).
- `grain/GrainTheme.swift` — design tokens.
- `docs/` — architecture audit, ADRs, specs.

## Conventions

- **Design system.** Use `GrainTheme` tokens for every color, font, and spacing value. Typography is monospace via `GrainTheme.mono(...)`. Never hardcode colors.
- **Architecture decisions.** Significant technical decisions get an ADR in `docs/adr/` (see the [ADR README](docs/adr/README.md) for the format). Reference the relevant ADR in your PR.
- **No external dependencies.** Apple frameworks only, unless an ADR explicitly approves an exception (ADR-0003).
- **Models.** Declare `@Relationship(deleteRule:)` on to-many relationships; use `Decimal` (never `Double`) for money; include `id` / `createdAt` / `updatedAt`. Register new models in the schema in `grainApp.swift`, in `DemoDataSeeder.makePreviewContainer()`, and in any `#Preview` container.
- **Errors.** Prefer user-facing alerts over swallowing errors with `print()` (known tech debt being paid down).

## Branches & PRs

- Branch from `main` with a descriptive name (`feature/...`, `fix/...`).
- Update `CHANGELOG.md` under `[Unreleased]` for user-facing changes.
- Keep PRs focused; CI builds + tests on every PR and validates docs.

## Tests

- Unit tests live in `grainTests/` (model, service, and parser coverage); UI smoke tests in `grainUITests/`.
- Add or extend tests for new services and parsing logic.

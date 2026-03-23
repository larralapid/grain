# Grain — iOS Receipt Scanner & Expense Tracker

## Project Overview

Grain is a native iOS app (SwiftUI + SwiftData, iOS 17+) that scans receipts via on-device OCR and tracks expenses at granular product/brand level. Currently at **proof-of-concept stage** (~3,500 LOC, 20 Swift files).

## Architecture

| Layer | Tech | Notes |
|-------|------|-------|
| UI | SwiftUI | Monospace brutalist design, adaptive dark/light theme via `GrainTheme` |
| Data | SwiftData | 7 `@Model` types: Receipt, ReceiptItem, Product, PricePoint, Brand, BankTransaction, SpendingAnalytics |
| OCR | Apple Vision | On-device text recognition → regex parser (PoC quality) |
| Charts | Swift Charts | Spending breakdown views |
| Storage | Local-only | CloudKit entitlement present but inactive (ADR-0005) |
| Dependencies | Zero | Apple frameworks only (ADR-0003) |

## Key Files

- `grain/grainApp.swift` — `@main` entry, ModelContainer setup
- `grain/Views/MainTabView.swift` — 5-tab root (receipts, scan, analytics, index, settings)
- `grain/Views/ReceiptScannerView.swift` — Camera → OCR → thermal receipt proof sheet
- `grain/Services/ReceiptScannerService.swift` — Vision API + regex parser
- `grain/Services/AnalyticsService.swift` — Aggregation queries
- `grain/GrainTheme.swift` — Design tokens, `AppearanceManager`, screen modifier
- `grain/Models/` — All SwiftData models

## Documentation

- `docs/Home.md` — Doc index
- `docs/Current-State.md` — Architecture audit
- `docs/Redesign-Spec.md` — Design system and wireframes
- `docs/adr/` — Architecture Decision Records (ADR-0001 through ADR-0006)
- `CHANGELOG.md` — Keep a Changelog format

## Conventions

- **Design system**: Use `GrainTheme` tokens for all colors, fonts, and spacing. Never hardcode colors.
- **Typography**: Monospace everywhere via `GrainTheme.mono()`.
- **Architecture decisions**: Create an ADR in `docs/adr/` before or alongside any significant technical decision. Follow the format in `docs/adr/README.md`.
- **No external deps**: Apple frameworks only unless an ADR explicitly approves an exception.
- **Error handling**: Replace `print()` error swallowing with user-facing alerts (known tech debt).
- **Models**: SwiftData `@Model` classes in `grain/Models/`. Relationships should declare cascade delete rules.

## Build & Run

```bash
# Open in Xcode 15+
open grain.xcodeproj
# Build target: grain (iOS 17.0+)
# Run on simulator or physical device
```

No CLI build tools, no SPM, no CocoaPods. Pure Xcode project.

## Known Tech Debt

- `ContentView.swift` and `Item.swift` are unused Xcode template files
- `BankTransaction` model exists but has no UI or import flow
- `SpendingAnalytics` should be a plain struct, not a persisted `@Model`
- OCR parser is regex-based PoC — not production-grade
- Test coverage is limited to model and service initialisation; OCR parsing internals are not yet unit-tested (private methods)
- All errors swallowed with `print()`
- Receipt image (`imageData` field) never saved

## PR & Issue Workflow

- Branch from `main`, use descriptive branch names (e.g., `feature/splash-screen`, `fix/ocr-parser`)
- Reference ADRs in PRs when making architectural changes
- Update `CHANGELOG.md` under `[Unreleased]` for user-facing changes

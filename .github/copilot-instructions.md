# Grain — Copilot Agent Instructions

These instructions establish consistent agent behavior across the Grain development team. All Copilot agents working on this repository must follow these guidelines.

---

## Project Overview

**Grain** is a native iOS receipt-scanner and expense-tracker. It is currently at proof-of-concept stage.

| Dimension | Value |
|-----------|-------|
| Platform | iOS 17+ |
| Language | Swift 5.9+ |
| UI | SwiftUI |
| Data | SwiftData |
| OCR | Apple Vision (`VNRecognizeTextRequest`) |
| Charts | Swift Charts |
| Dependencies | **Zero external** — Apple frameworks only (ADR-0003) |
| Storage | Local-only (CloudKit entitlement present but inactive — ADR-0005) |

---

## Project Boundaries

### In Scope
- `grain/` — all Swift source files (models, views, services, app entry point)
- `grainTests/` — unit tests
- `grainUITests/` — UI tests
- `docs/` — project documentation and ADRs
- `.github/` — CI/CD workflows, issue templates, agent configuration

### Out of Scope / Do Not Touch
- `grain.xcodeproj/project.pbxproj` — only modify when adding/removing files via Xcode project structure; never edit manually unless absolutely required
- `ContentView.swift`, `Item.swift` — Xcode template leftovers; leave in place, do not delete
- CloudKit entitlement — do not activate; see ADR-0005

### Dead Code (Known, Leave Alone)
- `ContentView.swift` and `Item.swift` — unused Xcode template files
- `BankTransaction` model — schema complete but no UI or import flow
- `SpendingAnalytics` model — should eventually be a plain struct; do not add new persisted fields
- `Receipt.imageData` — field exists, scanner never saves the photo

---

## Architecture

### Layer Map

```
grain/
├── grainApp.swift            # @main entry, ModelContainer setup
├── GrainTheme.swift          # Design tokens, AppearanceManager
├── Models/
│   ├── Receipt.swift         # @Model: merchant, date, totals, items
│   ├── ReceiptItem.swift     # @Model: line item name, price, quantity
│   ├── Product.swift         # @Model: product catalog with price history
│   ├── BankTransaction.swift # @Model: bank statement rows (no UI yet)
│   └── ...
├── Views/
│   ├── MainTabView.swift     # 5-tab root navigation
│   ├── ReceiptScannerView.swift  # Camera → OCR → thermal proof sheet
│   ├── ReceiptListView.swift
│   ├── ReceiptDetailView.swift
│   ├── AnalyticsView.swift
│   ├── ProductsView.swift
│   └── SettingsView.swift   # All settings are stubs ("coming soon")
└── Services/
    ├── ReceiptScannerService.swift  # Vision OCR + regex parser
    └── AnalyticsService.swift       # Aggregation queries
```

### SwiftData Models

All persistent models use SwiftData `@Model`. Follow these rules:
- Relationships **must** declare cascade delete rules where appropriate.
- Do not add new `@Model` classes for data that is purely derived/calculated — use plain structs instead.
- `SpendingAnalytics` is a known exception (it is a `@Model` but should be a struct); do not extend it with new persisted properties.

### ModelContainer Setup

`grainApp.swift` sets up the container with all model types. When adding a new `@Model`, register it in the container schema there.

---

## Design System

**All UI must use `GrainTheme` tokens. Never hardcode colors, fonts, or spacing.**

### Colors (adaptive dark/light via `AppearanceManager.shared.isDarkMode`)

| Token | Purpose |
|-------|---------|
| `GrainTheme.bg` | Background |
| `GrainTheme.surface` | Card/surface background |
| `GrainTheme.border` | Borders and dividers |
| `GrainTheme.textPrimary` | Primary text |
| `GrainTheme.textSecondary` | Secondary/muted text |
| `GrainTheme.accent` | Interactive elements, highlights |
| `GrainTheme.dateHeader` | Date section headers |

### Typography

**Monospace everywhere.** Use `GrainTheme.mono(_ size:)` for all text. The design language is monospace brutalist.

### Applying the Theme

Views must use the `.grainScreen()` modifier (defined in `GrainTheme.swift`) as their root background.

---

## Receipt-Parsing Domain Knowledge

This section documents the OCR pipeline and parsing conventions that agents must understand before modifying `ReceiptScannerService.swift`.

### Pipeline

```
UIImage (camera capture)
  └─▶ VNRecognizeTextRequest (.accurate, usesLanguageCorrection: true)
        └─▶ [VNRecognizedTextObservation]
              └─▶ joined text string
                    └─▶ parseReceiptFromText(_:)  ← regex-based PoC
                          └─▶ Receipt + [ReceiptItem]
```

### Parser Assumptions (PoC-level, known fragile)

- **Merchant name**: First non-empty line that contains no `$` and no "TOTAL" keyword.
- **Total**: Line containing "TOTAL" → extract trailing dollar amount via regex.
- **Subtotal**: Line containing "SUBTOTAL" → same extraction.
- **Tax**: Line containing "TAX" → same extraction.
- **Date**: Lines matching common date formats (MM/DD/YYYY, YYYY-MM-DD, "Jan 01 2024", etc.).
- **Line items**: Lines matching pattern `<description> <price>` where price is a decimal with optional leading `$`.

### Known Parser Limitations

- Does not handle weight-based items (e.g. "0.5 lb @ $3.99/lb").
- Does not handle multi-currency receipts.
- Does not handle tips, BOGO, or complex discount structures.
- Regex approach has no semantic understanding — context-free line-by-line processing.
- Low-quality or skewed photos reduce accuracy at the Vision layer before the parser even runs.
- `parseReceiptFromText` and helpers are `private` — they are not directly unit-testable without refactoring.

### Extending the Parser

When modifying the parser:
1. Add regression test cases in `grainTests/` before changing logic.
2. Cover: standard grocery receipt, restaurant receipt, pharmacy receipt.
3. Do not break the existing `Receipt` and `ReceiptItem` model contract.
4. Consider extracting `parseReceiptFromText` into a testable `ReceiptParser` struct if adding significant logic.
5. An ADR is required before replacing Vision OCR with any external service.

---

## Testing Conventions

- Tests use **Swift Testing framework** (`import Testing`), not XCTest.
- Test functions are annotated with `@Test`.
- Test files live in `grainTests/`.
- UI tests live in `grainUITests/`.
- Current coverage is limited to model and service initialization. OCR parsing internals are not yet unit-tested (private methods).
- Do not remove or skip existing tests. Do not convert tests to XCTest.

---

## Documentation Conventions

- Documentation lives in `docs/`.
- `docs/adr/` contains Architecture Decision Records.
- **Create an ADR for every significant technical decision** — before or alongside implementation.
- ADR format is defined in `docs/adr/README.md`. Follow it exactly.
- Update `CHANGELOG.md` under `[Unreleased]` for every user-facing change.

---

## PR & Branch Conventions

- Branch from `main` with descriptive names: `feature/`, `fix/`, `chore/`, `docs/`.
- Reference the relevant ADR in PRs that involve architectural changes.
- Update `CHANGELOG.md` under `[Unreleased]` for user-facing changes.
- Do not merge PRs that introduce hardcoded colors, external dependencies, or XCTest-based tests.

---

## Error Handling

- **Do not swallow errors with `print()`.** This is existing tech debt — do not add more.
- New code must surface errors to the user via SwiftUI alerts or inline error states.
- `ReceiptScannerService.lastError` is the existing pattern for service-layer errors — extend it if needed.

---

## Security & Privacy

- Receipt data is sensitive. Do not add any logging that could expose receipt content, merchant names, or amounts.
- Do not send receipt images or parsed data to any external service without an approved ADR and explicit user consent flow.
- Do not commit API keys, tokens, or secrets.

---

## Memory Persistence for Agents

When working across sessions, agents with memory-persistence capabilities should persist the following types of facts (e.g. via a `store_memory` tool if available):

| Category | What to Store |
|----------|--------------|
| Architecture | New model types, view hierarchy changes, service responsibilities |
| Conventions | New GrainTheme tokens, new ADR decisions |
| Build/Test | Verified lint, build, or test commands |
| Known issues | Newly discovered bugs or tech debt not yet filed as issues |

**Do not store**: secrets, user data, or implementation details that are visible in the source code.

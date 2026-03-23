# Grain — Current State Assessment

*Audited 2026-03-22 against commit `613fe57`*

## Architecture

Native iOS 17+ app. SwiftUI + SwiftData. Zero external dependencies — uses only Apple frameworks (Vision, VisionKit, Charts, UIKit for camera).

**17 Swift files** across three layers:

| Layer | Files | Role |
|-------|-------|------|
| Models | `Receipt`, `ReceiptItem`, `Product`, `PricePoint`, `Brand`, `BankTransaction`, `SpendingAnalytics` | SwiftData `@Model` classes |
| Views | `MainTabView`, `ReceiptListView`, `ReceiptScannerView`, `ReceiptDetailView`, `ProductsView`, `AnalyticsView`, `SettingsView` | SwiftUI views |
| Services | `ReceiptScannerService`, `AnalyticsService` | Business logic |
| Dead code | `ContentView`, `Item` | Xcode template leftovers, unused |

## What Works End-to-End

1. **Scan → Parse → Save → View**: Camera captures image → Vision OCR extracts text → regex parser pulls merchant/items/totals → Receipt saved to SwiftData → appears in list → detail view shows itemized breakdown.

2. **Analytics**: Receipts in DB → `AnalyticsService` aggregates by category/brand/merchant → Swift Charts renders bar charts with period selector (weekly/monthly/quarterly/yearly).

3. **Product & Brand catalog**: Auto-populated from receipt items. Search works. Price history tracked via `PricePoint`.

4. **Receipt editing**: Edit merchant, address, category, notes, date from detail view. Saves correctly.

5. **Delete**: Swipe-to-delete on receipt list.

## What's Broken or Stubbed

### Dead buttons (no handler at all)

| Location | Button | Code |
|----------|--------|------|
| `ReceiptScannerView:~70` | "Edit" on scan preview | `// TODO: Implement edit functionality` |
| `ReceiptListView:~57` | "+" toolbar button | `// TODO: Add manual receipt entry` |

### Settings — entirely fake

All four rows in `SettingsView` navigate to `Text("…coming soon")`:
- Export Data
- Import Bank Transactions
- Tax Categories
- Deduction Rules

### Built but never wired

| Thing | Status |
|-------|--------|
| `BankTransaction` model | Complete schema with `matchConfidence`, `isMatched`, `transactionType` enum — but nothing imports, displays, or matches transactions anywhere |
| `Receipt.imageData` | Field exists, never populated. Scanner doesn't save the photo. |
| `Receipt.bankTransactionId` | Foreign key to bank transactions — no linking logic |
| `Product.imageUrl` | Stored but never rendered |
| CloudKit entitlement | Present in project, never used |

### Tax deductible calculation — hardcoded

```swift
// AnalyticsService.swift
if receipt.category == "Business" || receipt.category == "Medical" || receipt.category == "Charitable"
```

No user-configurable tax rules. The "Tax Categories" setting is a stub.

## Data Model Issues

- **Decimal for currency** — correct choice, no floating-point problems.
- **No cascading deletes defined** — deleting a Receipt doesn't explicitly clean up its ReceiptItems. SwiftData may handle this via relationship rules, but it's not declared.
- **`SpendingAnalytics`** is a SwiftData model but is created transiently by `AnalyticsService` and never persisted or queried — it should be a plain struct.

## OCR Parser Quality

`ReceiptScannerService.parseReceiptFromText()` uses basic regex:

- Looks for `$?(\d+\.\d{2})` patterns to find amounts
- Assigns the largest amount as total, second-largest as subtotal
- Calculates tax as `total - subtotal` (fragile — assumes exactly two large amounts)
- Item parsing: splits lines, looks for price patterns at end of line
- Date parsing: tries 4 `DateFormatter` patterns sequentially
- **No handling for**: multi-page receipts, non-USD currencies, tip lines, discount lines, BOGO, weight-based items

This will produce garbage output for most real-world receipts. It's a proof-of-concept parser.

## Error Handling

Every error is swallowed with `print()`:

- `ReceiptScannerView`: `print("Error saving receipt: \(error)")`
- `ReceiptDetailView`: `print("Error saving receipt: \(error)")`
- `AnalyticsService`: 3 catch blocks with `print()`, all return `nil`
- `grainApp`: `fatalError()` on ModelContainer init failure (standard pattern)

No user-facing error states. If OCR fails, the user sees nothing.

## Test Coverage

**Zero.** All three test files are Xcode template stubs with no assertions:

- `grainTests.swift` — empty `@Test` function
- `grainUITests.swift` — launch test stub
- `grainUITestsLaunchTests.swift` — screenshot attachment only

## Missing Infrastructure

- No CI/CD
- No logging framework (just `print`)
- No crash reporting
- No onboarding/tutorial
- No accessibility labels on custom views
- No localization
- No deep linking

## Priority Next Steps

1. **Receipt image persistence** — save the camera photo to `Receipt.imageData` so users can refer back to the original scan. One-line fix in `ReceiptScannerView`.

2. **Manual receipt entry** — wire the "+" button to a form. The `EditReceiptView` already exists and could be reused with minor changes.

3. **Error states in UI** — replace `print()` catches with user-visible alerts. Silent failures are the worst UX.

4. **OCR parser improvements** — the regex approach will always be limited. Consider integrating Apple's `DataScannerViewController` (Live Text) or a server-side ML parser for production quality.

5. **Tests for AnalyticsService** — pure computation with no side effects, easy to test. Start here for coverage.

6. **Delete dead code** — remove `ContentView.swift` and `Item.swift` (Xcode template leftovers).

7. **Bank transaction integration** — the model layer is ready. Needs: import UI, matching algorithm, confirmation flow.

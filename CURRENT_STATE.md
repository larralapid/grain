# Current State Assessment: Grain iOS App

*Assessment date: March 2025 — Branch `copilot/assess-current-state-document-findings`*

---

## Overview

**Grain** is a native iOS receipt scanning and expense tracking application built with SwiftUI and SwiftData. It uses on-device Vision Framework OCR to automatically extract data from receipt photos and provides analytics across categories, brands, and merchants.

---

## ✅ What Has Been Built

### Architecture

| Layer | Technology |
|---|---|
| Platform | iOS 17+ native app |
| UI Framework | SwiftUI |
| Data Persistence | SwiftData (local SQLite, no cloud yet) |
| OCR Engine | Apple Vision Framework (on-device) |
| Charts | Swift Charts |
| Pattern | MVVM-style (Models / Services / Views) |

### Implemented Features

#### 1. Receipt Scanning — `ReceiptScannerView.swift` + `ReceiptScannerService.swift`
- Camera integration via `UIImagePickerController`
- On-device OCR via Apple Vision Framework (`VNRecognizeTextRequest`)
- Heuristic text parsing to extract merchant name, date, line items, brands, prices, tax, and total
- Post-scan preview screen with Edit and Save actions

#### 2. Receipt Management — `ReceiptListView.swift` + `ReceiptDetailView.swift`
- Full receipt list sorted newest-first
- Search by merchant name or item name
- Filter by category (dropdown)
- Swipe-to-delete with SwiftData persistence
- Detail view: merchant info, address, itemized list with brand/category per item, financial summary (subtotal / tax / total)
- Edit sheet to correct any OCR errors (merchant, address, date, category, notes)

#### 3. Item & Product Tracking — `Product.swift` + `ProductsView.swift`
- Per-item extraction: name, brand, category, subcategory, quantity, unit price, total price
- Tax deductibility tagging per item
- Discount tracking fields on `ReceiptItem`
- Auto-populated product catalog from scanned receipts
- Price history per product (`PricePoint` model) across merchants and dates
- Average price calculation per product

#### 4. Brand Analytics — `Brand.swift` inside `Product.swift`
- Auto-catalogued brand entities from scanned receipt items
- Total amount spent per brand
- Transaction count and average transaction amount
- Associated product list per brand with pricing
- Drill-down brand detail view

#### 5. Spending Analytics — `AnalyticsView.swift` + `AnalyticsService.swift`
- Period views: Weekly / Monthly / Quarterly / Yearly / Custom
- KPI overview cards: Total Spent, Transaction Count, Average Transaction, Tax-Deductible Amount
- Bar charts (Swift Charts): Spending by Category, Top Brands, Top Merchants
- Tax information section (deductible amount + percentage of total)
- Async analytics generation task

#### 6. Settings — `SettingsView` (embedded in `ProductsView.swift`)
- Data: Export Data, Import Bank Transactions (stubs)
- Tax: Tax Categories, Deduction Rules (stubs)
- About: App version

---

## 🚧 Planned / Not Yet Implemented

| Feature | Status | Notes |
|---|---|---|
| AI-powered categorization | Planned | README roadmap item |
| Bank account integration | Scaffolded | `BankTransaction` model complete, no UI or service |
| CloudKit sync | Entitlement only | `grain.entitlements` configured, not integrated |
| Receipt image storage | Partial | `imageData: Data?` field on `Receipt` model not populated by scanner |
| Export to tax software | Placeholder | Settings entry navigates to placeholder view |
| Class action notifications | Planned | Settings entry with no implementation |
| Rebate tracking | Planned | Settings entry with no implementation |
| Multi-language OCR | Planned | Single-language (English) only today |
| Manual receipt entry | TODO comment | "Add Receipt" toolbar button not wired up |
| MCP integration | Planned | Mentioned in README |
| Edit receipt items | Not started | Only receipt header fields are editable |

---

## 📁 Codebase Statistics

| Area | Files | Approx Lines |
|---|---|---|
| Models | 3 | ~300 |
| Services | 2 | ~360 |
| Views | 6 | ~1,500 |
| Tests | 3 | ~50 (skeleton only) |
| App entry / config | 4 | ~30 |
| **Total** | **18** | **~2,300** |

---

## 🧪 Test Coverage

All test files are skeleton-only with no meaningful assertions:

- `grainTests.swift` — single placeholder `testExample()`, no actual logic tested
- `grainUITests.swift` — launch screenshot test only
- `grainUITestsLaunchTests.swift` — launch performance test only

**Zero coverage** on the two most critical components:
- `ReceiptScannerService` (OCR parsing logic)
- `AnalyticsService` (date range grouping, aggregations)

---

## 📸 Screenshots

UI mockups for all implemented screens are in the [`screenshots/`](screenshots/) directory.

| Screen | Description | File |
|---|---|---|
| Receipt List | Browse, search & filter receipts | [`01_receipt_list.png`](screenshots/01_receipt_list.png) |
| Receipt Scanner | Camera + OCR interface | [`02_receipt_scanner.png`](screenshots/02_receipt_scanner.png) |
| Receipt Detail | Full item breakdown + financials | [`03_receipt_detail.png`](screenshots/03_receipt_detail.png) |
| Analytics Dashboard | KPI cards + bar charts | [`04_analytics.png`](screenshots/04_analytics.png) |
| Products & Brands | Auto-catalogued product database | [`05_products.png`](screenshots/05_products.png) |
| Settings | Configuration options | [`06_settings.png`](screenshots/06_settings.png) |
| Scan Preview (Post-OCR) | Review & save scanned receipt | [`07_scan_preview.png`](screenshots/07_scan_preview.png) |
| Brand Detail | Brand spending drill-down | [`08_brand_detail.png`](screenshots/08_brand_detail.png) |

---

## 🔍 Notable Observations

1. **OCR parsing is heuristic-based** — `ReceiptScannerService` uses regex and string matching to parse receipt text. Real-world receipt layouts vary widely; accuracy will require testing against real receipts and iterative parser improvements.

2. **No unit tests on critical services** — `ReceiptScannerService` and `AnalyticsService` have zero test coverage. These are the most complex, logic-heavy components.

3. **`BankTransaction` model is fully defined but entirely unused** — Complete model with `matchConfidence`, `isMatched`, and `TransactionType` fields ready for bank reconciliation; no service or UI has been built yet.

4. **All settings actions are non-functional stubs** — Export Data, Import Bank Transactions, Tax Categories, and Deduction Rules all navigate to placeholder `Text("…coming soon")` views.

5. **Receipt images not persisted** — `Receipt.imageData: Data?` field exists on the model but `ReceiptScannerService.scanReceipt()` never populates it. Users can't review the original receipt photo after saving.

6. **Manual receipt entry not implemented** — The "Add Receipt" button in the navigation bar has no action (`// TODO: Add manual receipt entry`).

7. **`AnalyticsPeriod.allCases` requires `CaseIterable`** — The `AnalyticsView` iterates `AnalyticsPeriod.allCases` for the segmented picker; ensure the enum declares `CaseIterable` conformance in `BankTransaction.swift`.

---

## 📋 Recommended Next Steps (Priority Order)

- [ ] **Write unit tests** for `ReceiptScannerService` (parsing logic with fixture receipt text)
- [ ] **Write unit tests** for `AnalyticsService` (date grouping, aggregation, edge cases)
- [ ] **Persist receipt images** — populate `Receipt.imageData` during the scan flow
- [ ] **Implement manual receipt entry** — wire up the "Add Receipt" button
- [ ] **Implement item editing** — allow correction of individual line items post-scan
- [ ] **Implement Export Data** — CSV/JSON export of receipts and analytics
- [ ] **Build bank transaction import** — UI and matching logic against `BankTransaction` model
- [ ] **Add CloudKit sync** — leverage existing entitlement for multi-device support
- [ ] **Improve OCR parser robustness** — test on real receipts, handle more formats
- [ ] **Tax Categories & Deduction Rules** — build out settings configuration

---

*See also: [`screenshots/README.md`](screenshots/README.md) for annotated screenshots of each screen.*

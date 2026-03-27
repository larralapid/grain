# Grain — Test Case Document

## Overview

This document defines the test cases for grain's automated test suite. Tests cover model initialization, data integrity, OCR parsing, analytics calculations, and UI launch behavior.

---

## Unit Tests (`grainTests/`)

### 1. Receipt Model Tests

| ID | Test Case | Expected |
|----|-----------|----------|
| R-01 | Create receipt with all required fields | All properties set, UUID generated, timestamps set |
| R-02 | Create receipt with default optional fields | Optional fields are nil |
| R-03 | Receipt items array starts empty | `items` is `[]` on init |
| R-04 | Verify receipt total/subtotal/tax are Decimal | No floating-point precision loss |

### 2. ReceiptItem Model Tests

| ID | Test Case | Expected |
|----|-----------|----------|
| RI-01 | Create item with all fields | All properties set correctly |
| RI-02 | Item quantity defaults correctly | Quantity matches init param |
| RI-03 | Item price calculations | unitPrice * quantity == totalPrice for single qty |
| RI-04 | Item with discount | Discount field stored correctly |

### 3. Product Model Tests

| ID | Test Case | Expected |
|----|-----------|----------|
| P-01 | Create product with required fields | name, category set; UUID generated |
| P-02 | Product price history starts empty | `priceHistory` is `[]` |
| P-03 | Product isTaxable defaults to true | `isTaxable == true` |
| P-04 | Product description attribute mapping | `productDescription` maps to `description` column |

### 4. Brand Model Tests

| ID | Test Case | Expected |
|----|-----------|----------|
| B-01 | Create brand with name | Spending stats initialize to zero |
| B-02 | Brand products list starts empty | `products` is `[]` |

### 5. BankTransaction Model Tests

| ID | Test Case | Expected |
|----|-----------|----------|
| BT-01 | Create debit transaction | Type is `.debit`, isMatched is false |
| BT-02 | Create credit transaction | Type is `.credit` |
| BT-03 | TransactionType raw values | Correct string values for all cases |

### 6. Planned OCR Parser Tests (`ReceiptScannerService`)

_Note: The following OCR parser test cases describe planned coverage. As of now, `grainTests/grainTests.swift` only verifies the initial state of `ReceiptScannerService` and does not yet implement these parsing/extraction tests._
| ID | Test Case | Expected |
|----|-----------|----------|
| OCR-01 | Extract amount "$12.99" | Returns Decimal(12.99) |
| OCR-02 | Extract amount "12.99" (no $) | Returns Decimal(12.99) |
| OCR-03 | Extract amount from "TOTAL $45.67" | Returns Decimal(45.67) |
| OCR-04 | No amount in text | Returns nil |
| OCR-05 | Parse simple receipt text | Merchant, items, total extracted |
| OCR-06 | Parse receipt with SUBTOTAL/TAX/TOTAL | All three extracted correctly |
| OCR-07 | Empty text returns nil or unknown merchant | Graceful handling |
| OCR-08 | Filter out TOTAL/SUBTOTAL/TAX from items | These lines not parsed as items |

### 7. Analytics Calculation Tests

| ID | Test Case | Expected |
|----|-----------|----------|
| A-01 | Category breakdown with tagged items | Correct per-category totals |
| A-02 | Brand breakdown | Correct per-brand totals |
| A-03 | Merchant breakdown | Correct per-merchant totals |
| A-04 | Average transaction amount | total / count |
| A-05 | Tax deductible filtering | Only Business/Medical/Charitable counted |
| A-06 | Empty receipts list | Zero totals, empty breakdowns |
| A-07 | AnalyticsPeriod enum raw values | All cases have correct strings |

### 8. Theme Tests

| ID | Test Case | Expected |
|----|-----------|----------|
| T-01 | GrainTheme colors are non-nil | All color tokens return valid Color |
| T-02 | Mono font returns system monospaced | Font design is .monospaced |
| ID | Test Case | Method | Expected |
|----|-----------|--------|----------|
| R-01 | Create receipt with all required fields | `receiptInitSetsAllRequiredFields` | All properties set, UUID generated |
| R-02 | Create receipt with default optional fields | `receiptOptionalFieldsDefaultToNil` | Optional fields are nil |
| R-03 | Receipt items array starts empty | `receiptItemsStartEmpty` | `items` is `[]` on init |
| R-04 | Verify receipt total/subtotal/tax are Decimal | `receiptUsesDecimalPrecision` | No floating-point precision loss |
| R-05 | Timestamps set on init | `receiptTimestampsSetOnInit` | `createdAt` and `updatedAt` fall within init window |

### 2. ReceiptItem Model Tests

| ID | Test Case | Method | Expected |
|----|-----------|--------|----------|
| RI-01 | Create item with all fields | `itemInitSetsAllFields` | All properties set correctly including discount |
| RI-02 | Optional fields default to nil | `itemOptionalFieldsDefaultToNil` | brand, category, sku, barcode, receipt, product, taxCategory, discount are nil |
| RI-03 | Item quantity matches init param | `itemQuantityMatchesInit` | `quantity` equals value passed on init |

### 3. Product Model Tests

| ID | Test Case | Method | Expected |
|----|-----------|--------|----------|
| P-01 | Create product with required fields | `productInitSetsRequiredFields` | name, category set; UUID generated |
| P-02 | Product price history starts empty | `productPriceHistoryStartsEmpty` | `priceHistory` is `[]` |
| P-03 | Product isTaxable defaults to true | `productIsTaxableDefaultsTrue` | `isTaxable == true` |
| P-04 | Product description attribute mapping | `productDescriptionAttributeMapping` | `productDescription` maps to `description` column |
| P-05 | Product non-taxable flag | `productNonTaxable` | `isTaxable == false` when explicitly set |

### 4. Brand Model Tests

| ID | Test Case | Method | Expected |
|----|-----------|--------|----------|
| B-01 | Create brand with name | `brandInitWithZeroStats` | Spending stats initialize to zero |
| B-02 | Brand products list starts empty | `brandProductsStartEmpty` | `products` is `[]` |
| B-03 | Brand with category | `brandWithCategory` | `category` field stored correctly |

### 5. BankTransaction Model Tests

| ID | Test Case | Method | Expected |
|----|-----------|--------|----------|
| BT-01 | Create debit transaction | `debitTransactionInit` | Type is `.debit`, isMatched is false |
| BT-02 | Create credit transaction | `creditTransactionInit` | Type is `.credit` |
| BT-03 | TransactionType raw values | `transactionTypeRawValues` | Correct string values for all cases |
| BT-04 | All TransactionType cases | `allTransactionTypeCases` | Exactly 3 cases: debit, credit, transfer |

### 6. SpendingAnalytics Model Tests

| ID | Test Case | Method | Expected |
|----|-----------|--------|----------|
| A-01 | Analytics init with all fields | `analyticsInitWithAllFields` | period, totalSpent, transactionCount, breakdowns stored correctly |
| A-02 | AnalyticsPeriod raw values | `analyticsPeriodRawValues` | weekly/monthly/quarterly/yearly/custom have correct strings |
| A-03 | All AnalyticsPeriod cases | `allAnalyticsPeriodCases` | Exactly 5 cases |

### 7. OCR Parser Tests (`ReceiptScannerService`)

| ID | Test Case | Method | Expected |
|----|-----------|--------|----------|
| OCR-01 | Service initial state | `receiptScannerServiceInitialState` | `isScanning == false`, `scannedText == ""`, `lastError == nil` |

> **Note:** Internal parsing methods (`extractAmount`, receipt text parsing) are private and not yet unit-testable. Making them `internal` and adding granular tests (amount extraction, item filtering, merchant detection) is tracked as future work.

### 8. PricePoint Model Tests

| ID | Test Case | Method | Expected |
|----|-----------|--------|----------|
| PP-01 | PricePoint init | `pricePointInit` | price, date, merchantName set; product and receiptItem are nil |

---

## UI Tests (`grainUITests/`)

| ID | Test Case | Expected |
|----|-----------|----------|
| UI-01 | App launches successfully | MainTabView visible |
| UI-02 | All 5 tabs exist | receipts, scan, analytics, index, settings tabs present |
| UI-03 | Tab navigation works | Tapping each tab switches content |
| UI-04 | Launch performance | Cold start < 3 seconds |

---

## Test Data Factories

Tests use in-memory SwiftData containers to avoid disk I/O. Factory methods create pre-configured test objects.
## Test Infrastructure

Unit tests instantiate model objects directly (no SwiftData container required) since the tests exercise initializer logic and property access, not persistence. UI tests use `XCUIApplication` launched fresh for each test class.

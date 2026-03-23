# Grain — Test Case Document

## Overview

This document defines the test cases for grain's automated test suite. Tests cover model initialization, data integrity, OCR parsing, and UI launch behavior.

---

## Unit Tests (`grainTests/`)

### 1. Receipt Model Tests

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

## Test Infrastructure

Unit tests instantiate model objects directly (no SwiftData container required) since the tests exercise initializer logic and property access, not persistence. UI tests use `XCUIApplication` launched fresh for each test class.

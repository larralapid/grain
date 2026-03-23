//
//  grainTests.swift
//  grainTests
//
//  Created by Larra Lapid on 7/14/25.
//

import Testing
import Foundation
@testable import grain

// MARK: - Receipt Model Tests

struct ReceiptTests {

    @Test func receiptInitSetsAllRequiredFields() async throws {
        let date = Date()
        let receipt = Receipt(
            date: date,
            merchantName: "Trader Joe's",
            merchantAddress: "123 Main St",
            total: Decimal(string: "45.67")!,
            subtotal: Decimal(string: "42.00")!,
            tax: Decimal(string: "3.67")!
        )

        #expect(receipt.merchantName == "Trader Joe's")
        #expect(receipt.merchantAddress == "123 Main St")
        #expect(receipt.total == Decimal(string: "45.67")!)
        #expect(receipt.subtotal == Decimal(string: "42.00")!)
        #expect(receipt.tax == Decimal(string: "3.67")!)
        #expect(receipt.date == date)
    }

    @Test func receiptOptionalFieldsDefaultToNil() async throws {
        let receipt = Receipt(
            date: Date(),
            merchantName: "Test",
            total: 10,
            subtotal: 9,
            tax: 1
        )

        #expect(receipt.merchantAddress == nil)
        #expect(receipt.imageData == nil)
        #expect(receipt.ocrText == nil)
        #expect(receipt.bankTransactionId == nil)
        #expect(receipt.category == nil)
        #expect(receipt.notes == nil)
    }

    @Test func receiptItemsStartEmpty() async throws {
        let receipt = Receipt(
            date: Date(),
            merchantName: "Test",
            total: 10,
            subtotal: 9,
            tax: 1
        )

        #expect(receipt.items.isEmpty)
    }

    @Test func receiptUsesDecimalPrecision() async throws {
        let receipt = Receipt(
            date: Date(),
            merchantName: "Test",
            total: Decimal(string: "99.99")!,
            subtotal: Decimal(string: "92.52")!,
            tax: Decimal(string: "7.47")!
        )

        // Verify no floating-point drift
        #expect(receipt.total == Decimal(string: "99.99")!)
        #expect(receipt.subtotal + receipt.tax == Decimal(string: "99.99")!)
    }

    @Test func receiptTimestampsSetOnInit() async throws {
        let before = Date()
        let receipt = Receipt(
            date: Date(),
            merchantName: "Test",
            total: 10,
            subtotal: 9,
            tax: 1
        )
        let after = Date()

        #expect(receipt.createdAt >= before)
        #expect(receipt.createdAt <= after)
        #expect(receipt.updatedAt >= before)
        #expect(receipt.updatedAt <= after)
    }
}

// MARK: - ReceiptItem Model Tests

struct ReceiptItemTests {

    @Test func itemInitSetsAllFields() async throws {
        let item = ReceiptItem(
            name: "Organic Milk",
            brand: "Horizon",
            category: "Dairy",
            quantity: 2,
            unitPrice: Decimal(string: "4.99")!,
            totalPrice: Decimal(string: "9.98")!,
            sku: "HOR-MLK-001",
            barcode: "012345678901",
            taxCategory: "Grocery",
            discount: Decimal(string: "1.00")!
        )

        #expect(item.name == "Organic Milk")
        #expect(item.brand == "Horizon")
        #expect(item.category == "Dairy")
        #expect(item.quantity == 2)
        #expect(item.unitPrice == Decimal(string: "4.99")!)
        #expect(item.totalPrice == Decimal(string: "9.98")!)
        #expect(item.sku == "HOR-MLK-001")
        #expect(item.barcode == "012345678901")
        #expect(item.taxCategory == "Grocery")
        #expect(item.discount == Decimal(string: "1.00")!)
    }

    @Test func itemOptionalFieldsDefaultToNil() async throws {
        let item = ReceiptItem(
            name: "Test Item",
            quantity: 1,
            unitPrice: 5,
            totalPrice: 5
        )

        #expect(item.brand == nil)
        #expect(item.category == nil)
        #expect(item.sku == nil)
        #expect(item.barcode == nil)
        #expect(item.receipt == nil)
        #expect(item.product == nil)
        #expect(item.taxCategory == nil)
        #expect(item.discount == nil)
    }

    @Test func itemQuantityMatchesInit() async throws {
        let item = ReceiptItem(
            name: "Bananas",
            quantity: 6,
            unitPrice: Decimal(string: "0.25")!,
            totalPrice: Decimal(string: "1.50")!
        )

        #expect(item.quantity == 6)
    }
}

// MARK: - Product Model Tests

struct ProductTests {

    @Test func productInitSetsRequiredFields() async throws {
        let product = Product(
            name: "Almond Butter",
            brand: "Justin's",
            category: "Pantry"
        )

        #expect(product.name == "Almond Butter")
        #expect(product.brand == "Justin's")
        #expect(product.category == "Pantry")
        #expect(product.id != UUID())
    }

    @Test func productPriceHistoryStartsEmpty() async throws {
        let product = Product(name: "Test", category: "Test")
        #expect(product.priceHistory.isEmpty)
    }

    @Test func productIsTaxableDefaultsTrue() async throws {
        let product = Product(name: "Test", category: "Test")
        #expect(product.isTaxable == true)
    }

    @Test func productDescriptionAttributeMapping() async throws {
        let product = Product(
            name: "Test",
            category: "Test",
            description: "A test product"
        )
        #expect(product.productDescription == "A test product")
    }

    @Test func productNonTaxable() async throws {
        let product = Product(
            name: "Fresh Vegetables",
            category: "Produce",
            isTaxable: false
        )
        #expect(product.isTaxable == false)
    }
}

// MARK: - Brand Model Tests

struct BrandTests {

    @Test func brandInitWithZeroStats() async throws {
        let brand = Brand(name: "Apple")

        #expect(brand.name == "Apple")
        #expect(brand.totalSpent == 0)
        #expect(brand.transactionCount == 0)
        #expect(brand.averageTransactionAmount == 0)
    }

    @Test func brandProductsStartEmpty() async throws {
        let brand = Brand(name: "Test")
        #expect(brand.products.isEmpty)
    }

    @Test func brandWithCategory() async throws {
        let brand = Brand(name: "Nike", category: "Athletic")
        #expect(brand.category == "Athletic")
    }
}

// MARK: - BankTransaction Model Tests

struct BankTransactionTests {

    @Test func debitTransactionInit() async throws {
        let tx = BankTransaction(
            transactionId: "TXN-001",
            amount: Decimal(string: "25.50")!,
            date: Date(),
            description: "Coffee purchase",
            merchantName: "Blue Bottle",
            accountId: "ACC-001",
            accountName: "Checking",
            transactionType: .debit
        )

        #expect(tx.transactionType == .debit)
        #expect(tx.isMatched == false)
        #expect(tx.matchConfidence == nil)
        #expect(tx.transactionDescription == "Coffee purchase")
    }

    @Test func creditTransactionInit() async throws {
        let tx = BankTransaction(
            transactionId: "TXN-002",
            amount: Decimal(string: "100.00")!,
            date: Date(),
            description: "Refund",
            accountId: "ACC-001",
            accountName: "Checking",
            transactionType: .credit
        )

        #expect(tx.transactionType == .credit)
    }

    @Test func transactionTypeRawValues() async throws {
        #expect(TransactionType.debit.rawValue == "debit")
        #expect(TransactionType.credit.rawValue == "credit")
        #expect(TransactionType.transfer.rawValue == "transfer")
    }

    @Test func allTransactionTypeCases() async throws {
        let allCases = TransactionType.allCases
        #expect(allCases.count == 3)
        #expect(allCases.contains(.debit))
        #expect(allCases.contains(.credit))
        #expect(allCases.contains(.transfer))
    }
}

// MARK: - SpendingAnalytics Model Tests

struct SpendingAnalyticsTests {

    @Test func analyticsInitWithAllFields() async throws {
        let analytics = SpendingAnalytics(
            period: .monthly,
            startDate: Date(),
            endDate: Date(),
            totalSpent: Decimal(string: "500.00")!,
            categoryBreakdown: ["Grocery": Decimal(string: "300.00")!, "Dining": Decimal(string: "200.00")!],
            brandBreakdown: ["Brand A": Decimal(string: "500.00")!],
            merchantBreakdown: ["Store A": Decimal(string: "500.00")!],
            averageTransactionAmount: Decimal(string: "50.00")!,
            transactionCount: 10,
            topCategories: ["Grocery", "Dining"],
            topBrands: ["Brand A"],
            topMerchants: ["Store A"],
            taxDeductibleAmount: Decimal(string: "100.00")!
        )

        #expect(analytics.period == .monthly)
        #expect(analytics.totalSpent == Decimal(string: "500.00")!)
        #expect(analytics.transactionCount == 10)
        #expect(analytics.categoryBreakdown.count == 2)
    }

    @Test func analyticsPeriodRawValues() async throws {
        #expect(AnalyticsPeriod.weekly.rawValue == "weekly")
        #expect(AnalyticsPeriod.monthly.rawValue == "monthly")
        #expect(AnalyticsPeriod.quarterly.rawValue == "quarterly")
        #expect(AnalyticsPeriod.yearly.rawValue == "yearly")
        #expect(AnalyticsPeriod.custom.rawValue == "custom")
    }

    @Test func allAnalyticsPeriodCases() async throws {
        let allCases = AnalyticsPeriod.allCases
        #expect(allCases.count == 5)
    }
}

// MARK: - OCR Parser Tests

struct OCRParserTests {

    // Test the parser via a testable wrapper
    // Note: ReceiptScannerService methods are private, so we test
    // the public scanReceipt flow. For unit testing internal parsing,
    // these methods should be made internal (not private) with @testable.

    @Test func receiptScannerServiceInitialState() async throws {
        let service = ReceiptScannerService()
        #expect(service.isScanning == false)
        #expect(service.scannedText == "")
        #expect(service.lastError == nil)
    }
}

// MARK: - PricePoint Tests

struct PricePointTests {

    @Test func pricePointInit() async throws {
        let date = Date()
        let pp = PricePoint(
            price: Decimal(string: "3.99")!,
            date: date,
            merchantName: "Whole Foods"
        )

        #expect(pp.price == Decimal(string: "3.99")!)
        #expect(pp.date == date)
        #expect(pp.merchantName == "Whole Foods")
        #expect(pp.product == nil)
        #expect(pp.receiptItem == nil)
    }
}

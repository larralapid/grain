import Foundation
import SwiftData

@Model
final class BankTransaction {
    var id: UUID
    var transactionId: String
    var amount: Decimal
    var date: Date
    @Attribute(originalName: "description") var transactionDescription: String
    var merchantName: String?
    var category: String?
    var accountId: String
    var accountName: String
    var transactionType: TransactionType
    var receipt: Receipt?
    var isMatched: Bool
    var matchConfidence: Double?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        transactionId: String,
        amount: Decimal,
        date: Date,
        description: String,
        merchantName: String? = nil,
        category: String? = nil,
        accountId: String,
        accountName: String,
        transactionType: TransactionType
    ) {
        self.id = UUID()
        self.transactionId = transactionId
        self.amount = amount
        self.date = date
        self.transactionDescription = description
        self.merchantName = merchantName
        self.category = category
        self.accountId = accountId
        self.accountName = accountName
        self.transactionType = transactionType
        self.isMatched = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum TransactionType: String, Codable, CaseIterable {
    case debit = "debit"
    case credit = "credit"
    case transfer = "transfer"
}

@Model
final class SpendingAnalytics {
    var id: UUID
    var period: AnalyticsPeriod
    var startDate: Date
    var endDate: Date
    var totalSpent: Decimal
    var categoryBreakdown: [String: Decimal]
    var brandBreakdown: [String: Decimal]
    var merchantBreakdown: [String: Decimal]
    var averageTransactionAmount: Decimal
    var transactionCount: Int
    var topCategories: [String]
    var topBrands: [String]
    var topMerchants: [String]
    var taxDeductibleAmount: Decimal
    var createdAt: Date
    
    init(
        period: AnalyticsPeriod,
        startDate: Date,
        endDate: Date,
        totalSpent: Decimal,
        categoryBreakdown: [String: Decimal],
        brandBreakdown: [String: Decimal],
        merchantBreakdown: [String: Decimal],
        averageTransactionAmount: Decimal,
        transactionCount: Int,
        topCategories: [String],
        topBrands: [String],
        topMerchants: [String],
        taxDeductibleAmount: Decimal
    ) {
        self.id = UUID()
        self.period = period
        self.startDate = startDate
        self.endDate = endDate
        self.totalSpent = totalSpent
        self.categoryBreakdown = categoryBreakdown
        self.brandBreakdown = brandBreakdown
        self.merchantBreakdown = merchantBreakdown
        self.averageTransactionAmount = averageTransactionAmount
        self.transactionCount = transactionCount
        self.topCategories = topCategories
        self.topBrands = topBrands
        self.topMerchants = topMerchants
        self.taxDeductibleAmount = taxDeductibleAmount
        self.createdAt = Date()
    }
}

enum AnalyticsPeriod: String, Codable, CaseIterable {
    case weekly = "weekly"
    case monthly = "monthly"
    case quarterly = "quarterly"
    case yearly = "yearly"
    case custom = "custom"
}

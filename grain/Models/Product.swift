import Foundation
import SwiftData

@Model
final class Product {
    var id: UUID
    var name: String
    var brand: String?
    var category: String
    var subcategory: String?
    var barcode: String?
    var sku: String?
    var averagePrice: Decimal?
    var priceHistory: [PricePoint]
    var isTaxable: Bool
    var taxCategory: String?
    var description: String?
    var imageUrl: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        name: String,
        brand: String? = nil,
        category: String,
        subcategory: String? = nil,
        barcode: String? = nil,
        sku: String? = nil,
        isTaxable: Bool = true,
        taxCategory: String? = nil,
        description: String? = nil,
        imageUrl: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.brand = brand
        self.category = category
        self.subcategory = subcategory
        self.barcode = barcode
        self.sku = sku
        self.isTaxable = isTaxable
        self.taxCategory = taxCategory
        self.description = description
        self.imageUrl = imageUrl
        self.priceHistory = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

@Model
final class PricePoint {
    var id: UUID
    var price: Decimal
    var date: Date
    var merchantName: String
    var product: Product?
    var receiptItem: ReceiptItem?
    
    init(price: Decimal, date: Date, merchantName: String) {
        self.id = UUID()
        self.price = price
        self.date = date
        self.merchantName = merchantName
    }
}

@Model
final class Brand {
    var id: UUID
    var name: String
    var category: String?
    var totalSpent: Decimal
    var transactionCount: Int
    var averageTransactionAmount: Decimal
    var products: [Product]
    var createdAt: Date
    var updatedAt: Date
    
    init(name: String, category: String? = nil) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.totalSpent = 0
        self.transactionCount = 0
        self.averageTransactionAmount = 0
        self.products = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
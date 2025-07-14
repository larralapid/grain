import Foundation
import SwiftData

@Model
final class Receipt {
    var id: UUID
    var date: Date
    var merchantName: String
    var merchantAddress: String?
    var total: Decimal
    var subtotal: Decimal
    var tax: Decimal
    var imageData: Data?
    var ocrText: String?
    var bankTransactionId: String?
    var items: [ReceiptItem]
    var category: String?
    var notes: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        date: Date,
        merchantName: String,
        merchantAddress: String? = nil,
        total: Decimal,
        subtotal: Decimal,
        tax: Decimal,
        imageData: Data? = nil,
        ocrText: String? = nil,
        bankTransactionId: String? = nil,
        category: String? = nil,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.date = date
        self.merchantName = merchantName
        self.merchantAddress = merchantAddress
        self.total = total
        self.subtotal = subtotal
        self.tax = tax
        self.imageData = imageData
        self.ocrText = ocrText
        self.bankTransactionId = bankTransactionId
        self.items = []
        self.category = category
        self.notes = notes
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

@Model
final class ReceiptItem {
    var id: UUID
    var name: String
    var brand: String?
    var category: String?
    var quantity: Int
    var unitPrice: Decimal
    var totalPrice: Decimal
    var sku: String?
    var barcode: String?
    var receipt: Receipt?
    var product: Product?
    var taxCategory: String?
    var discount: Decimal?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        name: String,
        brand: String? = nil,
        category: String? = nil,
        quantity: Int,
        unitPrice: Decimal,
        totalPrice: Decimal,
        sku: String? = nil,
        barcode: String? = nil,
        taxCategory: String? = nil,
        discount: Decimal? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.brand = brand
        self.category = category
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.totalPrice = totalPrice
        self.sku = sku
        self.barcode = barcode
        self.taxCategory = taxCategory
        self.discount = discount
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
import Foundation
import SwiftData

class AnalyticsService: ObservableObject {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func generateSpendingAnalytics(for period: AnalyticsPeriod, startDate: Date, endDate: Date) async -> SpendingAnalytics? {
        let predicate = #Predicate<Receipt> { receipt in
            receipt.date >= startDate && receipt.date <= endDate
        }
        
        let descriptor = FetchDescriptor<Receipt>(predicate: predicate)
        
        do {
            let receipts = try modelContext.fetch(descriptor)
            
            let totalSpent = receipts.reduce(Decimal(0)) { total, receipt in
                total + receipt.total
            }
            
            let categoryBreakdown = calculateCategoryBreakdown(from: receipts)
            let brandBreakdown = calculateBrandBreakdown(from: receipts)
            let merchantBreakdown = calculateMerchantBreakdown(from: receipts)
            
            let averageTransactionAmount = receipts.isEmpty ? Decimal(0) : totalSpent / Decimal(receipts.count)
            let transactionCount = receipts.count
            
            let topCategories = Array(categoryBreakdown.sorted { $0.value > $1.value }.prefix(10).map { $0.key })
            let topBrands = Array(brandBreakdown.sorted { $0.value > $1.value }.prefix(10).map { $0.key })
            let topMerchants = Array(merchantBreakdown.sorted { $0.value > $1.value }.prefix(10).map { $0.key })
            
            let taxDeductibleAmount = calculateTaxDeductibleAmount(from: receipts)
            
            return SpendingAnalytics(
                period: period,
                startDate: startDate,
                endDate: endDate,
                totalSpent: totalSpent,
                categoryBreakdown: categoryBreakdown,
                brandBreakdown: brandBreakdown,
                merchantBreakdown: merchantBreakdown,
                averageTransactionAmount: averageTransactionAmount,
                transactionCount: transactionCount,
                topCategories: topCategories,
                topBrands: topBrands,
                topMerchants: topMerchants,
                taxDeductibleAmount: taxDeductibleAmount
            )
        } catch {
            print("Error generating analytics: \(error)")
            return nil
        }
    }
    
    private func calculateCategoryBreakdown(from receipts: [Receipt]) -> [String: Decimal] {
        var breakdown: [String: Decimal] = [:]
        
        for receipt in receipts {
            for item in receipt.items {
                let category = item.category ?? "Uncategorized"
                breakdown[category, default: 0] += item.totalPrice
            }
        }
        
        return breakdown
    }
    
    private func calculateBrandBreakdown(from receipts: [Receipt]) -> [String: Decimal] {
        var breakdown: [String: Decimal] = [:]
        
        for receipt in receipts {
            for item in receipt.items {
                let brand = item.brand ?? "Unknown Brand"
                breakdown[brand, default: 0] += item.totalPrice
            }
        }
        
        return breakdown
    }
    
    private func calculateMerchantBreakdown(from receipts: [Receipt]) -> [String: Decimal] {
        var breakdown: [String: Decimal] = [:]
        
        for receipt in receipts {
            breakdown[receipt.merchantName, default: 0] += receipt.total
        }
        
        return breakdown
    }
    
    private func calculateTaxDeductibleAmount(from receipts: [Receipt]) -> Decimal {
        return receipts.reduce(Decimal(0)) { total, receipt in
            if receipt.category == "Business" || receipt.category == "Medical" || receipt.category == "Charitable" {
                return total + receipt.total
            }
            return total
        }
    }
    
    func getBrandSpending(for brand: String, in period: DateInterval) async -> [PricePoint] {
        let predicate = #Predicate<ReceiptItem> { item in
            item.brand == brand &&
            item.receipt != nil &&
            item.receipt!.date >= period.start &&
            item.receipt!.date <= period.end
        }
        
        let descriptor = FetchDescriptor<ReceiptItem>(predicate: predicate)
        
        do {
            let items = try modelContext.fetch(descriptor)
            return items.compactMap { item in
                guard let receipt = item.receipt else { return nil }
                return PricePoint(
                    price: item.totalPrice,
                    date: receipt.date,
                    merchantName: receipt.merchantName
                )
            }
        } catch {
            print("Error fetching brand spending: \(error)")
            return []
        }
    }
    
    func getSpendingTrends(for category: String, groupedBy period: AnalyticsPeriod) async -> [SpendingTrend] {
        let predicate = #Predicate<ReceiptItem> { item in
            item.category == category
        }
        
        let descriptor = FetchDescriptor<ReceiptItem>(predicate: predicate)
        
        do {
            let items = try modelContext.fetch(descriptor)
            let groupedItems = groupItemsByPeriod(items, period: period)
            
            return groupedItems.map { (dateKey, items) in
                let totalSpent = items.reduce(Decimal(0)) { $0 + $1.totalPrice }
                return SpendingTrend(
                    period: dateKey,
                    amount: totalSpent,
                    transactionCount: items.count
                )
            }.sorted { $0.period < $1.period }
        } catch {
            print("Error fetching spending trends: \(error)")
            return []
        }
    }
    
    private func groupItemsByPeriod(_ items: [ReceiptItem], period: AnalyticsPeriod) -> [String: [ReceiptItem]] {
        var grouped: [String: [ReceiptItem]] = [:]
        
        let formatter = DateFormatter()
        
        switch period {
        case .weekly:
            formatter.dateFormat = "yyyy-'W'ww"
        case .monthly:
            formatter.dateFormat = "yyyy-MM"
        case .quarterly:
            formatter.dateFormat = "yyyy-'Q'Q"
        case .yearly:
            formatter.dateFormat = "yyyy"
        case .custom:
            formatter.dateFormat = "yyyy-MM-dd"
        }
        
        for item in items {
            guard let receipt = item.receipt else { continue }
            let key = formatter.string(from: receipt.date)
            grouped[key, default: []].append(item)
        }
        
        return grouped
    }
}

struct SpendingTrend {
    let period: String
    let amount: Decimal
    let transactionCount: Int
}
import SwiftUI

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            ReceiptListView()
                .tabItem {
                    Label("Receipts", systemImage: "receipt")
                }
            
            ReceiptScannerView()
                .tabItem {
                    Label("Scan", systemImage: "camera")
                }
            
            AnalyticsView(modelContext: modelContext)
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar")
                }
            
            ProductsView()
                .tabItem {
                    Label("Products", systemImage: "tag")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Receipt.self, ReceiptItem.self, Product.self, Brand.self, BankTransaction.self, SpendingAnalytics.self], inMemory: true)
}
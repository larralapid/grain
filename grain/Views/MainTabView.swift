import SwiftUI

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var appearance = AppearanceManager.shared
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ReceiptListView()
                .tabItem {
                    Label("receipts", systemImage: "doc.text")
                }
                .tag(0)

            ReceiptScannerView()
                .tabItem {
                    Label("scan", systemImage: "viewfinder")
                }
                .tag(1)

            AnalyticsView(modelContext: modelContext)
                .tabItem {
                    Label("analytics", systemImage: "chart.bar")
                }
                .tag(2)

            ProductsView()
                .tabItem {
                    Label("index", systemImage: "list.bullet")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("settings", systemImage: "gearshape")
                }
                .tag(4)
        }
        .tint(GrainTheme.accent)
        .onAppear { updateTabBarAppearance() }
        .onChange(of: appearance.isDarkMode) { _, _ in updateTabBarAppearance() }
    }

    private func updateTabBarAppearance() {
        let isDark = appearance.isDarkMode
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()

        tabAppearance.backgroundColor = isDark
            ? UIColor(red: 0.055, green: 0.055, blue: 0.055, alpha: 1)
            : UIColor(red: 0.976, green: 0.973, blue: 0.965, alpha: 1)

        tabAppearance.shadowColor = isDark
            ? UIColor(white: 0.149, alpha: 1)
            : UIColor(red: 0.878, green: 0.871, blue: 0.855, alpha: 1)

        let normalColor: UIColor = isDark
            ? UIColor(white: 0.376, alpha: 1)
            : UIColor(red: 0.533, green: 0.522, blue: 0.502, alpha: 1)

        let selectedColor: UIColor = isDark
            ? UIColor(white: 0.627, alpha: 1)
            : UIColor(red: 0.4, green: 0.392, blue: 0.376, alpha: 1)

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.titleTextAttributes = [
            .font: UIFont.monospacedSystemFont(ofSize: 10, weight: .regular),
            .foregroundColor: normalColor
        ]
        itemAppearance.selected.titleTextAttributes = [
            .font: UIFont.monospacedSystemFont(ofSize: 10, weight: .regular),
            .foregroundColor: selectedColor
        ]
        itemAppearance.normal.iconColor = normalColor
        itemAppearance.selected.iconColor = selectedColor

        tabAppearance.stackedLayoutAppearance = itemAppearance
        tabAppearance.inlineLayoutAppearance = itemAppearance
        tabAppearance.compactInlineLayoutAppearance = itemAppearance

        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Receipt.self, ReceiptItem.self, Product.self, Brand.self, BankTransaction.self, SpendingAnalytics.self], inMemory: true)
}

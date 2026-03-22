//
//  grainApp.swift
//  grain
//
//  Created by Larra Lapid on 7/14/25.
//

import SwiftUI
import SwiftData

@main
struct grainApp: App {
    @ObservedObject private var appearance = AppearanceManager.shared

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Receipt.self,
            ReceiptItem.self,
            Product.self,
            PricePoint.self,
            Brand.self,
            BankTransaction.self,
            SpendingAnalytics.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(appearance.isDarkMode ? .dark : .light)
        }
        .modelContainer(sharedModelContainer)
    }
}

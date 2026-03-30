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

    var body: some Scene {
        WindowGroup {
            LaunchExperienceView(modelContainerBuilder: Self.makeSharedModelContainer)
                .preferredColorScheme(appearance.isDarkMode ? .dark : .light)
        }
    }

    private static func makeSharedModelContainer() throws -> ModelContainer {
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

        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    }
}

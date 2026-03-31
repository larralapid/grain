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

    /// Set via scheme environment variable LAUNCH_POC to switch launch experience.
    /// Values: "splash" (default), "skeleton", "notifications"
    private var launchPOC: String {
        ProcessInfo.processInfo.environment["LAUNCH_POC"] ?? "splash"
    }

    var body: some Scene {
        WindowGroup {
            launchView
                .preferredColorScheme(appearance.isDarkMode ? .dark : .light)
        }
    }

    @ViewBuilder
    private var launchView: some View {
        switch launchPOC {
        case "skeleton":
            SkeletonLaunchView(modelContainerBuilder: Self.makeSharedModelContainer)
        case "notifications":
            NotificationsLaunchView(modelContainerBuilder: Self.makeSharedModelContainer)
        default:
            LaunchExperienceView(modelContainerBuilder: Self.makeSharedModelContainer)
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

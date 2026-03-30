//
//  grainUITests.swift
//  grainUITests
//
//  Created by Larra Lapid on 7/14/25.
//

import XCTest

final class grainUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // UI-01: App launches successfully
    @MainActor
    func testAppLaunches() throws {
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
    }

    // UI-02: All 5 tabs exist
    @MainActor
    func testAllTabsExist() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists, "Tab bar should exist")

        let expectedTabs = ["receipts", "scan", "analytics", "index", "settings"]
        for tab in expectedTabs {
            XCTAssertTrue(
                tabBar.buttons[tab].exists,
                "Tab '\(tab)' should exist in tab bar"
            )
        }
    }

    // UI-03: Tab navigation works
    @MainActor
    func testTabNavigation() throws {
        let tabBar = app.tabBars.firstMatch

        let tabs = ["scan", "analytics", "index", "settings", "receipts"]
        for tab in tabs {
            tabBar.buttons[tab].tap()
            // Verify the tab is now selected
            XCTAssertTrue(
                tabBar.buttons[tab].isSelected,
                "Tab '\(tab)' should be selected after tapping"
            )
        }
    }

    // UI-04: Launch performance
    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}

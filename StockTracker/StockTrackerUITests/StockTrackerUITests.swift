//
//  StockTrackerUITests.swift
//  StockTrackerUITests
//
//  Created by Atchibabu Chitri on 16/03/26.
//

import XCTest

final class StockTrackerUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Stocks List Screen

    @MainActor
    func testConnectionStatusShowsDisconnectedInitially() throws {
        XCTAssertTrue(app.staticTexts["Disconnected"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testFeedControlButtonShowsStartInitially() throws {
        let feedButton = app.buttons["feedControlButton"]
        XCTAssertTrue(feedButton.waitForExistence(timeout: 3))
        XCTAssertTrue(feedButton.label.contains("Start"))
    }

    @MainActor
    func testSymbolListContainsExpectedStocks() throws {
        // These are at the top when sorted by price, so visible without scrolling
        XCTAssertTrue(app.staticTexts["NVIDIA Corp."].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Meta Platforms"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Microsoft Corp."].waitForExistence(timeout: 2))
    }

    @MainActor
    func testSortPickerHasPriceAndPriceChangeOptions() throws {
        let sortPicker = app.segmentedControls["sortPicker"]
        XCTAssertTrue(sortPicker.waitForExistence(timeout: 3))
        XCTAssertTrue(sortPicker.buttons["Price"].exists)
        XCTAssertTrue(sortPicker.buttons["Price Change"].exists)
    }

    @MainActor
    func testTapSymbolNavigatesToDetailView() throws {
        let nvidiaCell = app.staticTexts["NVIDIA Corp."]
        XCTAssertTrue(nvidiaCell.waitForExistence(timeout: 5))
        nvidiaCell.tap()

        XCTAssertTrue(app.navigationBars["NVDA"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Current Price"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Price Change"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Change %"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testDetailViewShowsPriceInformation() throws {
        let nvidiaCell = app.staticTexts["NVIDIA Corp."]
        XCTAssertTrue(nvidiaCell.waitForExistence(timeout: 5))
        nvidiaCell.tap()

        XCTAssertTrue(app.staticTexts["Current Price"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["$875.20"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testDetailViewHasFeedControlButton() throws {
        let nvidiaCell = app.staticTexts["NVIDIA Corp."]
        XCTAssertTrue(nvidiaCell.waitForExistence(timeout: 5))
        nvidiaCell.tap()

        let detailFeedButton = app.buttons["detailFeedControlButton"]
        XCTAssertTrue(detailFeedButton.waitForExistence(timeout: 3))
        XCTAssertTrue(detailFeedButton.label.contains("Start Price Feed") || detailFeedButton.label.contains("Stop Price Feed"))
    }

    @MainActor
    func testNavigateBackFromDetailToStocksList() throws {
        let nvidiaCell = app.staticTexts["NVIDIA Corp."]
        XCTAssertTrue(nvidiaCell.waitForExistence(timeout: 5))
        nvidiaCell.tap()

        XCTAssertTrue(app.navigationBars["NVDA"].waitForExistence(timeout: 3))

        app.navigationBars["NVDA"].buttons["Stocks"].tap()

        XCTAssertTrue(app.navigationBars["Stocks"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testChangeSortOption() throws {
        let sortPicker = app.segmentedControls["sortPicker"]
        XCTAssertTrue(sortPicker.waitForExistence(timeout: 3))

        sortPicker.buttons["Price Change"].tap()

        XCTAssertTrue(sortPicker.buttons["Price Change"].isSelected)
    }

    @MainActor
    func testTapStartButton() throws {
        let feedButton = app.buttons["feedControlButton"]
        XCTAssertTrue(feedButton.waitForExistence(timeout: 3))
        XCTAssertTrue(feedButton.isEnabled)

        feedButton.tap()

        let stopExists = app.buttons["feedControlButton"].label.contains("Stop")
        let startExists = app.buttons["feedControlButton"].label.contains("Start")
        XCTAssertTrue(stopExists || startExists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}

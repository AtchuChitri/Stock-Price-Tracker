//
//  StockTrackerApp.swift
//  StockTracker
//
//  Created by Atchibabu Chitri on 16/03/26.
//

import SwiftUI

@main
struct StockTrackerApp: App {
    @StateObject private var priceFeedService = PriceFeedService()

    var body: some Scene {
        WindowGroup {
            SymbolsListView(priceFeedService: priceFeedService)
        }
    }
}

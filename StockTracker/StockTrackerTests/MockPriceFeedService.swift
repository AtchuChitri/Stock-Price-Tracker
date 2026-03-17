//
//  MockPriceFeedService.swift
//  StockTrackerTests
//
//  Created by Atchibabu Chitri on 17/03/26.
//

import Foundation
import Combine
@testable import StockTracker

@MainActor
final class MockPriceFeedService: ObservableObject, PriceFeedServiceProtocol {
    @Published var symbols: [StockSymbol]
    @Published var connectionStatus: ConnectionStatus
    
    var startPriceFeedCallCount = 0
    var stopPriceFeedCallCount = 0
    
    var symbolsPublisher: AnyPublisher<[StockSymbol], Never> {
        $symbols.eraseToAnyPublisher()
    }
    
    var connectionStatusPublisher: AnyPublisher<ConnectionStatus, Never> {
        $connectionStatus.eraseToAnyPublisher()
    }
    
    init(symbols: [StockSymbol] = PriceFeedService.defaultSymbols, connectionStatus: ConnectionStatus = .disconnected) {
        self.symbols = symbols
        self.connectionStatus = connectionStatus
    }
    
    func startPriceFeed() {
        startPriceFeedCallCount += 1
        connectionStatus = .connecting
    }
    
    func stopPriceFeed() {
        stopPriceFeedCallCount += 1
        connectionStatus = .disconnected
    }
    
    func symbol(for id: String) -> StockSymbol? {
        symbols.first { $0.id == id }
    }
    
    // Test helpers
    func simulateConnectionConnected() {
        connectionStatus = .connected
    }
    
    func simulateConnectionConnecting() {
        connectionStatus = .connecting
    }
    
    func simulateConnectionDisconnected() {
        connectionStatus = .disconnected
    }
    
    func updateSymbols(_ newSymbols: [StockSymbol]) {
        symbols = newSymbols
    }
}

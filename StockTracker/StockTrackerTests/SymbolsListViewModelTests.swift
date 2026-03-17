//
//  SymbolsListViewModelTests.swift
//  StockTrackerTests
//
//  Created by Atchibabu Chitri on 17/03/26.
//

import XCTest
@testable import StockTracker

@MainActor
final class SymbolsListViewModelTests: XCTestCase {
    
    private var mockPriceFeedService: MockPriceFeedService!
    
    #if DEBUG
    private static var leakedViewModels: [SymbolsListViewModel] = []
    private static var leakedMocks: [MockPriceFeedService] = []
    #endif
    
    override func setUp() async throws {
        try await super.setUp()
        mockPriceFeedService = MockPriceFeedService()
    }
    
    override func tearDown() async throws {
        #if DEBUG
        if let mock = mockPriceFeedService {
            Self.leakedMocks.append(mock)
        }
        #endif
        mockPriceFeedService = nil
        try await super.tearDown()
    }
    
    private func retain(_ viewModel: SymbolsListViewModel) {
        #if DEBUG
        Self.leakedViewModels.append(viewModel)
        #endif
    }
    
    // MARK: - Initialization
    
    func testInitialState() {
        let viewModel = SymbolsListViewModel(priceFeedService: mockPriceFeedService)
        retain(viewModel)
        
        XCTAssertNil(viewModel.selectedSymbol)
        XCTAssertEqual(viewModel.sortOption, .price)
        XCTAssertEqual(viewModel.connectionStatus, .disconnected)
        XCTAssertFalse(viewModel.isConnected)
        XCTAssertFalse(viewModel.isFeedControlDisabled)
    }
    
    // MARK: - sortedSymbols
    
    func testSortedSymbolsByPrice() {
        let symbols = [
            StockSymbol(id: "A", name: "A", price: 100, priceChange: 1, priceChangePercent: 1),
            StockSymbol(id: "B", name: "B", price: 200, priceChange: 2, priceChangePercent: 2),
            StockSymbol(id: "C", name: "C", price: 150, priceChange: 3, priceChangePercent: 3)
        ]
        mockPriceFeedService.updateSymbols(symbols)
        
        let viewModel = SymbolsListViewModel(priceFeedService: mockPriceFeedService)
        retain(viewModel)
        viewModel.sortOption = .price
        
        let sorted = viewModel.sortedSymbols
        XCTAssertEqual(sorted.map(\.id), ["B", "C", "A"])
        XCTAssertEqual(sorted[0].price, 200)
        XCTAssertEqual(sorted[1].price, 150)
        XCTAssertEqual(sorted[2].price, 100)
    }
    
    func testSortedSymbolsByPriceChange() {
        let symbols = [
            StockSymbol(id: "A", name: "A", price: 100, priceChange: -5, priceChangePercent: -5),
            StockSymbol(id: "B", name: "B", price: 200, priceChange: 10, priceChangePercent: 10),
            StockSymbol(id: "C", name: "C", price: 150, priceChange: 2, priceChangePercent: 2)
        ]
        mockPriceFeedService.updateSymbols(symbols)
        
        let viewModel = SymbolsListViewModel(priceFeedService: mockPriceFeedService)
        retain(viewModel)
        viewModel.sortOption = .priceChange
        
        let sorted = viewModel.sortedSymbols
        XCTAssertEqual(sorted.map(\.id), ["B", "C", "A"])
        XCTAssertEqual(sorted[0].priceChange, 10)
        XCTAssertEqual(sorted[1].priceChange, 2)
        XCTAssertEqual(sorted[2].priceChange, -5)
    }
    
    // MARK: - Connection Status
    
    func testConnectionStatusReflectsService() {
        let viewModel = SymbolsListViewModel(priceFeedService: mockPriceFeedService)
        retain(viewModel)
        
        mockPriceFeedService.simulateConnectionConnecting()
        XCTAssertEqual(viewModel.connectionStatus, .connecting)
        XCTAssertTrue(viewModel.isFeedControlDisabled)
        
        mockPriceFeedService.simulateConnectionConnected()
        XCTAssertEqual(viewModel.connectionStatus, .connected)
        XCTAssertTrue(viewModel.isConnected)
        XCTAssertFalse(viewModel.isFeedControlDisabled)
        
        mockPriceFeedService.simulateConnectionDisconnected()
        XCTAssertEqual(viewModel.connectionStatus, .disconnected)
        XCTAssertFalse(viewModel.isConnected)
    }
    
    // MARK: - toggleFeed
    
    func testToggleFeedCallsStopWhenConnected() {
        mockPriceFeedService.simulateConnectionConnected()
        let viewModel = SymbolsListViewModel(priceFeedService: mockPriceFeedService)
        retain(viewModel)
        
        viewModel.toggleFeed()
        
        XCTAssertEqual(mockPriceFeedService.stopPriceFeedCallCount, 1)
        XCTAssertEqual(mockPriceFeedService.startPriceFeedCallCount, 0)
    }
    
    func testToggleFeedCallsStartWhenDisconnected() {
        let viewModel = SymbolsListViewModel(priceFeedService: mockPriceFeedService)
        retain(viewModel)
        
        viewModel.toggleFeed()
        
        XCTAssertEqual(mockPriceFeedService.startPriceFeedCallCount, 1)
        XCTAssertEqual(mockPriceFeedService.stopPriceFeedCallCount, 0)
    }
    
    func testToggleFeedCallsStartWhenConnecting() {
        mockPriceFeedService.simulateConnectionConnecting()
        let viewModel = SymbolsListViewModel(priceFeedService: mockPriceFeedService)
        retain(viewModel)
        
        viewModel.toggleFeed()
        
        // When not connected (including .connecting), toggleFeed calls startPriceFeed
        XCTAssertEqual(mockPriceFeedService.startPriceFeedCallCount, 1)
    }
    
    // MARK: - selectSymbol
    
    func testSelectSymbol() {
        let symbol = StockSymbol(id: "AAPL", name: "Apple", price: 175, priceChange: 2, priceChangePercent: 1.2)
        mockPriceFeedService.updateSymbols([symbol])
        
        let viewModel = SymbolsListViewModel(priceFeedService: mockPriceFeedService)
        retain(viewModel)
        XCTAssertNil(viewModel.selectedSymbol)
        
        viewModel.selectSymbol(symbol)
        
        XCTAssertEqual(viewModel.selectedSymbol?.id, "AAPL")
        XCTAssertEqual(viewModel.selectedSymbol?.name, "Apple")
    }
    
    // MARK: - sortOption
    
    func testSortOptionCanBeChanged() {
        let viewModel = SymbolsListViewModel(priceFeedService: mockPriceFeedService)
        retain(viewModel)
        
        XCTAssertEqual(viewModel.sortOption, .price)
        
        viewModel.sortOption = .priceChange
        XCTAssertEqual(viewModel.sortOption, .priceChange)
        
        viewModel.sortOption = .price
        XCTAssertEqual(viewModel.sortOption, .price)
    }
    
    // MARK: - priceFeedService
    
    func testPriceFeedServiceIsExposed() {
        let viewModel = SymbolsListViewModel(priceFeedService: mockPriceFeedService)
        retain(viewModel)
        
        XCTAssertTrue(viewModel.priceFeedService is MockPriceFeedService)
    }
}

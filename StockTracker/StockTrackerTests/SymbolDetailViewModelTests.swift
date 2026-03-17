//
//  SymbolDetailViewModelTests.swift
//  StockTrackerTests
//
//  Created by Atchibabu Chitri on 17/03/26.
//

import XCTest
@testable import StockTracker

@MainActor
final class SymbolDetailViewModelTests: XCTestCase {
    
    private var mockPriceFeedService: MockPriceFeedService!
    private var testSymbol: StockSymbol!
    
    #if DEBUG
    /// Retain view models and mocks to avoid deallocation-time malloc crash in Swift runtime
    /// when tearing down @MainActor + @Published + Combine-heavy objects under XCTest.
    private static var leakedViewModels: [SymbolDetailViewModel] = []
    private static var leakedMocks: [MockPriceFeedService] = []
    #endif
    
    override func setUp() async throws {
        try await super.setUp()
        testSymbol = StockSymbol(id: "AAPL", name: "Apple Inc.", price: 175.50, priceChange: 2.30, priceChangePercent: 1.33)
        mockPriceFeedService = MockPriceFeedService(symbols: [testSymbol])
    }
    
    override func tearDown() async throws {
        #if DEBUG
        if let mock = mockPriceFeedService {
            Self.leakedMocks.append(mock)
        }
        #endif
        mockPriceFeedService = nil
        testSymbol = nil
        try await super.tearDown()
    }
    
    private func retain(_ viewModel: SymbolDetailViewModel) {
        #if DEBUG
        Self.leakedViewModels.append(viewModel)
        #endif
    }
    
    // MARK: - Initialization
    
    func testInitialState() {
        let viewModel = SymbolDetailViewModel(symbol: testSymbol, priceFeedService: mockPriceFeedService)
        retain(viewModel)
        
        XCTAssertEqual(viewModel.symbol.id, "AAPL")
        XCTAssertEqual(viewModel.connectionStatus, .disconnected)
        XCTAssertFalse(viewModel.isConnected)
        XCTAssertFalse(viewModel.isFeedControlDisabled)
    }
    
    // MARK: - currentSymbol
    
    func testCurrentSymbolReturnsUpdatedSymbolFromService() {
        let viewModel = SymbolDetailViewModel(symbol: testSymbol, priceFeedService: mockPriceFeedService)
        retain(viewModel)
        
        XCTAssertEqual(viewModel.currentSymbol.id, "AAPL")
        XCTAssertEqual(viewModel.currentSymbol.price, 175.50)
        
        let updatedSymbol = StockSymbol(id: "AAPL", name: "Apple Inc.", price: 180.00, priceChange: 4.50, priceChangePercent: 2.57)
        mockPriceFeedService.updateSymbols([updatedSymbol])
        
        XCTAssertEqual(viewModel.currentSymbol.price, 180.00)
        XCTAssertEqual(viewModel.currentSymbol.priceChange, 4.50)
    }
    
    func testCurrentSymbolReturnsOriginalWhenSymbolNotInService() {
        mockPriceFeedService.updateSymbols([])
        let viewModel = SymbolDetailViewModel(symbol: testSymbol, priceFeedService: mockPriceFeedService)
        retain(viewModel)
        
        XCTAssertEqual(viewModel.currentSymbol.id, "AAPL")
        XCTAssertEqual(viewModel.currentSymbol.price, 175.50)
    }
    
    // MARK: - Connection Status
    
    func testConnectionStatusReflectsService() {
        let viewModel = SymbolDetailViewModel(symbol: testSymbol, priceFeedService: mockPriceFeedService)
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
        let viewModel = SymbolDetailViewModel(symbol: testSymbol, priceFeedService: mockPriceFeedService)
        retain(viewModel)
        
        viewModel.toggleFeed()
        
        XCTAssertEqual(mockPriceFeedService.stopPriceFeedCallCount, 1)
        XCTAssertEqual(mockPriceFeedService.startPriceFeedCallCount, 0)
    }
    
    func testToggleFeedCallsStartWhenDisconnected() {
        let viewModel = SymbolDetailViewModel(symbol: testSymbol, priceFeedService: mockPriceFeedService)
        retain(viewModel)
        
        viewModel.toggleFeed()
        
        XCTAssertEqual(mockPriceFeedService.startPriceFeedCallCount, 1)
        XCTAssertEqual(mockPriceFeedService.stopPriceFeedCallCount, 0)
    }
    
    // MARK: - Multiple symbols
    
    func testCurrentSymbolWithMultipleSymbolsInService() {
        let symbol2 = StockSymbol(id: "GOOG", name: "Alphabet", price: 142, priceChange: -1, priceChangePercent: -0.7)
        mockPriceFeedService.updateSymbols([testSymbol, symbol2])
        
        let viewModel = SymbolDetailViewModel(symbol: testSymbol, priceFeedService: mockPriceFeedService)
        retain(viewModel)
        
        XCTAssertEqual(viewModel.currentSymbol.id, "AAPL")
        
        let updatedAAPL = StockSymbol(id: "AAPL", name: "Apple Inc.", price: 200, priceChange: 25, priceChangePercent: 14.3)
        mockPriceFeedService.updateSymbols([updatedAAPL, symbol2])
        
        XCTAssertEqual(viewModel.currentSymbol.price, 200)
        XCTAssertEqual(viewModel.currentSymbol.priceChange, 25)
    }
}

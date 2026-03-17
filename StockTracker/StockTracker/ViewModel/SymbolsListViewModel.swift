//
//  SymbolsListViewModel.swift
//  StockTracker
//
//  Created by Atchibabu Chitri on 16/03/26.
//
import Foundation
import Combine


@MainActor
final class SymbolsListViewModel: ObservableObject {
    
    // MARK: - Published State
    @Published var selectedSymbol: StockSymbol?
    @Published var sortOption: SortOption = .price
    
    // MARK: - Dependencies
    
    let priceFeedService: PriceFeedService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties
    
    var sortedSymbols: [StockSymbol] {
        switch sortOption {
        case .price:
            return priceFeedService.symbols.sorted { $0.price > $1.price }
        case .priceChange:
            return priceFeedService.symbols.sorted { $0.priceChange > $1.priceChange }
        }
    }
    
    var connectionStatus: ConnectionStatus {
        priceFeedService.connectionStatus
    }
    
    var isConnected: Bool {
        connectionStatus == .connected
    }
    
    var isFeedControlDisabled: Bool {
        connectionStatus == .connecting
    }
    
    // MARK: - Init
    init(priceFeedService: PriceFeedService) {
        self.priceFeedService = priceFeedService
        setupObservers()
    }
    
    private func setupObservers() {
        priceFeedService.$symbols
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        priceFeedService.$connectionStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    func toggleFeed() {
        if priceFeedService.connectionStatus == .connected {
            priceFeedService.stopPriceFeed()
        } else {
            priceFeedService.startPriceFeed()
        }
    }
    func selectSymbol(_ symbol: StockSymbol) {
        selectedSymbol = symbol
    }
}

enum ConnectionStatus {
    case disconnected
    case connecting
    case connected
    
    var displayText: String {
        switch self {
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting..."
        case .connected: return "Connected"
        }
    }
}

enum SortOption: String, CaseIterable {
    case price = "Price"
    case priceChange = "Price Change"
}

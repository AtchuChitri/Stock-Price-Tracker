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
        return .disconnected
    }
    
    var isConnected: Bool {
        connectionStatus == .connected
    }
    
    // MARK: - Init
    init(priceFeedService: PriceFeedService) {
        self.priceFeedService = priceFeedService
    }
    
    // MARK: - Actions
    
    func toggleFeed() {
        if connectionStatus == .connected {
            // stop service
        } else {
           // start service
        }
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

//
//  SymbolDetailViewModel.swift
//  StockTracker
//
//  Created by Atchibabu Chitri on 17/03/26.
//

import Foundation
import Combine

@MainActor
final class SymbolDetailViewModel: ObservableObject {
    // MARK: - Input
    
    let symbol: StockSymbol
    
    // MARK: - Dependencies
    
    private let priceFeedService: any PriceFeedServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var currentSymbol: StockSymbol {
        priceFeedService.symbol(for: symbol.id) ?? symbol
    }
    
    var connectionStatus: ConnectionStatus {
        priceFeedService.connectionStatus
    }
    
    var isFeedControlDisabled: Bool {
        connectionStatus == .connecting
    }
    
    var isConnected: Bool {
        connectionStatus == .connected
    }
    
    // MARK: - Init
    
    init(symbol: StockSymbol, priceFeedService: any PriceFeedServiceProtocol) {
        self.symbol = symbol
        self.priceFeedService = priceFeedService
        setupObservers()
    }
    
    private func setupObservers() {
        priceFeedService.symbolsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        priceFeedService.connectionStatusPublisher
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
}

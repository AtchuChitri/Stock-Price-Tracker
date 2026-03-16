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
    
    var connectionStatus: ConnectionStatus {
        return .disconnected
    }
    
    var isConnected: Bool {
        connectionStatus == .connected
    }
    
    // MARK: - Init
    public init () {
        
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

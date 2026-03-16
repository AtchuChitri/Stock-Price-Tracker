//
//  ConnectionStatusView.swift
//  StockTracker
//
//  Created by Atchibabu Chitri on 16/03/26.
//
import SwiftUI

struct ConnectionStatusView: View {
    let status: ConnectionStatus
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
            Text(status.displayText)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .connected: return .green
        case .connecting: return .orange
        case .disconnected: return .red
        }
    }
}

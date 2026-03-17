//
//  SymbolDetailView.swift
//  StockTracker
//
//  Created by Atchibabu Chitri on 17/03/26.
//

import SwiftUI

struct SymbolDetailView: View {
    let symbol: StockSymbol
    @StateObject private var viewModel: SymbolDetailViewModel
    
    init(symbol: StockSymbol, priceFeedService: PriceFeedService) {
        self.symbol = symbol
        _viewModel = StateObject(wrappedValue: SymbolDetailViewModel(symbol: symbol, priceFeedService: priceFeedService))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                connectionSection
                priceSection(stock: viewModel.currentSymbol)
                changeSection(stock: viewModel.currentSymbol)
            }
            .padding(24)
        }
        .navigationTitle(symbol.id)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var connectionSection: some View {
        VStack(spacing: 12) {
            ConnectionStatusView(status: viewModel.connectionStatus)
            
            Button(action: { viewModel.toggleFeed() }) {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.isConnected ? "stop.circle.fill" : "play.circle.fill")
                    Text(viewModel.isConnected ? "Stop Price Feed" : "Start Price Feed")
                        .fontWeight(.semibold)
                }
                .font(.body)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(viewModel.isConnected ? Color.red : Color.green)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isFeedControlDisabled)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func priceSection(stock: StockSymbol) -> some View {
        VStack(spacing: 8) {
            Text("Current Price")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(stock.formattedPrice)
                .font(.system(size: 36, weight: .bold))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func changeSection(stock: StockSymbol) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Price Change")
                    .font(.headline)
                Spacer()
                Text(stock.formattedChange)
                    .font(.headline)
                    .foregroundColor(stock.isPositiveChange ? .green : .red)
            }
            
            Divider()
            
            HStack {
                Text("Change %")
                    .font(.headline)
                Spacer()
                Text(stock.formattedChangePercent)
                    .font(.headline)
                    .foregroundColor(stock.isPositiveChange ? .green : .red)
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SymbolDetailView(symbol: PriceFeedService.defaultSymbols[0], priceFeedService: PriceFeedService())
    }
}

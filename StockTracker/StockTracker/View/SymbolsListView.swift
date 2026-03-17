//
//  SymbolsListView.swift
//  StockTracker
//
//  Created by Atchibabu Chitri on 16/03/26.
//
import SwiftUI
struct SymbolsListView: View {
    @StateObject private var viewModel: SymbolsListViewModel

    init(priceFeedService: PriceFeedService) {
        _viewModel = StateObject(wrappedValue: SymbolsListViewModel(priceFeedService: priceFeedService))
    }
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                connectionHeader
                sortPicker
                symbolsList
            }
            .navigationTitle("Stocks")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $viewModel.selectedSymbol) { symbol in
                SymbolDetailView(symbol: symbol, priceFeedService: viewModel.priceFeedService)
            }
        }
    }
    private var connectionHeader: some View {
        VStack(spacing: 12) {
            HStack {
                ConnectionStatusView(status: viewModel.connectionStatus)
                Spacer()
                feedControlButton
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.systemGroupedBackground))
            
            Divider()
        }
    }

    private var feedControlButton: some View {
        Button(action: { viewModel.toggleFeed() }) {
            HStack(spacing: 6) {
                Image(systemName: viewModel.isConnected ? "stop.circle.fill" : "play.circle.fill")
                Text(viewModel.isConnected ? "Stop" : "Start")
                    .fontWeight(.semibold)
            }
            .font(.subheadline)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(viewModel.isConnected ? Color.red : Color.green)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isFeedControlDisabled)
    }
    
    private var symbolsList: some View {
        List(viewModel.sortedSymbols) { symbol in
            SymbolRowView(symbol: symbol)
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.selectSymbol(symbol)
                }
        }
        .listStyle(.plain)
    }

    private var sortPicker: some View {
        Picker("Sort by", selection: $viewModel.sortOption) {
            ForEach(SortOption.allCases, id: \.self) { option in
                Text(option.rawValue).tag(option)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

// MARK: - Preview

#Preview {
    SymbolsListView(priceFeedService: PriceFeedService())
}

//
//  SymbolRowView.swift
//  StockTracker
//
//  Created by Atchibabu Chitri on 16/03/26.
//
import SwiftUI

struct SymbolRowView: View {
    let symbol: StockSymbol
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(symbol.name)
                    .font(.headline)
                Text(symbol.id)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(symbol.formattedPrice)
                    .font(.headline)
                Text(symbol.formattedChangePercent)
                    .font(.subheadline)
                    .foregroundColor(symbol.isPositiveChange ? .green : .red)
            }
        }
        .padding(.vertical, 8)
        .accessibilityIdentifier("symbolRow_\(symbol.id)")
    }
}

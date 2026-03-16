//
//  stockSymbol.swift
//  StockTracker
//
//  Created by Atchibabu Chitri on 16/03/26.
//

import Foundation

struct StockSymbol: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    var price: Double
    var priceChange: Double
    var priceChangePercent: Double
    
    var formattedPrice: String {
        String(format: "$%.2f", price)
    }
    
    var formattedChange: String {
        let sign = priceChange >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", priceChange))"
    }
    
    var formattedChangePercent: String {
        let sign = priceChangePercent >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", priceChangePercent))%"
    }
    
    var isPositiveChange: Bool {
        priceChange >= 0
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

//
//  PriceFeedService.swift
//  StockTracker
//
//  Created by Atchibabu Chitri on 16/03/26.
//

import Foundation
import Combine

final class PriceFeedService: NSObject, ObservableObject {
    
    static let defaultSymbols: [StockSymbol] = [
        StockSymbol(id: "AAPL", name: "Apple Inc.", price: 175.50, priceChange: 2.30, priceChangePercent: 1.33),
        StockSymbol(id: "GOOG", name: "Alphabet Inc.", price: 142.80, priceChange: -1.20, priceChangePercent: -0.83),
        StockSymbol(id: "TSLA", name: "Tesla Inc.", price: 248.90, priceChange: 5.40, priceChangePercent: 2.22),
        StockSymbol(id: "AMZN", name: "Amazon.com Inc.", price: 178.25, priceChange: 0.85, priceChangePercent: 0.48),
        StockSymbol(id: "MSFT", name: "Microsoft Corp.", price: 415.60, priceChange: -3.10, priceChangePercent: -0.74),
        StockSymbol(id: "NVDA", name: "NVIDIA Corp.", price: 875.20, priceChange: 12.50, priceChangePercent: 1.45),
        StockSymbol(id: "META", name: "Meta Platforms", price: 485.30, priceChange: 8.20, priceChangePercent: 1.72),
        StockSymbol(id: "JPM", name: "JPMorgan Chase", price: 195.40, priceChange: -2.15, priceChangePercent: -1.09),
        StockSymbol(id: "V", name: "Visa Inc.", price: 278.90, priceChange: 1.45, priceChangePercent: 0.52),
        StockSymbol(id: "JNJ", name: "Johnson & Johnson", price: 158.75, priceChange: -0.95, priceChangePercent: -0.60),
        StockSymbol(id: "WMT", name: "Walmart Inc.", price: 168.20, priceChange: 2.80, priceChangePercent: 1.69),
        StockSymbol(id: "PG", name: "Procter & Gamble", price: 165.40, priceChange: 0.60, priceChangePercent: 0.36),
        StockSymbol(id: "UNH", name: "UnitedHealth Group", price: 525.80, priceChange: -4.20, priceChangePercent: -0.79),
        StockSymbol(id: "HD", name: "Home Depot", price: 385.60, priceChange: 3.25, priceChangePercent: 0.85),
        StockSymbol(id: "DIS", name: "Walt Disney Co.", price: 112.45, priceChange: -1.80, priceChangePercent: -1.58),
        StockSymbol(id: "BAC", name: "Bank of America", price: 38.90, priceChange: 0.45, priceChangePercent: 1.17),
        StockSymbol(id: "XOM", name: "Exxon Mobil", price: 118.30, priceChange: -2.10, priceChangePercent: -1.74),
        StockSymbol(id: "CVX", name: "Chevron Corp.", price: 155.80, priceChange: 1.20, priceChangePercent: 0.78),
        StockSymbol(id: "KO", name: "Coca-Cola Co.", price: 58.95, priceChange: 0.25, priceChangePercent: 0.43),
        StockSymbol(id: "PEP", name: "PepsiCo Inc.", price: 168.50, priceChange: -0.90, priceChangePercent: -0.53),
        StockSymbol(id: "COST", name: "Costco Wholesale", price: 585.40, priceChange: 7.80, priceChangePercent: 1.35),
        StockSymbol(id: "NFLX", name: "Netflix Inc.", price: 485.20, priceChange: 15.30, priceChangePercent: 3.26),
        StockSymbol(id: "ADBE", name: "Adobe Inc.", price: 525.80, priceChange: -6.40, priceChangePercent: -1.20),
        StockSymbol(id: "CRM", name: "Salesforce Inc.", price: 268.90, priceChange: 4.15, priceChangePercent: 1.57),
        StockSymbol(id: "INTC", name: "Intel Corp.", price: 42.15, priceChange: -1.25, priceChangePercent: -2.88)
    ]
    @Published private(set) var symbols: [StockSymbol] = defaultSymbols

    override init() {
        super.init()
    }
}

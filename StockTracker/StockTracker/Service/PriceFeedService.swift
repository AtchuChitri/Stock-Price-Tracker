//
//  PriceFeedService.swift
//  StockTracker
//
//  Created by Atchibabu Chitri on 16/03/26.
//

import Foundation
import Combine

final class PriceFeedService: NSObject, ObservableObject {
    static let webSocketURL = URL(string: "wss://ws.postman-echo.com/raw")!

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
    @Published private(set) var connectionStatus: ConnectionStatus = .disconnected
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private var priceUpdateTimer: Timer?
    
    override init() {
        super.init()
    }
    
    func startPriceFeed() {
        guard connectionStatus != .connected else { return }
        
        connectionStatus = .connecting
        let config = URLSessionConfiguration.default
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        webSocketTask = urlSession?.webSocketTask(with: Self.webSocketURL)
        webSocketTask?.resume()
    }
    
    func stopPriceFeed() {
        priceUpdateTimer?.invalidate()
        priceUpdateTimer = nil
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        urlSession?.invalidateAndCancel()
        urlSession = nil
        connectionStatus = .disconnected
    }
    
    private func schedulePriceUpdate() {
        priceUpdateTimer?.invalidate()
        priceUpdateTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.sendRandomPriceUpdate()
        }
        priceUpdateTimer?.tolerance = 0.5
        RunLoop.main.add(priceUpdateTimer!, forMode: .common)
    }
    
    private func sendRandomPriceUpdate() {
        let currentSymbols = symbols
        guard let randomSymbol = currentSymbols.randomElement() else { return }
        let changeAmount = Double.random(in: -5.0...5.0)
        let newPrice = max(1.0, randomSymbol.price + changeAmount)
        let changePercent = (changeAmount / randomSymbol.price) * 100
        
        let message = PriceUpdateMessage(
            symbol: randomSymbol.id,
            name: randomSymbol.name,
            price: newPrice,
            priceChange: changeAmount,
            priceChangePercent: changePercent
        )
        
        guard let jsonData = try? JSONEncoder().encode(message),
              let jsonString = String(data: jsonData, encoding: .utf8) else { return }
        
        let wsMessage = URLSessionWebSocketTask.Message.string(jsonString)
        webSocketTask?.send(wsMessage) { [weak self] error in
            if let error = error {
                print("WebSocket send error: \(error)")
                DispatchQueue.main.async {
                    self?.connectionStatus = .disconnected
                }
            }
        }
    }
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.handleReceivedMessage(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self?.handleReceivedMessage(text)
                    }
                @unknown default:
                    break
                }
                self?.receiveMessage()
            case .failure(let error):
                print("WebSocket receive error: \(error)")
                DispatchQueue.main.async {
                    self?.connectionStatus = .disconnected
                }
            }
        }
    }
    
    private func handleReceivedMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let message = try? JSONDecoder().decode(PriceUpdateMessage.self, from: data) else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let index = self.symbols.firstIndex(where: { $0.id == message.symbol }) {
                self.symbols[index] = StockSymbol(
                    id: message.symbol,
                    name: message.name,
                    price: message.price,
                    priceChange: message.priceChange,
                    priceChangePercent: message.priceChangePercent
                )
            }
        }
    }
    
    func symbol(for id: String) -> StockSymbol? {
        symbols.first { $0.id == id }
    }
}
extension PriceFeedService: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.connectionStatus = .connected
            self?.schedulePriceUpdate()
        }
        receiveMessage()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        DispatchQueue.main.async { [weak self] in
            self?.connectionStatus = .disconnected
            self?.priceUpdateTimer?.invalidate()
            self?.priceUpdateTimer = nil
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            DispatchQueue.main.async { [weak self] in
                self?.connectionStatus = .disconnected
                self?.priceUpdateTimer?.invalidate()
                self?.priceUpdateTimer = nil
            }
        }
    }
}

struct PriceUpdateMessage: Codable {
    let symbol: String
    let name: String
    let price: Double
    let priceChange: Double
    let priceChangePercent: Double
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

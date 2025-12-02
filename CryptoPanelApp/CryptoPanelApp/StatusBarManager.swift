import Foundation
import Cocoa

/// Менеджер для управления отображением цен в меню баре
class StatusBarManager: ObservableObject {
    @Published var prices: [String: String] = [:]
    
    private let binanceAPI = BinanceAPI.shared
    private var updateTimer: Timer?
    private let settingsManager = SettingsManager.shared
    
    // Маппинг символов на пары Binance (для предустановленных)
    private let symbolMap: [String: String] = [
        "BTC": "BTCUSDT",
        "ETH": "ETHUSDT",
        "SOL": "SOLUSDT",
        "BNB": "BNBUSDT",
        "ADA": "ADAUSDT",
        "XRP": "XRPUSDT",
        "DOGE": "DOGEUSDT",
        "DOT": "DOTUSDT",
        "MATIC": "MATICUSDT",
        "AVAX": "AVAXUSDT"
    ]
    
    // Получить символ для Binance API
    private func getBinanceSymbol(for ticker: String) -> String {
        // Если есть в маппинге, используем его
        if let mapped = symbolMap[ticker] {
            return mapped
        }
        // Иначе добавляем USDT к тикеру
        return "\(ticker)USDT"
    }
    
    func startUpdating() {
        updatePrices()
        // Обновляем каждые 15 секунд
        updateTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { [weak self] _ in
            self?.updatePrices()
        }
    }
    
    func stopUpdating() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func updatePrices() {
        // Получаем выбранные тикеры из настроек
        let selectedTickers = settingsManager.selectedTickers
        
        // Инициализируем цены для выбранных тикеров
        for ticker in selectedTickers {
            if prices[ticker] == nil {
                prices[ticker] = "\(ticker): --"
            }
        }
        
        // Обновляем цены для выбранных тикеров
        for ticker in selectedTickers {
            let symbol = getBinanceSymbol(for: ticker)
            
            binanceAPI.getPrice(symbol: symbol) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let price):
                        let priceValue = Double(price.price) ?? 0.0
                        let formattedPrice = self?.formatPrice(priceValue) ?? "--"
                        self?.prices[ticker] = "\(ticker): \(formattedPrice)"
                    case .failure(let error):
                        // Если тикер не найден, показываем ошибку
                        print("Ошибка получения цены для \(ticker) (\(symbol)): \(error.localizedDescription)")
                        // Оставляем "--" для несуществующих тикеров
                        if self?.prices[ticker] == nil {
                            self?.prices[ticker] = "\(ticker): --"
                        }
                    }
                }
            }
        }
    }
    
    private func formatPrice(_ price: Double) -> String {
        if price >= 1000 {
            return String(format: "$%.0f", price)
        } else if price >= 1 {
            return String(format: "$%.2f", price)
        } else {
            return String(format: "$%.4f", price)
        }
    }
    
    func getStatusBarText() -> String {
        let selectedTickers = settingsManager.selectedTickers.sorted()
        let parts = selectedTickers.compactMap { ticker -> String? in
            guard let price = prices[ticker], !price.contains("--") else { return nil }
            return price
        }
        
        if parts.isEmpty {
            // Показываем заглушки для выбранных тикеров
            return selectedTickers.map { "\($0): --" }.joined(separator: " | ")
        }
        
        return parts.joined(separator: " | ")
    }
}


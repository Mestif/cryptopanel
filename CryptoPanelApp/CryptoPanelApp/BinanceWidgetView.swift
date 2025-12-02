import SwiftUI
import Combine

/// Виджет с данными напрямую с Binance API
struct BinanceWidgetView: View {
    @ObservedObject var settingsManager = SettingsManager.shared
    @StateObject private var widgetDataManager = WidgetDataManager()
    
    var body: some View {
        HStack(spacing: 40) {
            ForEach(Array(settingsManager.selectedTickers).sorted(), id: \.self) { ticker in
                TickerView(
                    ticker: ticker,
                    price: widgetDataManager.prices[ticker]?.price ?? "--",
                    change: widgetDataManager.prices[ticker]?.changePercent ?? 0.0
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Color(red: 0.1, green: 0.1, blue: 0.1))
        .fixedSize(horizontal: false, vertical: true)
        .onAppear {
            widgetDataManager.startUpdating()
        }
        .onDisappear {
            widgetDataManager.stopUpdating()
        }
    }
}

/// Отдельный виджет для одного тикера
struct TickerView: View {
    let ticker: String
    let price: String
    let change: Double
    
    var body: some View {
        HStack(spacing: 12) {
            Text(ticker)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            
            Text(price)
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .foregroundColor(.white)
            
            Text(String(format: "%.2f%%", change))
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .foregroundColor(change >= 0 ? Color.green : Color.red)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

/// Менеджер данных для виджета (использует те же данные, что и StatusBarManager)
class WidgetDataManager: ObservableObject {
    @Published var prices: [String: TickerData] = [:]
    
    private let binanceAPI = BinanceAPI.shared
    private var updateTimer: Timer?
    private let settingsManager = SettingsManager.shared
    
    // Маппинг символов на пары Binance
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
    
    struct TickerData {
        let price: String
        let changePercent: Double
    }
    
    private func getBinanceSymbol(for ticker: String) -> String {
        if let mapped = symbolMap[ticker] {
            return mapped
        }
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
        let selectedTickers = settingsManager.selectedTickers
        
        for ticker in selectedTickers {
            let symbol = getBinanceSymbol(for: ticker)
            
            // Получаем данные 24hr ticker для получения изменения цены
            binanceAPI.getTicker24hr(symbol: symbol) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let tickerData):
                        let priceValue = Double(tickerData.lastPrice) ?? 0.0
                        let changePercent = Double(tickerData.priceChangePercent) ?? 0.0
                        let formattedPrice = self?.formatPrice(priceValue) ?? "--"
                        
                        self?.prices[ticker] = TickerData(
                            price: formattedPrice,
                            changePercent: changePercent
                        )
                    case .failure(let error):
                        print("Ошибка получения данных для \(ticker) (\(symbol)): \(error.localizedDescription)")
                        if self?.prices[ticker] == nil {
                            self?.prices[ticker] = TickerData(price: "--", changePercent: 0.0)
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
}

struct BinanceWidgetContentView: View {
    var body: some View {
        BinanceWidgetView()
            .fixedSize(horizontal: true, vertical: false)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: ContentWidthPreferenceKey.self, value: geometry.size.width)
                }
            )
            .onPreferenceChange(ContentWidthPreferenceKey.self) { width in
                // Отправляем уведомление для обновления размера popover
                NotificationCenter.default.post(
                    name: NSNotification.Name("WidgetContentWidthChanged"),
                    object: nil,
                    userInfo: ["width": width]
                )
            }
            .frame(height: 100)
            .padding(0)
    }
}

struct ContentWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 600
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

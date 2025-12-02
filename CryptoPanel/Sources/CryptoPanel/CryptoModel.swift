import Foundation

/// Модель криптовалюты для отображения в приложении
struct CryptoCurrency: Identifiable, Codable {
    let id: String
    let symbol: String
    let name: String
    let price: Double
    let priceChange24h: Double
    let priceChangePercent24h: Double
    let volume24h: Double
    let high24h: Double
    let low24h: Double
    
    init(from ticker: BinanceTicker) {
        self.id = ticker.symbol
        self.symbol = ticker.symbol.replacingOccurrences(of: "USDT", with: "")
        self.name = ticker.symbol
        
        self.price = Double(ticker.lastPrice) ?? 0.0
        self.priceChange24h = Double(ticker.priceChange) ?? 0.0
        self.priceChangePercent24h = Double(ticker.priceChangePercent) ?? 0.0
        self.volume24h = Double(ticker.volume) ?? 0.0
        self.high24h = Double(ticker.highPrice) ?? 0.0
        self.low24h = Double(ticker.lowPrice) ?? 0.0
    }
}

/// Менеджер для работы с данными криптовалют
class CryptoDataManager: ObservableObject {
    @Published var cryptocurrencies: [CryptoCurrency] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let binanceAPI = BinanceAPI.shared
    
    func fetchCryptocurrencies() {
        isLoading = true
        errorMessage = nil
        
        binanceAPI.getAllTickers { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let tickers):
                    // Фильтруем только пары с USDT и конвертируем в CryptoCurrency
                    let usdtPairs = tickers.filter { $0.symbol.hasSuffix("USDT") }
                    self?.cryptocurrencies = usdtPairs.map { CryptoCurrency(from: $0) }
                        .sorted { $0.volume24h > $1.volume24h } // Сортируем по объему
                    
                case .failure(let error):
                    self?.errorMessage = "Ошибка загрузки данных: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func refreshData() {
        fetchCryptocurrencies()
    }
}


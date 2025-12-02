import Foundation

/// API клиент для работы с Binance
class BinanceAPI {
    static let shared = BinanceAPI()
    
    private let baseURL = "https://api.binance.com/api/v3"
    
    private init() {}
    
    /// Получить список всех торговых пар с ценами
    func getAllTickers(completion: @escaping (Result<[BinanceTicker], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/ticker/24hr") else {
            completion(.failure(BinanceAPIError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(BinanceAPIError.noData))
                return
            }
            
            do {
                let tickers = try JSONDecoder().decode([BinanceTicker].self, from: data)
                completion(.success(tickers))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    /// Получить текущую цену для символа
    func getPrice(symbol: String, completion: @escaping (Result<BinancePrice, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/ticker/price?symbol=\(symbol)") else {
            completion(.failure(BinanceAPIError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Проверяем HTTP статус код
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 400 {
                    // Символ не найден на Binance
                    completion(.failure(BinanceAPIError.symbolNotFound))
                    return
                }
            }
            
            guard let data = data else {
                completion(.failure(BinanceAPIError.noData))
                return
            }
            
            do {
                let price = try JSONDecoder().decode(BinancePrice.self, from: data)
                completion(.success(price))
            } catch {
                // Если декодирование не удалось, возможно символ не существует
                if let jsonString = String(data: data, encoding: .utf8),
                   jsonString.contains("\"code\":-1121") || jsonString.contains("Invalid symbol") {
                    completion(.failure(BinanceAPIError.symbolNotFound))
                } else {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    /// Получить данные 24hr ticker для символа (включая изменение цены)
    func getTicker24hr(symbol: String, completion: @escaping (Result<BinanceTicker, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/ticker/24hr?symbol=\(symbol)") else {
            completion(.failure(BinanceAPIError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Проверяем HTTP статус код
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 400 {
                    completion(.failure(BinanceAPIError.symbolNotFound))
                    return
                }
            }
            
            guard let data = data else {
                completion(.failure(BinanceAPIError.noData))
                return
            }
            
            do {
                let ticker = try JSONDecoder().decode(BinanceTicker.self, from: data)
                completion(.success(ticker))
            } catch {
                if let jsonString = String(data: data, encoding: .utf8),
                   jsonString.contains("\"code\":-1121") || jsonString.contains("Invalid symbol") {
                    completion(.failure(BinanceAPIError.symbolNotFound))
                } else {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    /// Получить список всех доступных символов
    func getExchangeInfo(completion: @escaping (Result<BinanceExchangeInfo, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/exchangeInfo") else {
            completion(.failure(BinanceAPIError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(BinanceAPIError.noData))
                return
            }
            
            do {
                let exchangeInfo = try JSONDecoder().decode(BinanceExchangeInfo.self, from: data)
                completion(.success(exchangeInfo))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

enum BinanceAPIError: Error {
    case invalidURL
    case noData
    case decodingError
    case symbolNotFound
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .noData:
            return "Нет данных"
        case .decodingError:
            return "Ошибка декодирования"
        case .symbolNotFound:
            return "Символ не найден на Binance"
        }
    }
}

/// Модель данных для тикера Binance
struct BinanceTicker: Codable {
    let symbol: String
    let priceChange: String
    let priceChangePercent: String
    let weightedAvgPrice: String
    let prevClosePrice: String
    let lastPrice: String
    let bidPrice: String
    let askPrice: String
    let openPrice: String
    let highPrice: String
    let lowPrice: String
    let volume: String
    let quoteVolume: String
    let openTime: Int64
    let closeTime: Int64
    let count: Int64
    
    enum CodingKeys: String, CodingKey {
        case symbol
        case priceChange
        case priceChangePercent
        case weightedAvgPrice
        case prevClosePrice
        case lastPrice
        case bidPrice
        case askPrice
        case openPrice
        case highPrice
        case lowPrice
        case volume
        case quoteVolume
        case openTime
        case closeTime
        case count
    }
}

/// Модель данных для цены
struct BinancePrice: Codable {
    let symbol: String
    let price: String
}

/// Модель данных для информации о бирже
struct BinanceExchangeInfo: Codable {
    let symbols: [BinanceSymbol]
}

struct BinanceSymbol: Codable {
    let symbol: String
    let status: String
    let baseAsset: String
    let quoteAsset: String
}


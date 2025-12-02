import Foundation

// Локализация строк приложения
struct LocalizedStrings {
    // Определяем язык системы
    static var currentLanguage: String {
        return Locale.preferredLanguages.first?.prefix(2).lowercased() ?? "en"
    }
    
    // Проверяем, является ли язык русским
    static var isRussian: Bool {
        return currentLanguage == "ru"
    }
    
    // Настройки
    static var settingsTitle: String {
        return isRussian ? "Настройки тикеров" : "Ticker Settings"
    }
    
    static var addTickerManually: String {
        return isRussian ? "Добавить тикер вручную (только SPOT):" : "Add ticker manually (SPOT only):"
    }
    
    static var enterTicker: String {
        return isRussian ? "Введите тикер (например: LINK)" : "Enter ticker (e.g.: LINK)"
    }
    
    static var coreTickers: String {
        return isRussian ? "Основные тикеры:" : "Core tickers:"
    }
    
    static var customTickers: String {
        return isRussian ? "Пользовательские тикеры:" : "Custom tickers:"
    }
    
    static var quitApp: String {
        return isRussian ? "QUIT APP" : "QUIT APP"
    }
    
    static var about: String {
        return isRussian ? "ABOUT" : "ABOUT"
    }
    
    // Ошибки
    static var error: String {
        return isRussian ? "Ошибка" : "Error"
    }
    
    static func tickerAlphanumericOnly() -> String {
        return isRussian ? "Тикер может содержать только буквы и цифры" : "Ticker can only contain letters and numbers"
    }
    
    static func maxTickersReached() -> String {
        return isRussian ? "Максимум 5 тикеров могут отображаться в панели. Отключите один, чтобы добавить новый." : "Maximum 5 tickers can be displayed in the panel. Disable one to add a new one."
    }
    
    // About
    static var aboutTitle: String {
        return "CryptoPanel"
    }
    
    static var aboutVersion: String {
        return isRussian ? "Версия: 1.9.0" : "Version: 1.9.0"
    }
    
    static var aboutDescription: String {
        return isRussian ? 
            "Приложение для отслеживания криптовалют\nс использованием Binance API." :
            "Application for tracking cryptocurrencies\nusing Binance API."
    }
    
    static var aboutAuthor: String {
        return "Автор: Mestif" // Author: Mestif
    }
    
    static var aboutEmail: String {
        return "Email: Mestif@gmail.com"
    }
    
    static var aboutCopyright: String {
        return isRussian ? "© 2025 Все права защищены." : "© 2025 All rights reserved."
    }
}


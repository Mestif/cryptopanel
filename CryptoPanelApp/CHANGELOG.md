# Changelog

## Версия 1.0.0 (2024)

### Основные изменения

1. **Создан новый проект CryptoPanel**
   - Полностью переписанное приложение для macOS
   - Использует Binance API вместо CoinGecko
   - Удалены все зависимости от Firebase старого автора

2. **Интеграция Binance API**
   - Прямое получение данных с биржи Binance
   - Endpoint: `https://api.binance.com/api/v3/ticker/24hr`
   - Отображение топ-50 криптовалют по объему торгов

3. **Обновление данных автора**
   - Bundle Identifier: `com.mestif.cryptopanel` (было: `com.yonilevy.cryptoticker`)
   - Автор: Mestif (Mestif@gmail.com)
   - Удалены все ссылки на старого автора (yonilevy)

4. **Удаление старой конфигурации**
   - Удалена Firebase конфигурация (`GoogleService-Info.plist`)
   - Удалены зависимости от Firebase
   - Упрощена архитектура приложения

5. **Новый интерфейс**
   - Меню бар приложение (LSUIElement)
   - SwiftUI для отображения данных
   - Автоматическое обновление данных
   - Отображение цены, изменения за 24ч, объема торгов

### Технические детали

- **Платформа:** macOS 12.0+
- **Язык:** Swift 5.9+
- **UI Framework:** SwiftUI + AppKit
- **API:** Binance Public API (без аутентификации)

### Файлы проекта

- `AppDelegate.swift` - Главный делегат приложения
- `BinanceAPI.swift` - Клиент для работы с Binance API
- `CryptoModel.swift` - Модели данных криптовалют
- `ContentView.swift` - SwiftUI интерфейс
- `main.swift` - Точка входа приложения
- `Info.plist` - Конфигурация приложения

### Миграция с старого приложения

Старое приложение использовало:
- CoinGecko API
- Firebase для аналитики
- Bundle ID: `com.yonilevy.cryptoticker`

Новое приложение использует:
- Binance API напрямую
- Без внешних зависимостей (кроме системных)
- Bundle ID: `com.mestif.cryptopanel`


# CryptoPanel - Краткое описание

## Что было сделано

✅ **Создана копия приложения** с полностью новой архитектурой
✅ **Интегрирован Binance API** для получения данных о криптовалютах
✅ **Удалены все данные старого автора** (yonilevy, cryptoticker)
✅ **Вставлены ваши данные** (Mestif, Mestif@gmail.com, com.mestif.cryptopanel)
✅ **Удалена Firebase конфигурация** старого автора
✅ **Создан новый UI** для отображения данных с Binance

## Структура проекта

```
CryptoPanelApp/
├── CryptoPanelApp/          # Исходный код
│   ├── AppDelegate.swift    # Главный делегат (меню бар)
│   ├── BinanceAPI.swift     # API клиент Binance
│   ├── CryptoModel.swift    # Модели данных
│   ├── ContentView.swift    # SwiftUI интерфейс
│   └── main.swift           # Точка входа
├── Info.plist              # Конфигурация (ваши данные)
├── README.md               # Документация
├── BUILD_INSTRUCTIONS.md   # Инструкция по сборке
└── CHANGELOG.md            # История изменений
```

## Как собрать

1. Откройте Xcode
2. File -> New -> Project -> macOS -> App
3. Название: `CryptoPanelApp`
4. Bundle ID: `com.mestif.cryptopanel`
5. Добавьте все файлы из папки `CryptoPanelApp/` в проект
6. Замените Info.plist на файл из корня проекта
7. Соберите (⌘B) и запустите (⌘R)

Подробные инструкции в `BUILD_INSTRUCTIONS.md`

## Основные отличия от оригинала

| Параметр | Старое приложение | Новое приложение |
|----------|-------------------|------------------|
| API | CoinGecko | Binance |
| Автор | yonilevy | Mestif |
| Bundle ID | com.yonilevy.cryptoticker | com.mestif.cryptopanel |
| Firebase | Да | Нет |
| Email | - | Mestif@gmail.com |

## Контакты

**Автор:** Mestif  
**Email:** Mestif@gmail.com  
**Bundle ID:** com.mestif.cryptopanel


# Инструкция по сборке CryptoPanel

## Быстрый старт

### Вариант 1: Создание проекта в Xcode вручную

1. Откройте Xcode
2. File -> New -> Project
3. Выберите "macOS" -> "App"
4. Заполните:
   - Product Name: `CryptoPanelApp`
   - Team: (ваша команда или None)
   - Organization Identifier: `com.mestif`
   - Bundle Identifier: `com.mestif.cryptopanel`
   - Language: Swift
   - Interface: Storyboard (мы переделаем на код)
5. Нажмите Next и сохраните в папку проекта

6. **Удалите автоматически созданные файлы:**
   - `AppDelegate.swift` (если есть)
   - `ViewController.swift` (если есть)
   - `Main.storyboard` (если есть)

7. **Добавьте файлы из папки CryptoPanelApp:**
   - Перетащите все `.swift` файлы в проект
   - Убедитесь, что они добавлены в Target

8. **Настройте Info.plist:**
   - Скопируйте содержимое из `Info.plist` в проект
   - Или замените существующий файл

9. **Настройки проекта:**
   - Build Settings -> Info.plist File: `Info.plist`
   - General -> Bundle Identifier: `com.mestif.cryptopanel`
   - General -> Display Name: `CryptoPanel`

10. **Соберите проект:** ⌘B
11. **Запустите:** ⌘R

### Вариант 2: Использование Swift Package Manager

Проект также может быть собран как Swift Package:

```bash
cd CryptoPanel
swift build
swift run
```

## Структура проекта

```
CryptoPanelApp/
├── CryptoPanelApp/          # Исходный код
│   ├── AppDelegate.swift    # Главный делегат приложения
│   ├── BinanceAPI.swift     # API клиент для Binance
│   ├── CryptoModel.swift    # Модели данных
│   ├── ContentView.swift    # SwiftUI интерфейс
│   └── main.swift           # Точка входа
├── Info.plist               # Конфигурация приложения
├── README.md                # Документация
└── BUILD_INSTRUCTIONS.md    # Эта инструкция
```

## Требования

- macOS 12.0+
- Xcode 14.0+
- Swift 5.9+

## Проверка работы

После запуска приложения:
1. Проверьте меню бар (правый верхний угол)
2. Должна появиться иконка биткоина
3. Кликните на иконку - откроется панель с данными
4. Данные должны загрузиться с Binance API

## Устранение проблем

### Ошибка компиляции
- Убедитесь, что все файлы добавлены в Target
- Проверьте, что используется правильная версия Swift

### Нет данных
- Проверьте интернет-соединение
- Убедитесь, что Binance API доступен
- Проверьте консоль на ошибки

### Приложение не появляется в меню баре
- Проверьте Info.plist: `LSUIElement` должен быть `true`
- Перезапустите приложение

## Контакты

Автор: Mestif (Mestif@gmail.com)


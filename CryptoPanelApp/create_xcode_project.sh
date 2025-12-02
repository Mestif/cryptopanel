#!/bin/bash

# Скрипт для создания Xcode проекта
# Использование: ./create_xcode_project.sh

PROJECT_NAME="CryptoPanelApp"
BUNDLE_ID="com.mestif.cryptopanel"
AUTHOR="Mestif"
AUTHOR_EMAIL="Mestif@gmail.com"

echo "Создание Xcode проекта $PROJECT_NAME..."

# Создаем проект через xcodegen или создаем вручную через xcodebuild
# Для простоты создадим инструкцию

cat > XCODE_SETUP.md << EOF
# Инструкция по созданию Xcode проекта

1. Откройте Xcode
2. File -> New -> Project
3. Выберите "macOS" -> "App"
4. Название проекта: $PROJECT_NAME
5. Bundle Identifier: $BUNDLE_ID
6. Language: Swift
7. User Interface: SwiftUI (но мы используем AppKit)
8. Нажмите Next и выберите место для сохранения

После создания проекта:

1. Удалите автоматически созданные файлы (ContentView.swift, если есть)
2. Добавьте все файлы из папки CryptoPanelApp/ в проект:
   - AppDelegate.swift
   - BinanceAPI.swift
   - CryptoModel.swift
   - ContentView.swift
   - main.swift

3. В настройках проекта (Build Settings):
   - Установите "Info.plist File" на "Info.plist"
   - Убедитесь, что "Bundle Identifier" = "$BUNDLE_ID"
   - "Product Name" = "$PROJECT_NAME"

4. В Info.plist убедитесь, что:
   - CFBundleIdentifier = "$BUNDLE_ID"
   - NSPrincipalClass = "NSApplication"

5. В Build Phases -> Compile Sources добавьте все .swift файлы

6. Соберите проект (⌘B)
EOF

echo "Инструкция создана в XCODE_SETUP.md"
echo ""
echo "Или используйте команду для создания проекта через командную строку:"
echo "xcodebuild -project $PROJECT_NAME.xcodeproj -scheme $PROJECT_NAME"


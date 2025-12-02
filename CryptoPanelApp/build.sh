#!/bin/bash

# Скрипт для сборки CryptoPanel приложения

set -e

PROJECT_NAME="CryptoPanelApp"
BUNDLE_ID="com.mestif.cryptopanel"
BUILD_DIR="build"
APP_NAME="CryptoPanelApp.app"
CONTENTS_DIR="$BUILD_DIR/$APP_NAME/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "🔨 Начинаю сборку $PROJECT_NAME..."

# Создаем структуру директорий
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Компилируем Swift файлы
echo "📦 Компилирую Swift файлы..."

swiftc \
    -target arm64-apple-macosx12.0 \
    -sdk $(xcrun --show-sdk-path --sdk macosx) \
    -framework Cocoa \
    -framework SwiftUI \
    -framework WebKit \
    -framework Combine \
    -o "$MACOS_DIR/$PROJECT_NAME" \
    CryptoPanelApp/main.swift \
    CryptoPanelApp/AppDelegate.swift \
    CryptoPanelApp/BinanceAPI.swift \
    CryptoPanelApp/CryptoModel.swift \
    CryptoPanelApp/ContentView.swift \
    CryptoPanelApp/StatusBarManager.swift \
    CryptoPanelApp/BinanceWidgetView.swift \
    CryptoPanelApp/LocalizedStrings.swift \
    CryptoPanelApp/SettingsView.swift

if [ $? -ne 0 ]; then
    echo "❌ Ошибка компиляции Swift файлов"
    exit 1
fi

echo "✅ Компиляция завершена"

# Копируем Info.plist
echo "📋 Копирую Info.plist..."
cp Info.plist "$CONTENTS_DIR/"

# Копируем иконку если она существует
if [ -f "ICON.png" ]; then
    echo "🖼️  Копирую иконку ICON.png..."
    cp ICON.png "$RESOURCES_DIR/Icon.png"
elif [ -f "Icon.png" ]; then
    echo "🖼️  Копирую иконку Icon.png..."
    cp Icon.png "$RESOURCES_DIR/"
elif [ -f "CryptoPanelApp/ICON.png" ]; then
    echo "🖼️  Копирую иконку CryptoPanelApp/ICON.png..."
    cp CryptoPanelApp/ICON.png "$RESOURCES_DIR/Icon.png"
elif [ -f "CryptoPanelApp/Icon.png" ]; then
    echo "🖼️  Копирую иконку CryptoPanelApp/Icon.png..."
    cp CryptoPanelApp/Icon.png "$RESOURCES_DIR/"
else
    echo "⚠️  Иконка ICON.png или Icon.png не найдена (опционально)"
fi

# Создаем PkgInfo
echo "📄 Создаю PkgInfo..."
echo "APPL????" > "$CONTENTS_DIR/PkgInfo"

# Делаем исполняемый файл исполняемым
chmod +x "$MACOS_DIR/$PROJECT_NAME"

echo "✅ Сборка завершена успешно!"
echo "📦 Приложение находится в: $BUILD_DIR/$APP_NAME"
echo ""
echo "Для запуска выполните:"
echo "  open $BUILD_DIR/$APP_NAME"
echo ""
echo "Или запустите напрямую:"
echo "  $MACOS_DIR/$PROJECT_NAME"


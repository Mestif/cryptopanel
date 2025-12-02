# Changelog

## Version 1.9.0 (2025)

### Key Changes

1. **Fixed Recent Apps Display**
   - Changed `LSUIElement` from `true` to `false` in Info.plist
   - Added `LSBackgroundOnly` = `false`
   - Added `NSApp.setActivationPolicy(.accessory)` in AppDelegate
   - App now appears in "Recent Apps" list
   - Dock icon remains hidden (accessory policy)

2. **Added System Language Support**
   - Created `LocalizedStrings.swift` file for localization
   - Automatic system language detection
   - Support for Russian and English languages
   - All interface strings are localized:
     - Headers and labels
     - Buttons
     - Error messages
     - About window

3. **About Window Updates**
   - Added download link to GitHub Releases
   - Added "Open GitHub" button
   - Clickable download link

### Technical Details

- **Info.plist**: `LSUIElement` changed to `false`, added `LSBackgroundOnly = false`
- **AppDelegate.swift**: Added `NSApp.setActivationPolicy(.accessory)`
- **LocalizedStrings.swift**: New file for localization management
- **SettingsView.swift**: All strings replaced with localized constants
- **build.sh**: Added LocalizedStrings.swift to build

### Supported Languages

- **Russian (ru)**: Automatically detected if system is in Russian
- **English (en)**: Used by default and for all other languages

---

## Version 1.0.0 (2024)

### Key Changes

1. **Created New CryptoPanel Project**
   - Completely rewritten macOS application
   - Uses Binance API instead of CoinGecko
   - Removed all dependencies on Firebase from previous author

2. **Binance API Integration**
   - Direct data fetching from Binance exchange
   - Endpoint: `https://api.binance.com/api/v3/ticker/24hr`
   - Display of top 50 cryptocurrencies by trading volume

3. **Author Information Update**
   - Bundle Identifier: `com.mestif.cryptopanel` (was: `com.yonilevy.cryptoticker`)
   - Author: Mestif (Mestif@gmail.com)
   - Removed all references to previous author (yonilevy)

4. **Removed Old Configuration**
   - Removed Firebase configuration (`GoogleService-Info.plist`)
   - Removed Firebase dependencies
   - Simplified application architecture

5. **New Interface**
   - Menu bar application (LSUIElement)
   - SwiftUI for data display
   - Automatic data updates
   - Display of price, 24h change, trading volume

### Technical Details

- **Platform:** macOS 12.0+
- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI + AppKit
- **API:** Binance Public API (no authentication required)

### Project Files

- `AppDelegate.swift` - Main application delegate
- `BinanceAPI.swift` - Binance API client
- `CryptoModel.swift` - Cryptocurrency data models
- `ContentView.swift` - SwiftUI interface
- `main.swift` - Application entry point
- `Info.plist` - Application configuration

### Migration from Previous Application

Previous application used:
- CoinGecko API
- Firebase for analytics
- Bundle ID: `com.yonilevy.cryptoticker`

New application uses:
- Binance API directly
- No external dependencies (except system frameworks)
- Bundle ID: `com.mestif.cryptopanel`

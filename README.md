# 🚀 CryptoPanel

<div align="center">

![macOS](https://img.shields.io/badge/macOS-12.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)

**Cryptocurrency tracking app for macOS menu bar**

</div>

---

## 📋 Description

CryptoPanel is a native macOS application that displays real-time cryptocurrency prices directly in the menu bar. The app fetches data directly from the Binance exchange and automatically updates information every 30 seconds.

### ✨ Key Features

- 💰 **Price display in menu bar** — selected cryptocurrencies are displayed directly in the menu bar
- 📊 **Binance widget** — detailed information with charts on click
- ⚙️ **Flexible settings** — choose tickers to display
- 🔄 **Auto-update** — data updates every 30 seconds
- 🎨 **Minimalist design** — dark theme, compact interface

### 🎯 Supported Cryptocurrencies

BTC, ETH, SOL, BNB, ADA, XRP, DOGE, DOT, MATIC, AVAX and others (via Binance API)

---

## 📥 Download

1. Go to [Releases](https://github.com/Mestif/cryptopanel/releases)
2. Download the latest version `CryptoPanelApp.dmg` or `CryptoPanelApp.zip`
3. Open the downloaded file and drag the application to the Applications folder
4. Launch the application from Applications


---

## 🚀 Quick Start

1. **Launch the application** — it will appear in the menu bar (top right corner)
2. **Left click** on prices → open Binance widget with detailed information
3. **Right click** on prices → open settings and select tickers
4. Settings are saved automatically

---

## 📖 Documentation

### Application Controls

- **Left click** — open/close Binance widget
- **Right click** — open settings menu
- **QUIT APP** — exit the application
- **ABOUT** — version and author information

### Ticker Configuration

1. Right click on prices in the menu bar
2. Select tickers to display (at least one required)
3. Changes are applied immediately
4. Settings are saved automatically

### Binance Widget

The widget displays:
- Current price
- 24-hour change (%)
- Price chart
- Trading volume

---

## 🛠 Technical Details

### Architecture

- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI + AppKit
- **API:** Binance Public API (no authentication required)
- **Platform:** macOS 12.0+ (arm64)


### API Endpoints

The application uses Binance Public API:
- **Endpoint:** `https://api.binance.com/api/v3/ticker/24hr`
- **Documentation:** [Binance API Docs](https://binance-docs.github.io/apidocs/spot/en/#24hr-ticker-price-change-statistics)

---

## 📸 Screenshots
<img width="291" height="29" alt="CleanShot 2025-12-02 at 05 13 19" src="https://github.com/user-attachments/assets/49c262de-d785-4c00-a7eb-1b5e5447b597" />
<img width="824" height="144" alt="CleanShot 2025-12-02 at 05 14 05" src="https://github.com/user-attachments/assets/d21c336c-9c56-4550-bb93-7b94774fdbc7" />


---

## 📝 Changelog

See [CHANGELOG.md](CryptoPanelApp/CHANGELOG.md) for full version history.

### Recent Updates

- **v1.9** — Latest version 
- **v1.7** — Performance improvements
- **v1.6** — New widget features
- **v1.5** — Interface updates

---

## 👤 Author

**Mestif**

- Email: Mestif@gmail.com
- Bundle ID: com.mestif.cryptopanel

---

## ⭐ Acknowledgments

- [Binance](https://www.binance.com/) for providing the public API
- Swift community for excellent development tools

---

<div align="center">

**Made with ❤️ for macOS**

⭐ If you liked this project, give it a star!

</div>

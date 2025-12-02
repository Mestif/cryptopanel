import SwiftUI
import WebKit

/// SwiftUI обертка для WebView с виджетом Binance
struct BinanceWidgetView: NSViewRepresentable {
    @ObservedObject var settingsManager = SettingsManager.shared
    
    // Маппинг тикеров на CoinMarketCap ID
    private let cmcIdMap: [String: String] = [
        "BTC": "1",
        "ETH": "1027",
        "SOL": "5426",
        "BNB": "1839",
        "ADA": "2010",
        "XRP": "52",
        "DOGE": "5",
        "DOT": "6636",
        "MATIC": "3890",
        "AVAX": "5805",
        "LINK": "1975",
        "UNI": "7083",
        "LTC": "2",
        "ATOM": "3794",
        "ETC": "1321",
        "XLM": "512",
        "ALGO": "4030",
        "VET": "3077",
        "ICP": "8916",
        "FIL": "2280"
    ]
    
    private func getCMCIDs(for tickers: Set<String>) -> String {
        let ids = tickers.compactMap { ticker -> String? in
            return cmcIdMap[ticker.uppercased()]
        }
        // Если нет известных ID, используем BTC, ETH, SOL по умолчанию
        if ids.isEmpty {
            return "1,1027,5426"
        }
        return ids.joined(separator: ",")
    }
    
    func getHTMLString(for tickers: Set<String>) -> String {
        let cmcIds = getCMCIDs(for: tickers)
        
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                * {
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                }
                html, body {
                    margin: 0;
                    padding: 0;
                    width: 100%;
                    height: 100%;
                    background-color: #1a1a1a;
                    color: #ffffff;
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    overflow: hidden;
                }
                .binance-widget-marquee {
                    width: 100%;
                    height: 100%;
                    color: #ffffff;
                }
                .binance-widget-marquee * {
                    color: #ffffff !important;
                }
                /* Цвета для изменения цены */
                .binance-widget-marquee [class*="positive"],
                .binance-widget-marquee [class*="up"],
                .binance-widget-marquee [data-change*="+"],
                .binance-widget-marquee .positive,
                .binance-widget-marquee .up {
                    color: #00ff00 !important;
                }
                .binance-widget-marquee [class*="negative"],
                .binance-widget-marquee [class*="down"],
                .binance-widget-marquee [data-change*="-"],
                .binance-widget-marquee .negative,
                .binance-widget-marquee .down {
                    color: #ff0000 !important;
                }
                /* Стили для текста с изменениями */
                .binance-widget-marquee span:contains("+"),
                .binance-widget-marquee div:contains("+") {
                    color: #00ff00 !important;
                }
                .binance-widget-marquee span:contains("-"),
                .binance-widget-marquee div:contains("-") {
                    color: #ff0000 !important;
                }
            </style>
        </head>
        <body>
            <script src="https://public.bnbstatic.com/unpkg/growth-widget/cryptoCurrencyWidget@0.0.22.min.js"></script>
            <div class="binance-widget-marquee" 
                 data-cmc-ids="\(cmcIds)" 
                 data-theme="dark" 
                 data-transparent="true" 
                 data-locale="en" 
                 data-fiat="USD" 
                 data-layout="banner">
            </div>
        </body>
        </html>
        """
    }
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        
        // Загружаем виджет с текущими тикерами
        let htmlString = getHTMLString(for: settingsManager.selectedTickers)
        webView.loadHTMLString(htmlString, baseURL: nil)
        
        // Настраиваем обновление каждые 15 секунд
        context.coordinator.setupAutoRefresh(webView: webView, widgetView: self)
        
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        // Обновляем виджет при изменении тикеров
        let htmlString = getHTMLString(for: settingsManager.selectedTickers)
        nsView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        private var refreshTimer: Timer?
        private var getHTMLStringClosure: ((Set<String>) -> String)?
        private var getSelectedTickersClosure: (() -> Set<String>)?
        
        func setupAutoRefresh(webView: WKWebView, widgetView: BinanceWidgetView) {
            // Сохраняем замыкания для получения HTML и тикеров
            getHTMLStringClosure = { tickers in
                widgetView.getHTMLString(for: tickers)
            }
            getSelectedTickersClosure = {
                widgetView.settingsManager.selectedTickers
            }
            
            // Останавливаем предыдущий таймер если есть
            refreshTimer?.invalidate()
            
            // Обновляем виджет каждые 15 секунд
            refreshTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { [weak self, weak webView] _ in
                guard let webView = webView,
                      let getHTML = self?.getHTMLStringClosure,
                      let getTickers = self?.getSelectedTickersClosure else { return }
                let tickers = getTickers()
                let htmlString = getHTML(tickers)
                webView.loadHTMLString(htmlString, baseURL: nil)
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Виджет загружен - применяем стили для цветов
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let script = """
                (function() {
                    // Функция для применения цветов к изменениям цены
                    function applyColors() {
                        const widget = document.querySelector('.binance-widget-marquee');
                        if (!widget) return;
                        
                        // Находим все элементы с изменениями цены
                        const allElements = widget.querySelectorAll('*');
                        allElements.forEach(function(el) {
                            const text = el.textContent || '';
                            const style = window.getComputedStyle(el);
                            
                            // Проверяем на положительное изменение
                            if (text.includes('+') && (text.match(/\\+\\d/))) {
                                el.style.color = '#00ff00';
                            }
                            // Проверяем на отрицательное изменение
                            if (text.includes('-') && (text.match(/-\\d/) && !text.startsWith('-'))) {
                                el.style.color = '#ff0000';
                            }
                            
                            // Проверяем классы
                            if (el.className && (
                                el.className.includes('positive') || 
                                el.className.includes('up') ||
                                el.className.includes('gain')
                            )) {
                                el.style.color = '#00ff00';
                            }
                            
                            if (el.className && (
                                el.className.includes('negative') || 
                                el.className.includes('down') ||
                                el.className.includes('loss')
                            )) {
                                el.style.color = '#ff0000';
                            }
                        });
                    }
                    
                    // Применяем цвета сразу и периодически
                    applyColors();
                    setInterval(applyColors, 1000);
                })();
                """
                webView.evaluateJavaScript(script, completionHandler: nil)
            }
        }
        
        deinit {
            refreshTimer?.invalidate()
        }
    }
}

struct BinanceWidgetContentView: View {
    var body: some View {
        BinanceWidgetView()
            .frame(width: 800, height: 100)
            .padding(0)
    }
}


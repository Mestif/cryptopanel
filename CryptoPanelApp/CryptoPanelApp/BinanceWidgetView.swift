import SwiftUI
import WebKit

/// SwiftUI обертка для WebView с виджетом Binance
struct BinanceWidgetView: NSViewRepresentable {
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        
        // HTML с виджетом Binance
        let htmlString = """
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
                 data-cmc-ids="1,1027,5426" 
                 data-theme="dark" 
                 data-transparent="true" 
                 data-locale="en" 
                 data-fiat="USD" 
                 data-layout="banner">
            </div>
        </body>
        </html>
        """
        
        webView.loadHTMLString(htmlString, baseURL: nil)
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        // Обновление не требуется
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
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
    }
}

struct BinanceWidgetContentView: View {
    var body: some View {
        BinanceWidgetView()
            .frame(width: 800, height: 100)
            .padding(0)
    }
}


import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var statusItem: NSStatusItem?
    var widgetPopover: NSPopover?
    var settingsPopover: NSPopover?
    var statusBarManager = StatusBarManager()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Скрываем иконку из Dock, но оставляем в недавно запущенных
        NSApp.setActivationPolicy(.accessory)
        
        // Создаем статус бар
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let button = statusItem?.button else { return }
        
        // Устанавливаем начальный текст
        updateStatusBarText()
        
        // Обработка кликов мыши
        button.action = #selector(handleClick(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        
        // Начинаем обновление цен
        statusBarManager.startUpdating()
        
        // Обновляем текст в меню баре каждую секунду
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateStatusBarText()
        }
        
        // Также обновляем сразу после загрузки цен
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.updateStatusBarText()
        }
        
        // Слушаем изменения настроек
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(settingsChanged),
            name: NSNotification.Name("SettingsChanged"),
            object: nil
        )
        
        // Слушаем изменения размера виджета
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(widgetWidthChanged(_:)),
            name: NSNotification.Name("WidgetContentWidthChanged"),
            object: nil
        )
        
        // Создаем popover для виджета Binance (бегущая строка)
        widgetPopover = NSPopover()
        // Начальный размер, будет обновляться при открытии
        widgetPopover?.contentSize = NSSize(width: 600, height: 100)
        widgetPopover?.behavior = .transient
        
        let widgetView = BinanceWidgetContentView()
        widgetPopover?.contentViewController = NSHostingController(rootView: widgetView)
        
        // Создаем popover для настроек
        settingsPopover = NSPopover()
        settingsPopover?.contentSize = NSSize(width: 300, height: 500)
        settingsPopover?.behavior = .transient
        
        let settingsView = SettingsView()
        settingsPopover?.contentViewController = NSHostingController(rootView: settingsView)
    }
    
    
    @objc func handleClick(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        
        if event.type == .rightMouseUp {
            // Правая кнопка - настройки
            toggleSettingsPopover(sender)
        } else {
            // Левая кнопка - виджет
            toggleWidgetPopover(sender)
        }
    }
    
    @objc func toggleWidgetPopover(_ sender: AnyObject?) {
        if let popover = widgetPopover {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                // Закрываем настройки если открыты
                settingsPopover?.performClose(sender)
                
                // Вычисляем размер на основе количества тикеров
                let tickerCount = SettingsManager.shared.selectedTickers.count
                // Примерная ширина: ~200px на тикер + отступы
                let estimatedWidth = max(400, min(800, CGFloat(tickerCount) * 200 + 40))
                popover.contentSize = NSSize(width: estimatedWidth, height: 100)
                
                if let button = statusItem?.button {
                    popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                }
            }
        }
    }
    
    @objc func toggleSettingsPopover(_ sender: AnyObject?) {
        if let popover = settingsPopover {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                // Закрываем виджет если открыт
                widgetPopover?.performClose(sender)
                
                if let button = statusItem?.button {
                    popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                }
            }
        }
    }
    
    private func updateStatusBarText() {
        guard let button = statusItem?.button else { return }
        
        let text = statusBarManager.getStatusBarText()
        // Устанавливаем максимальную длину для меню бара (macOS может обрезать)
        // Но не ограничиваем программно - пусть macOS сам управляет
        button.title = text
        button.attributedTitle = NSAttributedString(
            string: text,
            attributes: [
                .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular),
                .foregroundColor: NSColor.labelColor
            ]
        )
        // Убираем ограничение длины - пусть текст отображается полностью
        button.appearsDisabled = false
    }
    
    @objc func settingsChanged() {
        // Перезапускаем обновление цен при изменении настроек
        statusBarManager.stopUpdating()
        statusBarManager.startUpdating()
        updateStatusBarText()
    }
    
    @objc func widgetWidthChanged(_ notification: Notification) {
        if let width = notification.userInfo?["width"] as? CGFloat,
           let popover = widgetPopover, popover.isShown {
            popover.contentSize = NSSize(width: width, height: 100)
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        statusBarManager.stopUpdating()
        NotificationCenter.default.removeObserver(self)
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}


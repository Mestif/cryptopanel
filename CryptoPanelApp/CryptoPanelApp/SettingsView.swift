import SwiftUI
import AppKit

// Кастомное текстовое поле с поддержкой Cmd+V
struct CustomTextField: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String
    
    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()
        textField.placeholderString = placeholder
        textField.delegate = context.coordinator
        // Включаем поддержку вставки
        textField.allowsEditingTextAttributes = false
        return textField
    }
    
    func updateNSView(_ nsView: NSTextField, context: Context) {
        // Обновляем только если текст изменился извне
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: CustomTextField
        
        init(_ parent: CustomTextField) {
            self.parent = parent
        }
        
        func controlTextDidChange(_ obj: Notification) {
            if let textField = obj.object as? NSTextField {
                // Автоматически преобразуем в верхний регистр
                let newValue = textField.stringValue.uppercased()
                if newValue != textField.stringValue {
                    textField.stringValue = newValue
                }
                parent.text = newValue
            }
        }
        
        // Обработка вставки через Cmd+V
        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSText.paste(_:)) {
                // Получаем текст из буфера обмена
                if let pasteboard = NSPasteboard.general.string(forType: .string) {
                    let trimmed = pasteboard.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                    if let textField = control as? NSTextField {
                        textField.stringValue = trimmed
                        parent.text = trimmed
                        return true // Обработали команду
                    }
                }
            }
            return false // Позволяем стандартную обработку
        }
    }
}

/// Настройки приложения
class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var selectedTickers: Set<String> = ["BTC", "ETH", "SOL"]
    @Published var allCustomTickers: Set<String> = [] // Все добавленные пользовательские тикеры
    
    private let coreTickers = ["BTC", "ETH", "SOL"] // Основные тикеры, которые нельзя удалить
    
    private init() {
        // Загружаем сохраненные настройки
        if let saved = UserDefaults.standard.array(forKey: "selectedTickers") as? [String] {
            selectedTickers = Set(saved)
        }
        
        // Загружаем список всех пользовательских тикеров
        if let saved = UserDefaults.standard.array(forKey: "allCustomTickers") as? [String] {
            allCustomTickers = Set(saved)
        }
        
        // Убеждаемся, что основные тикеры всегда выбраны
        for ticker in coreTickers {
            selectedTickers.insert(ticker)
        }
        
        // Убеждаемся, что хотя бы один тикер выбран
        if selectedTickers.isEmpty {
            selectedTickers = Set(coreTickers)
            save()
        }
    }
    
    func save() {
        UserDefaults.standard.set(Array(selectedTickers), forKey: "selectedTickers")
        UserDefaults.standard.set(Array(allCustomTickers), forKey: "allCustomTickers")
        // Уведомляем об изменении настроек
        NotificationCenter.default.post(name: NSNotification.Name("SettingsChanged"), object: nil)
    }
    
    func toggleTicker(_ ticker: String) {
        if selectedTickers.contains(ticker) {
            // Не позволяем убрать последний тикер
            if selectedTickers.count > 1 {
                selectedTickers.remove(ticker)
            }
        } else {
            // Проверяем ограничение на максимум 5 тикеров
            if selectedTickers.count >= 5 {
                // Не добавляем, если уже 5 тикеров
                return
            }
            selectedTickers.insert(ticker)
        }
        save()
    }
    
    func addTicker(_ ticker: String) {
        // Добавляем в список всех пользовательских тикеров
        allCustomTickers.insert(ticker)
        // Автоматически включаем его, если не превышен лимит
        if selectedTickers.count < 5 {
            selectedTickers.insert(ticker)
        }
        save()
    }
    
    func removeTicker(_ ticker: String) {
        // Нельзя удалить основные тикеры
        guard !coreTickers.contains(ticker) else { return }
        
        // Удаляем из списка всех тикеров
        allCustomTickers.remove(ticker)
        // Удаляем из выбранных
        selectedTickers.remove(ticker)
        
        // Убеждаемся, что хотя бы один тикер выбран
        if selectedTickers.isEmpty {
            selectedTickers = Set(coreTickers)
        }
        
        save()
    }
    
    func isCoreTicker(_ ticker: String) -> Bool {
        return coreTickers.contains(ticker)
    }
}

struct SettingsView: View {
    @ObservedObject private var settings = SettingsManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var newTickerInput: String = ""
    
    let coreTickers = ["BTC", "ETH", "SOL"] // Основные тикеры
    
    var body: some View {
        VStack(spacing: 20) {
            // Заголовок
            Text(LocalizedStrings.settingsTitle)
                .font(.headline)
                .fontWeight(.bold)
                .padding(.top)
            
            Divider()
            
            // Поле для ввода нового тикера
            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizedStrings.addTickerManually)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    CustomTextField(text: $newTickerInput, placeholder: LocalizedStrings.enterTicker)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            addCustomTicker()
                        }
                    
                    Button(action: {
                        addCustomTicker()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(newTickerInput.isEmpty)
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // Список тикеров
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Основные тикеры (BTC, ETH, SOL)
                    Text(LocalizedStrings.coreTickers)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.top, 4)
                    
                    ForEach(coreTickers, id: \.self) { ticker in
                        HStack {
                            Button(action: {
                                settings.toggleTicker(ticker)
                            }) {
                                Image(systemName: settings.selectedTickers.contains(ticker) ? "checkmark.square.fill" : "square")
                                    .foregroundColor(settings.selectedTickers.contains(ticker) ? .blue : .gray)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Text(ticker)
                                .font(.body)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    // Пользовательские тикеры
                    if !settings.allCustomTickers.isEmpty {
                        Divider()
                            .padding(.vertical, 8)
                        
                        Text(LocalizedStrings.customTickers)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        ForEach(Array(settings.allCustomTickers).sorted(), id: \.self) { ticker in
                            HStack {
                                // Галочка для включения/выключения
                                Button(action: {
                                    settings.toggleTicker(ticker)
                                }) {
                                    Image(systemName: settings.selectedTickers.contains(ticker) ? "checkmark.square.fill" : "square")
                                        .foregroundColor(settings.selectedTickers.contains(ticker) ? .blue : .gray)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Text(ticker)
                                    .font(.body)
                                
                                Spacer()
                                
                                // Кнопка удаления
                                Button(action: {
                                    settings.removeTicker(ticker)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            
            Divider()
            
            // Кнопки
            VStack(spacing: 12) {
                    Button(action: {
                        NSApplication.shared.terminate(nil)
                    }) {
                        HStack {
                            Image(systemName: "power")
                            Text(LocalizedStrings.quitApp)
                        }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                
                    Button(action: {
                        showAbout()
                    }) {
                        HStack {
                            Image(systemName: "info.circle")
                            Text(LocalizedStrings.about)
                        }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(width: 300, height: 550)
    }
    
    private func addCustomTicker() {
        let ticker = newTickerInput.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        guard !ticker.isEmpty else { return }
        
        // Проверяем, что тикер содержит только буквы и цифры
        let allowedCharacters = CharacterSet.alphanumerics
        guard ticker.unicodeScalars.allSatisfy({ allowedCharacters.contains($0) }) else {
            showError(LocalizedStrings.tickerAlphanumericOnly())
            return
        }
        
        // Проверяем ограничение на максимум 5 тикеров в панели
        if settings.selectedTickers.count >= 5 && !settings.selectedTickers.contains(ticker) {
            showError(LocalizedStrings.maxTickersReached())
            return
        }
        
        settings.addTicker(ticker)
        newTickerInput = ""
    }
    
    private func showError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = LocalizedStrings.error
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func showAbout() {
        let alert = NSAlert()
        alert.messageText = LocalizedStrings.aboutTitle
        
        // Загружаем иконку приложения
        // Сначала пробуем из Resources
        if let iconPath = Bundle.main.path(forResource: "Icon", ofType: "png"),
           let iconImage = NSImage(contentsOfFile: iconPath) {
            // Масштабируем иконку для окна About (128x128)
            iconImage.size = NSSize(width: 128, height: 128)
            alert.icon = iconImage
        } else if let appIcon = NSApp.applicationIconImage {
            // Используем системную иконку приложения
            let scaledIcon = appIcon.copy() as! NSImage
            scaledIcon.size = NSSize(width: 128, height: 128)
            alert.icon = scaledIcon
        }
        
        // Создаем информационный текст
        let infoText = """
        \(LocalizedStrings.aboutVersion)
        
        \(LocalizedStrings.aboutDescription)
        
        \(LocalizedStrings.aboutAuthor)
        \(LocalizedStrings.aboutEmail)
        
        \(LocalizedStrings.aboutDownload)
        \(LocalizedStrings.aboutDownloadLink)
        
        \(LocalizedStrings.aboutCopyright)
        """
        
        // Создаем NSTextView с кликабельной ссылкой
        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: 400, height: 100))
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = .clear
        
        // Создаем NSAttributedString с кликабельной ссылкой
        let attributedString = NSMutableAttributedString(string: infoText)
        let linkRange = (infoText as NSString).range(of: LocalizedStrings.aboutDownloadLink)
        if linkRange.location != NSNotFound {
            attributedString.addAttribute(.link, value: LocalizedStrings.aboutDownloadLink, range: linkRange)
            attributedString.addAttribute(.foregroundColor, value: NSColor.linkColor, range: linkRange)
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: linkRange)
        }
        
        textView.textStorage?.setAttributedString(attributedString)
        textView.textContainer?.containerSize = NSSize(width: 400, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.heightTracksTextView = false
        textView.sizeToFit()
        
        alert.informativeText = ""
        alert.accessoryView = textView
        
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: LocalizedStrings.isRussian ? "Открыть GitHub" : "Open GitHub")
        
        let response = alert.runModal()
        if response == .alertSecondButtonReturn {
            // Открываем ссылку в браузере
            if let url = URL(string: LocalizedStrings.aboutDownloadLink) {
                NSWorkspace.shared.open(url)
            }
        }
    }
}


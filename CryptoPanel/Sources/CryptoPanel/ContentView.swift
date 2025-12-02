import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = CryptoDataManager()
    
    var body: some View {
        VStack(spacing: 0) {
            // Заголовок
            HStack {
                Text("CryptoPanel")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    dataManager.refreshData()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Список криптовалют
            if dataManager.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = dataManager.errorMessage {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text(errorMessage)
                        .foregroundColor(.secondary)
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(dataManager.cryptocurrencies.prefix(50)) { crypto in
                            CryptoRowView(crypto: crypto)
                        }
                    }
                    .padding()
                }
            }
        }
        .frame(width: 400, height: 600)
        .onAppear {
            dataManager.fetchCryptocurrencies()
        }
    }
}

struct CryptoRowView: View {
    let crypto: CryptoCurrency
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(crypto.symbol)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(formatPrice(crypto.price))
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatPercent(crypto.priceChangePercent24h))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(crypto.priceChangePercent24h >= 0 ? .green : .red)
                
                Text(formatVolume(crypto.volume24h))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
    
    private func formatPrice(_ price: Double) -> String {
        if price >= 1 {
            return String(format: "$%.2f", price)
        } else {
            return String(format: "$%.6f", price)
        }
    }
    
    private func formatPercent(_ percent: Double) -> String {
        let sign = percent >= 0 ? "+" : ""
        return String(format: "\(sign)%.2f%%", percent)
    }
    
    private func formatVolume(_ volume: Double) -> String {
        if volume >= 1_000_000_000 {
            return String(format: "Vol: $%.2fB", volume / 1_000_000_000)
        } else if volume >= 1_000_000 {
            return String(format: "Vol: $%.2fM", volume / 1_000_000)
        } else {
            return String(format: "Vol: $%.2fK", volume / 1_000)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


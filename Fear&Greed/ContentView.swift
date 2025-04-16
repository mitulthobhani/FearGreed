import SwiftUI

struct FearGreedData: Codable {
    let value: String
    let value_classification: String
    let timestamp: String
}

struct HistoricalData: Codable {
    let data: [FearGreedData]
}

struct GradientProgressBar: View {
    let value: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Rectangle()
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 8)
                    .cornerRadius(4)
                
                // Full gradient bar
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(hex: "#FF3B30"), location: 0.0),    // Extreme Fear
                        .init(color: Color(hex: "#FF9500"), location: 0.25),   // Fear
                        .init(color: Color(hex: "#FFCC00"), location: 0.5),    // Neutral
                        .init(color: Color(hex: "#34C759"), location: 0.75),   // Greed
                        .init(color: Color(hex: "#30B0C7"), location: 1.0)     // Extreme Greed
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 8)
                .cornerRadius(4)
                
                // White arrow indicator
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.white)
                    .offset(x: (geometry.size.width * value / 100) - 6, y: -8)
                    .animation(.easeInOut, value: value)
            }
        }
    }
}

struct MiniChart: View {
    let data: [FearGreedData]
    @State private var selectedIndex: Int?
    
    var body: some View {
        let values = data.compactMap { Double($0.value) }
        let maxValue = values.max() ?? 100
        let minValue = values.min() ?? 0
        
        HStack(spacing: 2) {
            ForEach(data.indices, id: \.self) { index in
                if let value = Double(data[index].value) {
                    let height = ((value - minValue) / (maxValue - minValue)) * 100
                    VStack(spacing: 2) {
                        Text(data[index].value)
                            .font(.system(size: 8))
                            .foregroundColor(.white.opacity(0.6))
                        Rectangle()
                            .fill(getColorByValue(Int(value)))
                            .opacity(selectedIndex == index ? 0.4 : 0.2)
                            .frame(height: CGFloat(max(20, height)))
                            .overlay(
                                Rectangle()
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedIndex = selectedIndex == index ? nil : index
                        }
                    }
                }
            }
        }
        .frame(height: 48)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct InfoButton: View {
    @Binding var showingInfo: Bool
    
    var body: some View {
        Button(action: { showingInfo.toggle() }) {
            Image(systemName: "info.circle")
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(.white.opacity(0.4))
                .font(.system(size: 12))
        }
        .buttonStyle(.plain)
    }
}

struct HeaderView: View {
    @Binding var showingInfo: Bool
    let timeRemaining: Int
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "gauge")
                    .foregroundColor(.white.opacity(0.8))
                Text("Fear & Greed Index")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                InfoButton(showingInfo: $showingInfo)
            }
            Spacer()
            Text(String(format: "%02d:%02d", timeRemaining / 60, timeRemaining % 60))
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
        }
    }
}

struct ValueDisplay: View {
    let value: String
    let previousValue: Int?
    let classification: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .center) {
                Text(value)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                if let previousValue = previousValue {
                    let currentValue = Int(value) ?? 0
                    let change = currentValue - previousValue
                    if change != 0 {
                        HStack(spacing: 2) {
                            Image(systemName: change > 0 ? "arrow.up.right" : "arrow.down.right")
                            Text("\(abs(change))")
                        }
                        .font(.system(size: 14))
                        .foregroundColor(change > 0 ? .green : .red)
                    }
                }
            }
            Text(classification)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(getColorByValue(Int(value) ?? 0))
        }
    }
}

func getColorByValue(_ value: Int) -> Color {
    switch value {
    case 0...20: return Color(hex: "#FF3B30")  // Extreme Fear
    case 21...40: return Color(hex: "#FF9500") // Fear
    case 41...60: return Color(hex: "#FFCC00") // Neutral
    case 61...80: return Color(hex: "#34C759") // Greed
    default: return Color(hex: "#30B0C7")      // Extreme Greed
    }
}

struct ContentView: View {
    @StateObject private var viewModel = FearGreedViewModel()
    @State private var timeRemaining: Int = 1800 // 30 minutes in seconds
    @State private var showingInfo = false
    @State private var expanded = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color(red: 0.11, green: 0.11, blue: 0.12)
                .ignoresSafeArea()
            
            if let data = viewModel.data {
                VStack(spacing: 24) {
                    HeaderView(showingInfo: $showingInfo, timeRemaining: timeRemaining)
                        .popover(isPresented: $showingInfo) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Fear & Greed Index")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("Measures market sentiment from 0 (Extreme Fear) to 100 (Extreme Greed) based on:")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("• Market Volatility")
                                    Text("• Market Momentum")
                                    Text("• Social Media")
                                    Text("• Trading Volume")
                                    Text("• Bitcoin Dominance")
                                }
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            }
                            .padding()
                            .frame(width: 250)
                            .background(Color.black.opacity(0.95))
                    }
                    
                    VStack(spacing: 8) {
                        ValueDisplay(
                            value: data.value,
                            previousValue: viewModel.previousValue,
                            classification: data.value_classification
                        )
                        .padding(.bottom, 8)
                        
                        VStack(spacing: 12) {
                            GradientProgressBar(value: Double(data.value) ?? 0)
                                .frame(height: 8)
                            
                            HStack {
                                VStack(spacing: 0) {
                                    Text("Extreme")
                                        .fontWeight(.medium)
                                        .foregroundColor(Color(hex: "#FF3B30"))
                                    Text("Fear")
                                        .foregroundColor(Color(hex: "#FF3B30").opacity(0.8))
                                }
                                Spacer()
                                Text("Fear")
                                    .foregroundColor(Color(hex: "#FF9500"))
                                Spacer()
                                Text("Neutral")
                                    .foregroundColor(Color(hex: "#FFCC00"))
                                Spacer()
                                Text("Greed")
                                    .foregroundColor(Color(hex: "#34C759"))
                                Spacer()
                                VStack(spacing: 0) {
                                    Text("Extreme")
                                        .fontWeight(.medium)
                                        .foregroundColor(Color(hex: "#30B0C7"))
                                    Text("Greed")
                                        .foregroundColor(Color(hex: "#30B0C7").opacity(0.8))
                                }
                            }
                            .font(.system(size: 10))
                        }
                        
                        if expanded && !viewModel.historicalData.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Last 7 Days")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                                MiniChart(data: viewModel.historicalData)
                            }
                            .padding(.top, 16)
                        }
                    }
                }
                .padding()
                .onReceive(timer) { _ in
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                    } else {
                        timeRemaining = 1800
                    }
                }
                .onTapGesture {
                    withAnimation {
                        expanded.toggle()
                    }
                }
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
        .frame(width: 320, height: expanded ? 320 : 240)
        .animation(.spring(), value: expanded)
    }
}

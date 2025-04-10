import SwiftUI

struct FearGreedData: Codable {
    let value: String
    let value_classification: String
    let timestamp: String
}

struct Response: Codable {
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

struct ContentView: View {
    @StateObject private var viewModel = FearGreedViewModel()
    @State private var timeRemaining: Int = 1800 // 30 minutes in seconds
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    func getColorByValue(_ value: Int) -> Color {
        switch value {
        case 0...20: return Color(hex: "#FF3B30")  // Extreme Fear
        case 21...40: return Color(hex: "#FF9500") // Fear
        case 41...60: return Color(hex: "#FFCC00") // Neutral
        case 61...80: return Color(hex: "#34C759") // Greed
        default: return Color(hex: "#30B0C7")      // Extreme Greed
        }
    }
    
    func formatTimeRemaining() -> String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.11, green: 0.11, blue: 0.12) // #1C1C1E
                .ignoresSafeArea()
            
            if let data = viewModel.data {
                VStack(spacing: 24) {
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "gauge")
                                .foregroundColor(.white.opacity(0.8))
                            Text("Fear & Greed Index")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        Text(formatTimeRemaining())
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    VStack(spacing: 8) {
                        VStack(spacing: 4) {
                            Text(data.value)
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                            Text(data.value_classification)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(getColorByValue(Int(data.value) ?? 0))
                        }
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
                    }
                }
                .padding()
                .onReceive(timer) { _ in
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                    } else {
                        timeRemaining = 1800 // Reset to 30 minutes
                    }
                }
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
    }
}

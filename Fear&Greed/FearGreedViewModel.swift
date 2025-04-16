import SwiftUI

class FearGreedViewModel: ObservableObject {
    @Published var data: FearGreedData?
    @Published var historicalData: [FearGreedData] = []
    @Published var previousValue: Int?
    private var timer: Timer?
    
    init() {
        fetchData()
        timer = Timer.scheduledTimer(withTimeInterval: 1800, repeats: true) { [weak self] _ in
            self?.fetchData()
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func fetchData() {
        guard let url = URL(string: "https://api.alternative.me/fng/?limit=7") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data else { return }
            
            do {
                let response = try JSONDecoder().decode(HistoricalData.self, from: data)
                DispatchQueue.main.async {
                    if let currentValue = Int(self?.data?.value ?? "0") {
                        self?.previousValue = currentValue
                    }
                    self?.data = response.data.first
                    self?.historicalData = response.data
                }
            } catch {
                print("Decoding error:", error)
            }
        }.resume()
    }
}

import SwiftUI

class FearGreedViewModel: ObservableObject {
    @Published var data: FearGreedData?
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
        guard let url = URL(string: "https://api.alternative.me/fng/") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data else { return }
            
            do {
                let response = try JSONDecoder().decode(Response.self, from: data)
                DispatchQueue.main.async {
                    self?.data = response.data.first
                }
            } catch {
                print("Decoding error:", error)
            }
        }.resume()
    }
}

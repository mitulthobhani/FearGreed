import SwiftUI

@main
struct CryptoFearGreedWidgetApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 320, height: 240)
                .fixedSize()
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 320, height: 240)
    }
}

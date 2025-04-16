import SwiftUI

@main
struct CryptoFearGreedWidgetApp: App {
    @StateObject private var settings = SettingsManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 320, minHeight: 240)
                .environmentObject(settings)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 320, height: 240)
        .commands {
            CommandGroup(after: .appSettings) {
                Button("Settings") {
                    settings.showSettings.toggle()
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
    }
}

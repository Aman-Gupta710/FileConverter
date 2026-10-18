import SwiftUI

@main
struct FileConverterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize(CGSize(width: 600, height: 500)))
    }
}

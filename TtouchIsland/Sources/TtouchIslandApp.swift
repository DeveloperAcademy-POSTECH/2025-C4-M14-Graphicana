import SwiftUI

@main
struct RealityKitPracticeApp: App {
    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView().environment(appModel)
        }
    }
}

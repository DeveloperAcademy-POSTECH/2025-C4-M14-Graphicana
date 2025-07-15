

import SwiftUI

@main
struct TtouchIslandApp: App {
    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView().environment(appModel)
        }
    }
}

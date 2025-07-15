import SwiftUI

struct ContentView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        GameView()
    }
}

#Preview {
    ContentView()
}

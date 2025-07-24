import SwiftUI

struct ContentView: View {
    var body: some View {
        GameView()
            .overlay(alignment: .center) {
                GameStatusView()
            }
    }
}

#Preview {
    ContentView()
}

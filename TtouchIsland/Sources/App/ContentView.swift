import SwiftUI

struct ContentView: View {
    @State var manager = GameManager.shared

    var body: some View {
        // ZStack으로 한 이유: GameView가 처음부터 생성되지 않으면 RealityKit 초기화가 아예 실행되지 않는 문제가 있어서
        // (뷰 생성 타이밍과 RealityView 내부 비동기 초기화 시점이 맞물려 생기는 문제일 가능성이 높다고 함)
        ZStack {
            GameView()
                .ignoresSafeArea()
                .opacity(manager.isGameReady ? 1 : 0)
                .allowsHitTesting(manager.isGameReady)

            if !manager.isGameReady {
                LaunchView()
                    .ignoresSafeArea()
            }
        }
    }
}

import DummyAssets
import RealityKit
import SwiftUI

public struct ContentView: View {
    public init() {}

    public var body: some View {
        ZStack {
            RealityView { content in
                guard let game = try? await Entity(
                    named: "Scene", in: dummyAssetsBundle
                ) else { return }

                content.add(game)

                let cameraEntity = Entity()
                cameraEntity.components.set(PerspectiveCameraComponent())
                cameraEntity.position = [0, 100, 0]
                cameraEntity.transform.rotation = simd_quatf(angle: -.pi / 2, axis: [1, 0, 0])

                content.add(cameraEntity)
            }
        }
        .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

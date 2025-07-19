import RealityKit
import SwiftUI

/// Maintains the app-wide state.
@MainActor
@Observable
class AppModel {
    var gameRoot: Entity?
    var gameAudioRoot: Entity? {
        gameRoot?.children.first(where: { $0.name == "Root" })
    }

    // 상태바 오버레이 표시여부
    var isCharacterInteractNewspaper = false

    let isPortrait = true
    var levelFinished = false

    var metalDevice: MTLDevice? = MTLCreateSystemDefaultDevice()

    func reset() {
        gameRoot?.removeFromParent()
        gameRoot = nil
        isCharacterInteractNewspaper = false

        levelFinished = false
    }
}

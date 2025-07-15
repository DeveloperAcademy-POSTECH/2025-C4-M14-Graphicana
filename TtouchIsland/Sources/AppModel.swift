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

    var displayOverlaysVisible = false
    var collectedCoin = false
    var collectedKey = false
    let isPortrait = true
    var levelFinished = false

    var metalDevice: MTLDevice? = MTLCreateSystemDefaultDevice()

    func reset() {
        gameRoot?.removeFromParent()
        gameRoot = nil
        displayOverlaysVisible = false
        collectedCoin = false
        collectedKey = false
        levelFinished = false
    }
}

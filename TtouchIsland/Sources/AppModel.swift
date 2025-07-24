import RealityKit
import SwiftUI
import WorldCamera

@Observable
class AppModel {
    static let shared = AppModel()

    var gameRoot: Entity?
    var gameAudioRoot: Entity? {
        gameRoot?.children.first(where: { $0.name == "Root" })
    }

    var gameCamera: Entity? {
        gameRoot?.findEntity(named: "camera")
    }

    // 아이템 관련
    var nearItem: Entity?
    var isFocusedOnItem = false

    // 신문 관련
    var savedCameraState: WorldCameraComponent?

    // 상태바 오버레이 표시여부
    var displayAllItemsVisible = false

    var isGameFinished = false
    let isPortrait = true
    var levelFinished = false

    var metalDevice: MTLDevice? = MTLCreateSystemDefaultDevice()

    func reset() {
        gameRoot?.removeFromParent()
        gameRoot = nil

        displayAllItemsVisible = false

        isGameFinished = false
        levelFinished = false
    }
}

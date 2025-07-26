import RealityKit
import SwiftUI
import WorldCamera

@Observable
class GameManager {
    static let shared = GameManager()

    // MARK: - 초기 게임 세팅

    var gameRoot: Entity?
    var gameAudioRoot: Entity? {
        gameRoot?.children.first(where: { $0.name == "Root" })
    }

    var gameCamera: Entity? {
        gameRoot?.findEntity(named: "camera")
    }

    // MARK: - 아이템 시스템

    var visibleItems: [StatusItem] = []

    var nearItem: Entity?

    var isFocusedOnItem = false

    func setBackpackAvailable() {
        visibleItems = [
            StatusItem(
                solidImageName: "Backpack",
                outlinedImageName: "Backpack_Outline",
                isSolid: false
            ),
        ]
    }

    func setAllItemsAvailable() {
        visibleItems =
            [
                StatusItem(
                    solidImageName: "Backpack",
                    outlinedImageName: "Backpack_Outline",
                    isSolid: true
                ),
                StatusItem(
                    solidImageName: "Cheese",
                    outlinedImageName: "Cheese_Outline",
                    isSolid: false
                ),
                StatusItem(
                    solidImageName: "Bottle",
                    outlinedImageName: "Bottle_Outline",
                    isSolid: false
                ),
                StatusItem(
                    solidImageName: "Flashlight",
                    outlinedImageName: "Flashlight_Outline",
                    isSolid: false
                ),
                StatusItem(
                    solidImageName: "Map",
                    outlinedImageName: "Map_Outline",
                    isSolid: false
                ),
            ]
    }

    // MARK: - 카메라 시점 이동

    var savedCameraState: WorldCameraComponent?

    var isGameFinished = false
    let isPortrait = true
    var levelFinished = false

    var metalDevice: MTLDevice? = MTLCreateSystemDefaultDevice()

    func reset() {
        gameRoot?.removeFromParent()
        gameRoot = nil

        visibleItems = []

        isGameFinished = false
        levelFinished = false
    }
}

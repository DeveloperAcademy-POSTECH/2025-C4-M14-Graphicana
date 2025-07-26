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

    // MARK: - 아이템 상태 변수

    var visibleItems: [StatusItem] = []

    var nearItem: Entity?

    var isFocusedOnItem = false

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

// MARK: - 아이템 관리 메소드

extension GameManager {
    func setBackpackAvailable() {
        if visibleItems.count == 0 {
            visibleItems = [
                StatusItem(
                    solidImageName: "Backpack",
                    outlinedImageName: "Backpack_Outline",
                    isSolid: false
                ),
            ]
        } else {
            print("⚠️ Warning: Backpack is already available.")
        }
    }

    func setAllItemsAvailable() {
        if visibleItems.count == 1 {
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
                        outlinedImageName: "Mystery_Outline",
                        isSolid: false
                    ),
                ]
        } else {
            print("⚠️ Warning: You need to activate the Backpack first.")
        }
    }

    func setMapCompassAvailable() {
        if visibleItems.count == 5, visibleItems[4].outlinedImageName == "Mystery_Outline" {
            visibleItems[3].isSolid = true
            visibleItems[4] = StatusItem(
                solidImageName: "Map",
                outlinedImageName: "Map_Outline",
                isSolid: false
            )
        } else {
            print("⚠️ Warning: MapCompass is not available yet.")
        }
    }
}

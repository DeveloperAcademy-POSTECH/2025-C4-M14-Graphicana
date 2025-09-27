import RealityKit
import SwiftUI

// 단순 기능 모음이고 인스턴스 생성 가능성을 완전히 차단할 수 있어서 enum으로
enum AudioManager {
    // 왜 static이냐? 인스턴스를 안 만들어도 직접 호출할 수 있어야 해서

    // ChannelAudio(포지션, 디렉션x)
    static func setupBackgroundAudio(
        root: Entity,
        content: some RealityViewContentProtocol  // realityKit 씬을 구성하고 연결하는 역할의 프로토콜(?)
    ) {
        // 오디오를 적용할 엔티티를 찾는다
        if let background = root.findEntity(named: "EnvironmentMap"),
            let audioLibrary = background.components[
                AudioLibraryComponent.self
            ],
            // AudioLibraryComponent(리컴포에서 추가할 수 있음)에서 backgroundAudio라는 리소스(.wav,.mp3 파일을 메모리에 올린 객체)를 가져온다
            let backgroundAudio = audioLibrary.resources["newbackgroundAudio"]
        {
            // 가져온 오디오 리소스를 해당 엔티티에서 재생한다
            background.playAudio(backgroundAudio)
        }
    }

    // ChannelAudio(포지션, 디렉션x)
    static func playJumpAudio(
        root: Entity
    ) {
        if let character = root.findEntity(named: "Ttouch"),
            let audioLibrary = character.components[
                AudioLibraryComponent.self
            ],
            let jumpAudio = audioLibrary.resources["jumpAudio"]
        {
            character.playAudio(jumpAudio)
        }
    }

    // ChannelAudio(포지션, 디렉션x)
    static func playGetItemAudio(root: Entity) {
        if let item = root.findEntity(named: "ItemAudio"),
            let audioLibrary = item.components[
                AudioLibraryComponent.self
            ],
            let itemAudio = audioLibrary.resources["itemAudio"]
        {
            item.playAudio(itemAudio)
        }
    }

    // SpatialAudio(포지션, 디렉션 O)
    static func playOceanAudio(
        root: Entity,
        content: some RealityViewContentProtocol
    ) {
        if let ocean1 = root.findEntity(named: "OceanSpatialAudio1"),
            let audioLibrary = ocean1.components[
                AudioLibraryComponent.self
            ],
            let oceanAudio = audioLibrary.resources["oceanAudio"]
        {
            ocean1.playAudio(oceanAudio)
        }

        if let ocean2 = root.findEntity(named: "OceanSpatialAudio2"),
            let audioLibrary = ocean2.components[
                AudioLibraryComponent.self
            ],
            let oceanAudio = audioLibrary.resources["oceanAudio"]
        {
            ocean2.playAudio(oceanAudio)
        }

    }

    // SpatialAudio(포지션, 디렉션 O)
    static func playForestAudio(
        root: Entity,
        content: some RealityViewContentProtocol
    ) {
        if let forest = root.findEntity(named: "ForestSpatialAudio"),
            let audioLibrary = forest.components[
                AudioLibraryComponent.self
            ],
            let forestAudio = audioLibrary.resources["forestAudio"]
        {
            forest.playAudio(forestAudio)
        }

    }
}

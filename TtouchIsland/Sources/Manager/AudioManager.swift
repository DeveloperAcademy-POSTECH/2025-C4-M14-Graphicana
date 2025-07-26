import RealityKit
import SwiftUI

// 단순 기능 모음이고 인스턴스 생성 가능성을 완전히 차단할 수 있어서 enum으로
enum AudioManager {
    // 왜 static이냐? 인스턴스를 안 만들어도 직접 호출할 수 있어야 해서
    static func setupBackgroundMusic(
        root: Entity,
        content: some RealityViewContentProtocol  // realityKit 씬을 구성하고 연결하는 역할의 프로토콜(?)
    ) {
        // TtouchParent를 사운드의 재생 위치로 할거다~
        if let background = root.findEntity(named: "EnvironmentMap") {
            Task {
                // background.wav 파일을 가져와서 realitykit에서 사용할 수 있게함(비동기)
                let backgroundMusic = try! await AudioFileResource(
                    // AudioFileResource: RealityKit에서 외부에서 가져온 오디오파일을 사용할수있게 해주는 객체(.wav, .mp3 파일을 취급)
                    named: "backgroundMusic.wav",
                    configuration: AudioFileResource.Configuration(
                        // 끝나면 자동으로 반복 재생 true
                        shouldLoop: true,
                    )
                )
                // background 엔티티에서 backgroundMusic를 재생
                await background.playAudio(backgroundMusic)
            }
        }
    }

    static func playJumpSound(
        root: Entity
    ) {
        // Ttouch를 재생위치로 설정
        if let ttouchJumpSound = root.findEntity(named: "Ttouch") {
            Task {
                // jump.wav 파일을 가져와서 AudioFileResource을 통해 realitykit에서 사용할 수 있게함
                let jumpSound = try! await AudioFileResource(
                    named: "jump.wav",
                    configuration: AudioFileResource.Configuration(
                        // 일회성 재생
                        shouldLoop: false,
                    )
                )
                // ttouchJumpSound에서 jumpSound를 재생
                await ttouchJumpSound.playAudio(jumpSound)
            }
        }
    }

    static func playGetItemSound(root: Entity) {
        // TO DO: 추후에 구현 예정~
    }
}

import RealityKit
import SwiftUI

extension GameView {
    func setupBackgroundMusic(
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
                background.playAudio(backgroundMusic)
            }
        }
    }
}

import CharacterMovement
import DummyAssets
import RealityKit
import SwiftUI
import ThumbStickView
import WorldCamera

struct GameView: View {
    @State var appModel = AppModel.shared

    var character: Entity? {
        appModel.gameRoot?.findEntity(named: "Ttouch")
    }

    @State var showJoystick: Bool = false
    @State var isViewingNewspaper: Bool = false

    // 1. 애니메이션 컨트롤러를 저장할 State 변수 추가
    @State private var activeAnimation: AnimationPlaybackController?

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            RealityView { content in
                guard
                    let game = try? await Entity(
                        named: "Scene",
                        in: dummyAssetsBundle
                    )
                else { return }

                appModel.gameRoot = game

                await initializeGameSetting(game, content)
                content.add(game)

                showJoystick = true
            }
            .ignoresSafeArea()

            if showJoystick {
                PlatformerThumbControl(
                    character: character,
                    isViewingNewspaper: $isViewingNewspaper,
                    newspaperAction: { newspaper, camera in
                        // 현재 신문 보기 모드인지에 따라 다른 함수를 호출
                        if isViewingNewspaper {
                            try? returnToPlayerView(camera: camera)
                            //                            try? stopCameraLockAction(camera: camera)

                        } else {
                            try? closeupNewspaper(
                                newspaper: newspaper,
                                camera: camera
                            )
                            //                            try? triggerCameraLockAction(newspaper: newspaper, camera: camera)
                        }
                    }
                )
            }
        }
        .allowedDynamicRange(.high)
    }

    // MARK: - Game Initialization

    fileprivate func initializeGameSetting(
        _ game: Entity,
        _ content: some RealityViewContentProtocol
    ) async {
        if let character {
            setupWorldCamera(target: character)
            await characterSetup(character)
        }

        // 배경음 삽입
        AudioManager.setupBackgroundMusic(root: game, content: content)

        // TODO: - 환경 충돌 설정
        await setupEnvironmentCollisions(on: game, content: content)

        if let newspaper = game.findEntity(named: "NewsPaper"), let character {
            setupItems(
                character: character,
                newspaper: newspaper,
                content: content
            )
        }
    }

    fileprivate struct PlatformerThumbControl: View {
        let character: Entity?
        @Binding var isViewingNewspaper: Bool
        let newspaperAction: (_ newspaper: Entity, _ camera: Entity) -> Void

        var appModel = AppModel.shared

        @State var characterJoystick: CGPoint = .zero
        @State var cameraAngleThumbstick: CGPoint = .zero

        var body: some View {
            VStack {
                if isViewingNewspaper {
                    HStack {
                        Spacer()

                        Button(action: {
                            // 뒤로가기 액션 호출
                            if let newspaper = appModel.nearItem,
                                let camera = appModel.gameCamera
                            {
                                newspaperAction(newspaper, camera)
                                isViewingNewspaper.toggle()
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .frame(width: 50, height: 50)
                                .font(.system(size: 36))
                                .glassEffect(.regular.interactive())
                        }
                        .padding()
                    }
                }

                Spacer()

                if !isViewingNewspaper {
                    HStack(alignment: .bottom) {
                        ThumbStickView(updatingValue: $characterJoystick)
                            .onChange(of: characterJoystick) { _, newValue in
                                let movementVector: SIMD3<Float> =
                                    [Float(newValue.x), 0, Float(newValue.y)]
                                    / 10
                                character?.components[
                                    CharacterMovementComponent.self
                                ]?.controllerDirection = movementVector
                            }

                        Spacer()

                        ZStack(alignment: .bottomTrailing) {
                            CameraThumbStickView(
                                updatingValue: $cameraAngleThumbstick
                            )
                            .onChange(of: cameraAngleThumbstick) {
                                _,
                                newValue in
                                let movementVector: SIMD2<Float> =
                                    [Float(newValue.x), Float(-newValue.y)] / 30

                                appModel.gameRoot?.findEntity(named: "camera")?
                                    .components[WorldCameraComponent.self]?
                                    .updateWith(
                                        continuousMotion: movementVector
                                    )
                            }
                            .background(Color.clear)

                            HStack {
                                if appModel.nearItem != nil {
                                    Button {
                                        if let newspaper = appModel.nearItem,
                                            let camera = appModel.gameCamera
                                        {
                                            newspaperAction(newspaper, camera)
                                            isViewingNewspaper.toggle()
                                        }

                                    } label: {
                                        Image(systemName: "newspaper")
                                            .frame(width: 50, height: 50)
                                            .font(.system(size: 36))
                                            .glassEffect(.regular.interactive())
                                    }
                                    .padding(.trailing, 16)
                                }

                                // Jump button.
                                Image(systemName: "arrow.up")
                                    .frame(width: 70, height: 70)
                                    .font(.system(size: 36))
                                    .glassEffect(.regular.interactive())
                                    .onLongPressGesture(
                                        minimumDuration: 0.0,
                                        perform: {},
                                        onPressingChanged: { isPressed in
                                            character?.components[
                                                CharacterMovementComponent.self
                                            ]?.jumpPressed = isPressed
                                            AudioManager.playJumpSound(
                                                root: character!
                                            )
                                        }
                                    )
                            }
                            .padding()
                        }
                    }
                    .padding(.bottom, 60)
                }
            }
        }
    }
}

#Preview {
    GameView()
}

import CharacterMovement
import DummyAssets
import RealityKit
import SwiftUI
import ThumbStickView
import WorldCamera

struct GameView: View {
    private var appModel: AppModel = .shared

    var character: Entity? {
        appModel.gameRoot?.findEntity(named: "Ttouch_walk")
    }

    @State var showJoystick: Bool = false

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
                PlatformerThumbControl(character: character, appModel: appModel)
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
        setupBackgroundMusic(root: game, content: content)

        // TODO: - 환경 충돌 설정
        await setupEnvironmentCollisions(on: game, content: content)

        if let newspaper = game.findEntity(named: "NewsPaper"), let character {
            setupItems(character: character, newspaper: newspaper, content: content)
        }
    }

    fileprivate struct PlatformerThumbControl: View {
        let character: Entity?
        let appModel: AppModel

        @State var characterJoystick: CGPoint = .zero
        @State var cameraAngleThumbstick: CGPoint = .zero

        var body: some View {
            VStack {
                Spacer()

                HStack(alignment: .bottom) {
                    ThumbStickView(updatingValue: $characterJoystick)
                        .onChange(of: characterJoystick) { _, newValue in
                            let movementVector: SIMD3<Float> =
                                [Float(newValue.x), 0, Float(newValue.y)] / 10
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
                            if appModel.isNearNewspaper {
                                Button(action: {
                                    // 신문 버튼 액션
                                }) {
                                    Image(systemName: "newspaper")
                                        .frame(width: 50, height: 50)
                                        .font(.system(size: 36))
                                        .glassEffect(.regular.interactive())
                                }
                                .padding(.trailing, 16)
                            }

                            // Jump button.
                            Image(systemName: "arrow.up")
                                .frame(width: 50, height: 50)
                                .font(.system(size: 36))
                                .glassEffect(.regular.interactive())
                                .onLongPressGesture(
                                    minimumDuration: 0.0,
                                    perform: {},
                                    onPressingChanged: { isPressed in
                                        character?.components[
                                            CharacterMovementComponent.self
                                        ]?.jumpPressed = isPressed
                                    }
                                )
                        }
                        .padding()
                    }
                }
                .padding(.bottom, 30)
            }
        }
    }
}

#Preview {
    GameView()
}

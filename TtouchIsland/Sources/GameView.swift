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

    @State var showInterface: Bool = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            RealityView { content in

                guard
                    let game: Entity = try? await Entity(
                        named: "Scene",
                        in: dummyAssetsBundle
                    )
                else { return }

                appModel.gameRoot = game

                await initializeGameSetting(game, content)
                content.add(game)

                showInterface = true
            }
            .ignoresSafeArea()
            .zIndex(0)

            if showInterface {
                if !appModel.isFocusedOnItem {
                    GameStatusView()
                        .padding(.top, 26)
                } else { GameStatusView() }

                PlatformerThumbControl(
                    appModel: appModel,
                    character: character,
                    itemAction: { item, camera in
                        if item.components[ItemComponent.self]?.type == .newspaper {
                            print("📰")
                            handleNewspaperItem(item: item, camera: camera)
                        }
                        if item.components[ItemComponent.self]?.type == .cheese {
                            print("🧀")
                        }
                        if item.components[ItemComponent.self]?.type == .bottle {
                            print("🍶")
                        }
                        if item.components[ItemComponent.self]?.type == .flashlight {
                            print("🔦")
                        }
                        if item.components[ItemComponent.self]?.type == .mapCompass {
                            print("🗺️")
                        }
                        if item.components[ItemComponent.self]?.type == .backpack {
                            print("🎒")
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

        if let character,
           let newspaper = game.findEntity(named: "NewsPaper"),
           let backpack = game.findEntity(named: "Backpack"),
           let cheese = game.findEntity(named: "Cheese"),
           let bottle = game.findEntity(named: "Bottle"),
           let flashlight = game.findEntity(named: "Flashlight"),
           let mapCompass = game.findEntity(named: "MapCompass")
        {
            setupItems(
                character: character,
                newspaper: newspaper,
                backpack: backpack,
                cheese: cheese,
                bottle: bottle,
                flashlight: flashlight,
                mapCompass: mapCompass,
                content: content
            )
        }
    }

    fileprivate struct PlatformerThumbControl: View {
        let appModel: AppModel
        let character: Entity?
        let itemAction: (_ item: Entity, _ camera: Entity) -> Void

        @State var characterJoystick: CGPoint = .zero
        @State var cameraAngleThumbstick: CGPoint = .zero

        var body: some View {
            VStack {
                if appModel.isFocusedOnItem {
                    HStack {
                        Spacer()

                        Button(action: {
                            // 뒤로가기 액션 호출
                            if let item = appModel.nearItem,
                               let camera = appModel.gameCamera
                            {
                                itemAction(item, camera)
                            }
                        }) {
                            Image(systemName: "xmark")
                                .frame(width: 50, height: 50)
                                .foregroundColor(.black)
                                .font(.system(size: 36))
                                .glassEffect(.regular.interactive())
                        }
                        .padding()
                    }
                }

                Spacer()

                if !appModel.isFocusedOnItem {
                    HStack(alignment: .bottom) {
                        ThumbStickView(updatingValue: $characterJoystick)
                            .onChange(of: characterJoystick) { _, newValue in
                                let movementVector: SIMD3<Float> =
                                    [Float(newValue.x), 0, Float(newValue.y)] / 10
                                character?
                                    .components[CharacterMovementComponent.self]?
                                    .controllerDirection = movementVector
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
                                    .updateWith(continuousMotion: movementVector)
                            }
                            .background(Color.clear)

                            HStack {
                                if appModel.nearItem != nil {
                                    Button {
                                        if let item = appModel.nearItem,
                                           let camera = appModel.gameCamera
                                        {
                                            itemAction(item, camera)
                                        }

                                    } label: {
                                        Image(systemName: "eye.fill")
                                            .frame(width: 70, height: 70)
                                            .font(.system(size: 36))
                                            .glassEffect(.regular.interactive())
                                    }
                                    .padding(.trailing, 16)
                                }

                                // Jump button.
                                ZStack {
                                    // 배경
                                    Color.clear
                                        .frame(width: 70, height: 70)
                                        .glassEffect(.regular.interactive())

                                    // 이미지
                                    Image("JumpIcon")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50) // 이미지 크기 조정
                                }
                                .onLongPressGesture(
                                    minimumDuration: 0.0,
                                    perform: {},
                                    onPressingChanged: { isPressed in
                                        character?
                                            .components[CharacterMovementComponent.self]?
                                            .jumpPressed = isPressed
                                        AudioManager.playJumpSound(
                                            root: character!
                                        )
                                    }
                                )
                            }
                            .padding()
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        }
    }
}

#Preview {
    GameView()
}

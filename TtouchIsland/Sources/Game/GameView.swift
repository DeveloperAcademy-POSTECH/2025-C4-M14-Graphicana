import CharacterMovement
import DummyAssets
import RealityKit
import SwiftUI
import ThumbStickView
import WorldCamera

struct GameView: View {
    @State var manager = GameManager.shared

    @State private var currentScale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    var character: Entity? {
        manager.gameRoot?.findEntity(named: "Ttouch")
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

                manager.gameRoot = game

                await initializeGameSetting(game, content)
                content.add(game)

                showInterface = true
            }
            .ignoresSafeArea()
            .zIndex(0)

            if showInterface {
                if !manager.isFocusedOnItem {
                    GameStatusView()
                        .padding(.top, 26)
                } else {
                    GameStatusView()
                }

                PlatformerThumbControl(
                    appModel: manager,
                    character: character,
                    itemAction: { item, camera in
                        if item.components[ItemComponent.self]?.type
                            == .newspaper
                        {
                            print("📰")
                            handleNewspaperItem(item: item, camera: camera)
                        }
                        if item.components[ItemComponent.self]?.type
                            == .backpack
                        {
                            print("🎒")
                            manager.setAllItemsAvailable()
                        }
                        if item.components[ItemComponent.self]?.type == .cheese
                        {
                            print("🧀")
                        }
                        if item.components[ItemComponent.self]?.type == .bottle
                        {
                            print("🍶")
                        }
                        if item.components[ItemComponent.self]?.type
                            == .flashlight
                        {
                            print("🔦")
                            manager.setMapCompassAvailable()
                        }
                        if item.components[ItemComponent.self]?.type
                            == .mapCompass
                        {
                            print("🗺️")
                        }
                    }
                )
                .zIndex(1)
            }
        }
        .gesture(
            // 핀치 인아웃(두 손가락 벌리기, 오므리기) 제스처를 감지
            MagnificationGesture()
                .onChanged { newValue in
                    // 얼마나 크기가 변했는지 비율 계산
                    let delta = newValue / lastScale
                    // 다음을 위해.. 업뎃
                    lastScale = newValue
                    cameraZoomInOut(delta: Float(delta))
                }
                // 제스처가 끝났을 때 호출
                .onEnded { _ in
                    // 핀치 제스처는 newValue 값을 1.0을 기준으로 연속적으로 누적된 배율을 전달하기 때문에..
                    // 그래서 매번 delta = scale / lastScale 으로 계산해 변화량만 반영하고 그 다음 lastScale을 업데이트헤야함
                    // 제스처가 끝났을 때 lastScale을 1.0으로 초기화, 이는 다음 핀치 제스처가 시작될 때 올바른 delta 계산을 위해 필요
                    // 한마디로.. 누적 안되게 초기화
                    lastScale = 1.0
                }

        )
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
        let appModel: GameManager
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
                                .frame(width: 36, height: 36)
                                .foregroundColor(.black)
                                .font(.system(size: 24))
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
                                    [Float(newValue.x), 0, Float(newValue.y)]
                                    / 10
                                character?
                                    .components[
                                        CharacterMovementComponent.self
                                    ]?
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
                                    .updateWith(
                                        continuousMotion: movementVector
                                    )
                            }
                            .background(Color.clear)

                            HStack {
                                if appModel.nearItem != nil {
                                    Button {
                                        if let item = appModel.nearItem,
                                            let camera = appModel.gameCamera,
                                            let character = character
                                        {
                                            itemAction(item, camera)
                                            AudioManager.playGetItemSound(
                                                root: character
                                            )
                                        }

                                    } label: {
                                        ActionButton(name: "GetIcon")
                                    }
                                    .padding(.trailing, 16)
                                }

                                // Jump button.
                                ActionButton(name: "JumpIcon")
                                    .onLongPressGesture(
                                        minimumDuration: 0.0,
                                        pressing: { isPressed in
                                            character?.components[
                                                CharacterMovementComponent.self
                                            ]?.jumpPressed = isPressed
                                            AudioManager.playJumpSound(
                                                root: character!
                                            )
                                        },
                                        perform: {}
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

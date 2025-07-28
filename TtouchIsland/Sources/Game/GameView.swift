import CharacterMovement
import DummyAssets
import RealityKit
import SwiftUI
import ThumbStickView
import WorldCamera

struct GameView: View {
    @State var manager = GameManager.shared

    // realityview를 완전히 다시 시작하기 위한 트리거
    @State private var gameId = UUID()

    @State private var currentScale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    var character: Entity? {
        manager.gameRoot?.findEntity(named: "Ttouch")
    }

    @State private var showResetAlert = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            RealityView { content in
                guard
                    let game: Entity = try? await Entity(
                        named: "Scene2",
                        in: dummyAssetsBundle
                    )
                else { return }

                manager.gameRoot = game

                await initializeGameSetting(game, content)
                content.add(game)
                print("게임 세팅 완료")

                DispatchQueue.main.async { manager.isGameReady = true }

                playItemAnimations(game: game)
                manager.showInterface = true
            }
            .ignoresSafeArea()
            .zIndex(0)
            // id가 변경되면 뷰를 새로 그림
            .id(gameId)

            if manager.showInterface {
                if !manager.isFocusedOnItem {
                    GameStatusView()
                        .padding(.top, 26)
                } else {
                    GameStatusView()
                }

                PlatformerThumbControl(
                    manager: manager,
                    character: character,
                    itemAction: { item, camera in
                        if item.components[ItemComponent.self]?.type
                            == .newspaper
                        {
                            print("📰")
                            handleNewspaperItem(item: item, camera: camera)
                        }
                        if manager.visibleItems.count == 1 {
                            if item.components[ItemComponent.self]?.type
                                == .backpack
                            {
                                print("🎒")

                                // 땃쥐 행복해하는 로티 애니메이션 플레이
                                manager.updateStatus(to: .getItem)

                                manager.visibleItems[0].isSolid = true
                                manager.setAllItemsAvailable()
                                item.removeFromParent()
                                manager.nearItem = nil
                            }
                        }
                        if manager.visibleItems.count > 1 {
                            if item.components[ItemComponent.self]?.type
                                == .cheese
                            {
                                print("🧀")

                                // 땃쥐 행복해하는 로티 애니메이션 플레이
                                manager.updateStatus(to: .getItem)

                                Task { await setCharacterScaleUp() }
                                manager.visibleItems[1].isSolid = true
                                item.removeFromParent()
                                manager.nearItem = nil
                            }
                            if item.components[ItemComponent.self]?.type
                                == .bottle
                            {
                                print("🍶")

                                // 땃쥐 행복해하는 로티 애니메이션 플레이
                                manager.updateStatus(to: .getItem)

                                manager.visibleItems[2].isSolid = true
                                item.removeFromParent()
                                manager.nearItem = nil
                            }
                            if item.components[ItemComponent.self]?.type
                                == .flashlight
                            {
                                print("🔦")

                                // 땃쥐 행복해하는 로티 애니메이션 플레이
                                manager.updateStatus(to: .getItem)

                                manager.visibleItems[3].isSolid = true
                                manager.setMapCompassAvailable()
                                item.removeFromParent()
                                manager.nearItem = nil
                            }
                        }
                        if manager.visibleItems.last?.outlinedImageName
                            == "Map_Outline"
                        {
                            if item.components[ItemComponent.self]?.type
                                == .mapCompass
                            {
                                print("🗺️")

                                // 땃쥐 행복해하는 로티 애니메이션 플레이
                                manager.updateStatus(to: .getItem)

                                manager.visibleItems[4].isSolid = true
                                item.removeFromParent()
                                manager.nearItem = nil
                            }
                        }
                    }
                )
                .zIndex(1)
            }
            // 초기화 버튼
            // TO DO: UI 변경
            VStack {
                HStack {
                    Spacer()
                    Button("Reset") {
                        showResetAlert = true
                    }
                }.padding(.top, 50)
                Spacer()
                // 우선순위 위로!
            }.zIndex(2)

            if manager.showEndCredits {
                VStack {
                    Text("end credits")
                    Button("처음부터 시작") {
                        manager.isGameReady = false
                        manager.resetGame()
                        manager.showInterface = false
                        gameId = UUID()
                    }
                }
            }
        }
        .alert("게임 리셋", isPresented: $showResetAlert) {
            Button("취소", role: .cancel) {}
            Button("네", role: .confirm) {
                manager.isGameReady = false
                manager.resetGame()
                manager.showInterface = false
                // 새로운 게임 아이디를 설정해줘서 realityview를 다시 그리게 한다
                gameId = UUID()
            }
        } message: {
            Text("게임을 다시 시작하시겠습니까?")
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
            let backpack = game.findEntity(named: "Backpack_Anim"),
            let cheese = game.findEntity(named: "Cheese_Anim"),
            let bottle = game.findEntity(named: "Bottle_Anim"),
            let flashlight = game.findEntity(named: "Flashlight_Anim"),
            let mapCompass = game.findEntity(named: "MapCompass_Anim")
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
        let manager: GameManager
        let character: Entity?
        let itemAction: (_ item: Entity, _ camera: Entity) -> Void

        @State var characterJoystick: CGPoint = .zero
        @State var cameraAngleThumbstick: CGPoint = .zero

        var body: some View {
            VStack {
                if manager.isFocusedOnItem {
                    HStack {
                        Spacer()

                        Button(action: {
                            // 뒤로가기 액션 호출
                            if let item = manager.nearItem,
                                let camera = manager.gameCamera
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

                if !manager.isFocusedOnItem {
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

                                manager.gameRoot?.findEntity(named: "camera")?
                                    .components[WorldCameraComponent.self]?
                                    .updateWith(
                                        continuousMotion: movementVector
                                    )
                            }
                            .background(Color.clear)

                            HStack {
                                if manager.nearItem != nil {
                                    Button {
                                        if let item = manager.nearItem,
                                            let camera = manager.gameCamera,
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
                                            manager.updateStatus(to: .jump)
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
//
//#Preview {
//    GameView()
//}


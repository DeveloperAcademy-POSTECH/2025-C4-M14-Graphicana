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

    @State private var showResetAlert = false
    @State private var showRestartButton = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            RealityView { content in
                guard
                    let game: Entity = try? await Entity(
                        named: "Scene",
                        in: dummyAssetsBundle
                    )
                else {
                    print("‼️ 에셋 로드 실패: Scene")
                    return
                }

                manager.gameRoot = game

                await initializeGameSetting(game, content)
                content.add(game)

                print("게임 세팅 완료")

                DispatchQueue.main.async { manager.isGameReady = true }

                playItemAnimations(game: game)
                manager.showInterface = true
            }
            .id(gameId)

            if manager.showOnboarding {
                OnboardingView()
                    .zIndex(3)
            }

            if manager.showInterface {
                JoystickButtonView(
                    manager: manager,
                    itemAction: { item, camera in
                        if item.components[ItemComponent.self]?.type
                            == .newspaper
                        {
                            print("📰")
                            ItemManager().handleNewspaperItem(
                                item: item,
                                camera: camera
                            )
                        } else if manager.visibleItems.count == 1 {
                            if item.components[ItemComponent.self]?.type
                                == .backpack
                            {
                                print("🎒")

                                // 땃쥐 행복해하는 로티 애니메이션 플레이
                                manager.currentActStatus = .getItem
                                AudioManager.playGetItemAudio(
                                    root: manager.gameRoot!
                                )
                                manager.visibleItems[0].isSolid = true
                                manager.setAllItemsAvailable()
                                item.removeFromParent()
                                manager.nearItem = nil

                                manager.currentSpeechStatus = .getBag
                            } else {
                                manager.currentSpeechStatus = .needBag
                            }
                        } else if manager.visibleItems.count > 1 {
                            if item.components[ItemComponent.self]?.type
                                == .cheese
                            {
                                print("🧀")

                                // 땃쥐 행복해하는 로티 애니메이션 플레이
                                manager.currentActStatus = .getItem

                                Task {
                                    await ItemManager().setCharacterScaleUp()
                                }
                                AudioManager.playGetItemAudio(
                                    root: manager.gameRoot!
                                )
                                manager.visibleItems[1].isSolid = true
                                item.removeFromParent()
                                manager.nearItem = nil

                                manager.currentSpeechStatus = .getCheeze
                            }
                            if item.components[ItemComponent.self]?.type
                                == .bottle
                            {
                                print("🍶")

                                // 땃쥐 행복해하는 로티 애니메이션 플레이
                                manager.currentActStatus = .getItem

                                ItemManager().setCharacterRunButtonAvailable()
                                AudioManager.playGetItemAudio(
                                    root: manager.gameRoot!
                                )
                                manager.visibleItems[2].isSolid = true
                                item.removeFromParent()
                                manager.nearItem = nil

                                manager.currentSpeechStatus = .getBottle
                            }
                            if item.components[ItemComponent.self]?.type
                                == .flashlight
                            {
                                print("🔦")

                                // 땃쥐 행복해하는 로티 애니메이션 플레이
                                manager.currentActStatus = .getItem

                                manager.visibleItems[3].isSolid = true
                                if let game = manager.gameRoot {
                                    guard
                                        let mapCompass = game.findEntity(
                                            named: "MapCompass_Anim"
                                        )
                                    else { return }
                                    ItemManager().setMapCompassItemAvailable(
                                        mapCompass: mapCompass
                                    )
                                }
                                AudioManager.playGetItemAudio(
                                    root: manager.gameRoot!
                                )
                                item.removeFromParent()
                                manager.nearItem = nil

                                manager.currentSpeechStatus = .getFlashlight
                            }
                        } else {
                            manager.currentSpeechStatus = .needNewspaper
                        }
                        if manager.visibleItems.last?.outlinedImageName
                            == "Map_Outline"
                        {
                            if item.components[ItemComponent.self]?.type
                                == .mapCompass
                            {
                                print("🗺️")

                                // 땃쥐 행복해하는 로티 애니메이션 플레이
                                manager.currentActStatus = .getItem

                                do {
                                    try ItemManager()
                                        .setCameraAngleToDestination()
                                } catch {
                                    print(
                                        "⚠️ Camera angle setting failed: \(error)"
                                    )
                                }

                                AudioManager.playGetItemAudio(
                                    root: manager.gameRoot!
                                )
                                manager.visibleItems[4].isSolid = true
                                item.removeFromParent()
                                manager.nearItem = nil

                                manager.currentSpeechStatus = .getMap
                            }
                        }
                    }
                )
            }

            // 초기화 버튼
            if manager.showResetButton {
                VStack {
                    HStack {
                        Spacer()

                        Button {
                            showResetAlert = true
                        } label: {
                            ActionButton(name: "ResetIcon")
                                .scaleEffect(0.7)
                        }
                    }
                    .padding(.all, 30)
                    Spacer()
                    // 우선순위 위로!
                }
                .zIndex(2)
            }

            if manager.showEndCredits {
                let width: CGFloat = UIScreen.main.bounds.width * 0.75
                let height: CGFloat = UIScreen.main.bounds.height * 0.75
                ZStack {
                    EndCreditsView()
                        .frame(width: width, height: height)
                        .onAppear {
                            // 로티 재생시간
                            DispatchQueue.main.asyncAfter(deadline: .now() + 53) {
                                showRestartButton = true
                            }
                        }
                    // 로티 재생 후 다시 시작버튼 생김
                    if showRestartButton {
                        Button {
                            manager.isGameReady = false
                            manager.resetGame()
                            manager.showInterface = false
                            showRestartButton = false
                            gameId = UUID()
                        } label: {
                            Text("다시 탐험하기").foregroundStyle(Color.white)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 14)
                        }.glassEffect(.regular.interactive())
                    }
                }
            }
        }
        .alert("게임을 다시 시작하시겠습니까?", isPresented: $showResetAlert) {
            Button("취소", role: .cancel) {}
            Button("다시 시작할래요", role: .confirm) {
                manager.isGameReady = false
                manager.resetGame()
                // 새로운 게임 아이디를 설정해줘서 realityview를 다시 그리게 한다
                gameId = UUID()
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
        if let character = manager.character {
            setupWorldCamera(target: character)
            await characterSetup(character)
        }

        // 배경음 삽입
        AudioManager.setupBackgroundAudio(root: game, content: content)
        AudioManager.playOceanAudio(root: game, content: content)
        AudioManager.playForestAudio(root: game, content: content)

        // TODO: - 환경 충돌 설정
        await setupEnvironmentCollisions(on: game, content: content)

        if let character = manager.character,
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
}

#Preview {
    GameView()
}

import CharacterMovement
import DummyAssets
import RealityKit
import SwiftUI
import ThumbStickView
import WorldCamera

struct GameView: View {
    @Environment(AppModel.self) private var appModel

    var character: Entity? {
        appModel.gameRoot?.findEntity(named: "TtouchParent")
    }

    @State var showCharacterJoystick: Bool = false

    var body: some View {
        ZStack {
            
            Color.black
                .ignoresSafeArea()

            RealityView { content in
                guard let game = try? await Entity(
                    named: "Scene", in: dummyAssetsBundle
                ) else { return }

                appModel.gameRoot = game

                await initializeGameSetting(game, content)
                content.add(game)

                showCharacterJoystick = true
            }
            .ignoresSafeArea()

            if showCharacterJoystick {
                PlatformerThumbControl(character: character)
            }
        }
        .allowedDynamicRange(.high)
    }

    fileprivate func initializeGameSetting(_ game: Entity, _ content: some RealityViewContentProtocol) async {
        if let character {
            setupWorldCamera(target: character)
            await characterSetup(character)
        }

        // TODO: - 환경 충돌 설정
        await setupEnvironmentCollisions(on: game, content: content)
    }

    fileprivate struct PlatformerThumbControl: View {
        let character: Entity?
        @State var CharacterJoystick: CGPoint = .zero

        var body: some View {
            VStack {
                Spacer()

                HStack(alignment: .bottom) {
                    ThumbStickView(updatingValue: $CharacterJoystick)
                        .onChange(of: CharacterJoystick) { _, newValue in
                            let movementVector: SIMD3<Float> = [Float(newValue.x), 0, Float(newValue.y)] / 10
                            character?.components[CharacterMovementComponent.self]?.controllerDirection = movementVector
                        }

                    Spacer()

                    // Jump button.
                    Image(systemName: "arrow.up")
                        .frame(width: 50, height: 50)
                        .font(.system(size: 36))
                        .glassEffect(.regular.interactive())
                        .onLongPressGesture(minimumDuration: 0.0, perform: {}, onPressingChanged: { isPressed in
                            character?.components[CharacterMovementComponent.self]?.jumpPressed = isPressed
                        })
                        .padding()
                }
            }
        }
    }
}

#Preview {
    GameView()
        .environment(AppModel())
}

//
//  JoystickButtonView.swift
//  TtouchIsland
//
//  Created by 김현기 on 7/28/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import CharacterMovement
import RealityKit
import SwiftUI
import ThumbStickView
import WorldCamera

struct JoystickButtonView: View {
    let manager: GameManager
    let itemAction: (_ item: Entity, _ camera: Entity) -> Void

    @State var characterJoystick: CGPoint = .zero
    @State var cameraAngleThumbstick: CGPoint = .zero

    var body: some View {
        ZStack {
            VStack {
                if !manager.isFocusedOnItem { Spacer().frame(height: 30) }  // 하단 패딩과 10 차이나게 (이유 모름;;)

                HStack {
                    GameStatusView()

                    Spacer()

                    if manager.isFocusedOnItem {
                        CloseNewspaperComponent(itemAction: itemAction)
                    }
                }  // HStack
                .padding(.horizontal, 48)

                Spacer()
            }

            if !manager.isFocusedOnItem {
                HStack(alignment: .bottom) {
                    ThumbStickView(updatingValue: $characterJoystick)
                        .onChange(of: characterJoystick) { _, newValue in
                            let movementVector: SIMD3<Float> =
                                [Float(newValue.x), 0, Float(newValue.y)]
                                / 10
                            manager.character?
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
                                [Float(newValue.x), Float(-newValue.y)] / 50

                            manager.gameRoot?.findEntity(named: "camera")?
                                .components[WorldCameraComponent.self]?
                                .updateWith(
                                    continuousMotion: movementVector
                                )
                        }
                        .background(Color.clear)

                        HStack {
                            if manager.nearItem != nil {
                                // Get Item Button
                                ActionButton(name: "GetIcon")
                                    .onTapGesture {
                                        if let item = manager.nearItem,
                                            let camera = manager.gameCamera,
                                            let character = manager.character
                                        {
                                            itemAction(item, camera)
                                            AudioManager.playJumpAudio(
                                                root: character
                                            )
                                        }
                                    }
                                    .padding(.trailing, 8)
                            }

                            // Run Button
                            if manager.runButtonEnabled {
                                ActionButton(name: "RunIcon")
                                    .onLongPressGesture(
                                        minimumDuration: 0.0,  // 즉시 반응
                                        pressing: { isPressed in
                                            if isPressed {
                                                manager.currentActStatus = .run
                                                manager.setCharacterRunning(
                                                    to: true
                                                )

                                            } else {
                                                manager.currentActStatus =
                                                    .common
                                                manager.setCharacterRunning(
                                                    to: false
                                                )
                                            }
                                        },
                                        perform: {}
                                    )
                                    .padding(.trailing, 8)
                            } else {
                                DisabledActionButton(name: "RunIcon")
                                    .disabled(true)
                                    .padding(.trailing, 8)
                            }

                            // Jump button.
                            ActionButton(name: "JumpIcon")
                                .onLongPressGesture(
                                    minimumDuration: 0.0,
                                    pressing: { isPressed in
                                        manager.character?.components[
                                            CharacterMovementComponent.self
                                        ]?.jumpPressed = isPressed
                                        if let character = manager.character {
                                            AudioManager.playJumpAudio(
                                                root: character
                                            )
                                        }
                                        manager.currentActStatus = .jump
                                    },
                                    perform: {}
                                )
                        }  // HStack
                    }  // ZStack
                }  // HStack
                .padding(.horizontal, 56)
                .padding(.bottom, 40)
            }
        }  // ZStack
    }
}

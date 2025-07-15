/*
  Copyright © 2025 Apple Inc.

  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import RealityKit
import SwiftUI

/// A system that updates playable characters based on motion information
/// from the character movement component.
public struct CharacterMovementSystem: System {
    /// 캐릭터에게 적용되는 중력 벡터
    var gravityConstant: SIMD3<Float> { [0, -9.8, 0] * 0.04 }

    /// 점프 시 적용되는 상승력
    static var jumpForce: SIMD3<Float> { [0, 0.08, 0] }

    /// The maximum speed for the character.
    /// 캐릭터의 최대 속도
    let maxFlatSpeed: Float = 2.5
    /// 가속 비율
    var accelerationRate: Float = 0.1
    /// 감속 비율
    var decelerationRate: Float = 0.6

    public init(scene _: RealityKit.Scene) {}

    /// SceneUpdateContext: RealityKit의 시스템(System) 업데이트 과정에서 제공되는 컨텍스트 객체
    /// 이 객체는 ECS(Entity-Component-System) 아키텍처에서 시스템이 씬의 상태와 상호작용하는 데 필요한 핵심 정보와 기능을 제공합니다.
    public mutating func update(context: SceneUpdateContext) {
        /// 이전 프레임부터 현재 프레임까지의 경과 시간(초)을 제공한다.
        let floatDeltaTime = Float(context.deltaTime)
        /// CharacterMovementComponent를 가진 모든 엔티티를 찾는다.
        let movementEntities = context.entities(
            matching: EntityQuery(
                where: .has(CharacterMovementComponent.self)),
            updatingSystemWhen: .rendering
        )
        /// 카메라 참조 가져오기 : 카메라 기준으로 이동 방향 조정
        let rkCamera = realityKitCameraEntity(context: context)

        /// 각 캐릭터 엔티티에 대한 이동과 상태를 처리하는 핵심 로직을 나타낸다.
        for character in movementEntities {
            // 캐릭터가 CharacterMovementComponent를 가지고 있는지 확인한다.
            guard var characterMovement = character.components[CharacterMovementComponent.self]
            else { return }

            // The character is paused, so skip this character.
            // 일시정지된 캐릭터일 경우 건너뛴다.
            if characterMovement.paused { continue }

            // 조이스틱 입력 방향 가져오기
            let controllerInput = characterMovement.controllerDirection // WASDDirection 없앰으로써 바꿈
            // 입력 강도 계산해오기
            let directionLength = simd_length(controllerInput)
            // 카메라 방향을 기준으로 입력 방향 변환. (플레이어가 보는 방향이 '앞'이 된다)
            var fixedDirection = if let rkCamera {
                rkCamera.orientation.flattened
                    .act(controllerInput)
            } else {
                /// nearestSimulationEntity : 캐릭터와 가장 가까운 물리 시뮬레이션 엔티티 찾기
                /// .orientation.flattend.inverse : 평면화된 방향의 역 계산. (역을 계산하는 이유 : 물리 엔티티 기준으로 상대적 방향을 계산하기 위함)
                PhysicsSimulationComponent.nearestSimulationEntity(for: character)?.orientation.flattened.inverse
                    .act(controllerInput) ?? controllerInput
            }
            /// 방향 벡터를 1.8로 나눠 속도를 조절합니다
            fixedDirection /= 1.8
            // 계산된 방향으로 캐릭터 이동
            moveCharacter(
                character,
                by: &fixedDirection,
                deltaTime: floatDeltaTime,
                lastLinear: &characterMovement.lastLinear,
                jump: characterMovement.jumpReady
            )
            // 캐릭터가 이동하는 방향으로 회전시킨다.
            reorientCharacter(character, to: fixedDirection, proxy: characterMovement.characterProxy)

            // 계산된 최종 속도를 컴포넌트에 저장한다.
            character.components[CharacterMovementComponent.self]?.lastLinear = characterMovement.lastLinear

            // Based on the controller input, change the character state.
            let targetCharacterState: CharacterStateComponent.CharacterState =
                // 점프 준비 상태면 점프 상태로 설정
                if characterMovement.jumpReady {
                    .jump
                } else {
                    // 이동 중이면 걷기 상태로, 멈춰있다면 대기 상태로
                    directionLength > 1e-10 ? .walking : .idle
                }

            // 결정된 상태에 따라서 애니메이션 업데이트
            _ = try? CharacterStateComponent.updateState(
                for: character,
                to: targetCharacterState,
                movementSpeed: directionLength,
                childProxy: characterMovement.characterProxy
            )
            // 변경사항을 외부 콜백에 알린다.
            characterMovement.update(character, characterMovement.lastLinear, context.deltaTime)
        }
    }

    /// RealityKit Scene에서 카메라 엔티티를 찾아서 반환하는 역할
    fileprivate func realityKitCameraEntity(context: SceneUpdateContext) -> Entity? {
        /// 다양한 카메라 타입을 검색한다
        let lookupComponents: [Component.Type] = [
            PerspectiveCameraComponent.self, // 원근감 있는 일반적인 3D 카메라
            OrthographicCameraComponent.self, // 원근감 없는 2D 스타일 카메라
            ProjectiveTransformCameraComponent.self, // 다양한 투영 변환을 지원하는 카메라
        ]
        /// 현재 씬에서 카메라 엔티티를 찾는 과정.
        for component in lookupComponents {
            let query = EntityQuery(where: .has(component))
            if let camera = context.entities(
                matching: query,
                updatingSystemWhen: .rendering
            )
            // 찾으면 즉시 카메라 객체 반환
            .first(where: { _ in true }) {
                return camera
            }
        }
        return nil
    }

    /// Performs character movement.
    /// - Parameters:
    ///   - character: The character to move.
    ///   - fixedDirection: The direction to move the character.
    ///   - deltaTime: The time since the last frame.
    ///   - jump: The jump flag.
    @MainActor
    fileprivate mutating func moveCharacter(
        _ character: Entity,
        by fixedDirection: inout SIMD3<Float>,
        deltaTime: Float,
        lastLinear: inout SIMD3<Float>,
        jump: Bool
    ) {
        /// 수평면(XZ)에서의 속도 크기 비교
        /// 속도 감소 시 0.6으로 감속 (빠르게) , 가속 시 0.1로 가속 (부드럽게)
        let accelerationRate: Float = {
            let lastFlatSpeed = simd_length_squared(SIMD2<Float>(lastLinear.x, lastLinear.z))
            let newFlatSpeed = simd_length_squared(SIMD2<Float>(fixedDirection.x, fixedDirection.z))
            return lastFlatSpeed > newFlatSpeed ? self.decelerationRate : self.accelerationRate
        }()

        /// 선형 보간(LERP) 방식을 통한 부드러운 속도 전환
        /// 이전 속도에서 목표 속도로 점진적인 변화
        lastLinear.x = lastLinear.x * (1 - accelerationRate) + fixedDirection.x * deltaTime * accelerationRate
        lastLinear.z = lastLinear.z * (1 - accelerationRate) + fixedDirection.z * deltaTime * accelerationRate

        // 점프 처리 코드
        if let controllerState = character.components[CharacterControllerStateComponent.self] {
            /// 캐릭터가 지면에 있을 때만 점프 가능
            if controllerState.isOnGround {
                // 점프력 0.08 적용
                lastLinear.y = jump ? CharacterMovementSystem.jumpForce.y : 0
            }
            /// 점프 상태 플래그 초기화
            character.components[CharacterMovementComponent.self]?.jumpReady = false
//            character.components[CharacterMovementComponent.self]?.attackReady = false
        }
        // Help the character jump a bit farther by reducing the effect of gravity
        // while someone presses the jump button.
        var gravityMultiplier: Float = 1.0
        if let jumpPressed = character.components[CharacterMovementComponent.self]?.jumpPressed,
           /// 점프 버튼 계속 누르고 있으면 중력 효과 60% 감소
           jumpPressed
        {
            gravityMultiplier *= 0.4
        }
        /// 중력 상수(-9.8 * 0.04)를 y축 속도에 적용
        lastLinear.y += gravityConstant.y * gravityMultiplier * deltaTime

        /// 최종 이동 적용
        character.moveCharacter(by: lastLinear, deltaTime: deltaTime, relativeTo: character.parent)
    }

    @MainActor
    func reorientCharacter(_ character: Entity, to direction: SIMD3<Float>, proxy: String?) {
        var charModel: Entity = character
        if let proxy, let proxyModel = character.findEntity(named: proxy) {
            charModel = proxyModel
        }
        let orientation = simd_quatf(from: [0, 0, 1], to: normalize([direction.x, 0, direction.z]))
        if orientation.real.isNaN || orientation.angle == .zero {
            return
        }
        charModel.orientation = simd_slerp(charModel.orientation, orientation, 0.1)
    }
}

import CharacterMovement
import ControllerInput
import RealityKit
import SwiftUI
import WorldCamera

extension GameView {
    var characterCollisionFilter: CollisionFilter {
        CollisionFilter(
            group: GameCollisionGroup.player,
            mask: .all
        )
    }

    // 캐릭터 이동 후 호출되는 함수
    func characterMoveUpdated(
        entity: Entity,
        velocity _: SIMD3<Float>,
        deltaTime _: TimeInterval
    ) {
        if let controllerState = entity.components[
            CharacterControllerStateComponent.self
        ] {
            // If not on the ground, exit early. 현재는 캐릭터가 지면에 있는지만 확인
            guard controllerState.isOnGround else { return }
        }
    }

    // 컨트롤러 입력 처리 함수
    // TODO: - 드래그 제스쳐로 카메라 이동 구현
    func controllerInputUpdater(
        _ component: inout ControllerInputReceiver,
        entity: Entity
    ) {
        // TODO: - 조이스틱 -> 화면 드래그로 카메라 조정
        //        if let camEntity = entity.scene?.findEntity(named: "camera"),
        //           var camComponent = camEntity.components[WorldCameraComponent.self]
        //        {
        //            camComponent.updateWith(joystickMotion: component.rightJoystick)
        //            camEntity.components.set(camComponent)
        //        }

        // 캐릭터 움직임 업데이트
        guard
            var characterMovement = entity.components[
                CharacterMovementComponent.self
            ]
        else { return }

        if !characterMovement.paused {
            characterMovement.controllerDirection =
                [component.leftJoystick.x, 0, -component.leftJoystick.y] * 3
            if component.jumpPressed != characterMovement.jumpPressed {
                characterMovement.jumpPressed = component.jumpPressed
            }
            entity.components.set(characterMovement)
            //            if component.attackReady {
            //                component.attackReady = false
            //                if let attackAnim = try? HeroAttackAction.animation(duration: 1) {
            //                    entity.playAnimation(attackAnim)
            //                    HapticUtility.playHapticsFile(named: "SpinAttack")
            //                }
            //            }
        }
    }
}

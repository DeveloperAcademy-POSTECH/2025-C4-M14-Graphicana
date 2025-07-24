//
//  GameView+Item.swift
//  TtouchIsland
//
//  Created by 김현기 on 7/18/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import CharacterMovement
import RealityKit
import SwiftUI
import WorldCamera

extension GameView {
    func setupItems(
        character: Entity,
        newspaper: Entity,
        backpack: Entity,
        cheese: Entity,
        bottle: Entity,
        flashlight: Entity,
        mapCompass: Entity,
        content _: some RealityViewContentProtocol
    ) {
        newspaper.components.set([ItemComponent(type: .newspaper, targetEntity: character)])
        backpack.components.set([ItemComponent(type: .backpack, targetEntity: character)])
        cheese.components.set([ItemComponent(type: .cheese, targetEntity: character)])
        bottle.components.set([ItemComponent(type: .bottle, targetEntity: character)])
        flashlight.components.set([ItemComponent(type: .flashlight, targetEntity: character)])
        mapCompass.components.set([ItemComponent(type: .mapCompass, targetEntity: character)])
    }

    /// 신문을 클로즈업하는 함수
    func closeupNewspaper(newspaper: Entity, camera: Entity) throws {
        appModel.isFocusedOnItem.toggle()

        // 카메라 상태 수동 저장
        if let worldCameraComponent = camera.components[WorldCameraComponent.self] {
            appModel.savedCameraState = worldCameraComponent
            print("✅ Camera state saved: \(worldCameraComponent)")
        }

        // 캐릭터 움직임 정지
        if let character = character,
           var movementComponent = character.components[CharacterMovementComponent.self]
        {
            movementComponent.paused = true
            character.components.set(movementComponent)
        }

        // 카메라를 신문으로 이동시키는 액션 생성
        let orientAction = CameraOrientAction(
            transitionIn: 0.5,
            transitionOut: 0,
            azimuth: .pi - 0.8, // 카메라의 수평 회전 각도
            elevation: 0.3, // 카메라의 수직 회전 각도
            radius: 0.75, // 카메라와 신문 사이의 거리
            targetOffset: .zero, // 카메라가 바라볼 때 신문의 오프셋
            target: newspaper.id
        )

        let orientAnim = try AnimationResource.makeActionAnimation(
            for: orientAction, duration: .greatestFiniteMagnitude
        )
        CameraOrientActionHandler.register { _ in CameraOrientActionHandler() }
        camera.playAnimation(orientAnim)

        // 신문이 서서히 나타나는 애니메이션
        let fadeInAction = FromToByAction(to: Float(1.0))
        let fadeInAnim = try AnimationResource.makeActionAnimation(
            for: fadeInAction, duration: 1, bindTarget: .opacity, delay: 1
        )
        newspaper.playAnimation(fadeInAnim)
    }

    /// 플레이어 시점으로 카메라를 되돌리는 함수
    func returnToPlayerView(camera: Entity) throws {
        appModel.isFocusedOnItem.toggle()

        camera.stopAllAnimations()

        // 카메라의 FollowComponent를 캐릭터로 다시 설정
        if let character = character {
            if let followComponent = camera.components[FollowComponent.self] {
                followComponent.targetOverride = character.id
                followComponent.cameraComponent = appModel.savedCameraState
                camera.components.set(followComponent)
            } else {
                // FollowComponent가 없으면 새로 추가
                let followComponent = FollowComponent(
                    targetId: character.id,
                    cameraComponent: appModel.savedCameraState
                )
                camera.components.set(followComponent)
            }
        }

        CameraOrientAction.subscribe(to: .ended) { _ in
            // 캐릭터 움직임 재개
            if let character = character,
               var movementComponent = character.components[CharacterMovementComponent.self]
            {
                movementComponent.paused = false
                character.components.set(movementComponent)
            }
        }

        appModel.displayAllItemsVisible = true
    }

    // MARK: - 신문 아이템 상호작용 함수

    func handleNewspaperItem(item: Entity, camera: Entity) {
        do {
            if appModel.isFocusedOnItem {
                try returnToPlayerView(camera: camera)
            } else {
                try closeupNewspaper(newspaper: item, camera: camera)
            }
        } catch {
            print("Error during newspaper interaction: \(error)")
        }
    }
}

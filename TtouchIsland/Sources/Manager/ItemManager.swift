//
//  ItemManager.swift
//  TtouchIsland
//
//  Created by 김현기 on 7/28/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import CharacterMovement
import Foundation
import RealityKit
import WorldCamera

struct ItemManager {
    let manager = GameManager.shared

    /// 신문을 클로즈업하는 함수
    func closeupNewspaper(newspaper: Entity, camera: Entity) throws {
        manager.isFocusedOnItem.toggle()
        manager.showResetButton = false

        if let character = manager.character {
            character.isEnabled = false // 캐릭터 비활성화
        }

        // 카메라 상태 수동 저장
        if let worldCameraComponent = camera.components[
            WorldCameraComponent.self
        ] {
            manager.savedCameraState = worldCameraComponent
            print("✅ Camera state saved: \(worldCameraComponent)")
        }

        // 캐릭터 움직임 정지
        if let character = manager.character,
            var movementComponent = character.components[
                CharacterMovementComponent.self
            ]
        {
            movementComponent.paused = true
            character.components.set(movementComponent)
        }

        // 카메라를 신문으로 이동시키는 액션 생성
        let orientAction = CameraOrientAction(
            transitionIn: 0.5,
            transitionOut: 0,
            azimuth: .pi - 0.8,  // 카메라의 수평 회전 각도
            elevation: 0.3,  // 카메라의 수직 회전 각도
            radius: 0.75,  // 카메라와 신문 사이의 거리
            targetOffset: .zero,  // 카메라가 바라볼 때 신문의 오프셋
            target: newspaper.id
        )

        let orientAnim = try AnimationResource.makeActionAnimation(
            for: orientAction,
            duration: .greatestFiniteMagnitude
        )
        CameraOrientActionHandler.register { _ in CameraOrientActionHandler() }
        camera.playAnimation(orientAnim)

        // 신문이 서서히 나타나는 애니메이션
        let fadeInAction = FromToByAction(to: Float(1.0))
        let fadeInAnim = try AnimationResource.makeActionAnimation(
            for: fadeInAction,
            duration: 1,
            bindTarget: .opacity,
            delay: 1
        )
        newspaper.playAnimation(fadeInAnim)
    }

    /// 플레이어 시점으로 카메라를 되돌리는 함수
    func returnToPlayerView(camera: Entity) throws {
        manager.isFocusedOnItem.toggle()
        manager.showResetButton = true

        camera.stopAllAnimations()

        if let character = manager.character {
            character.isEnabled = true // 캐릭터 활성화
        }

        // 카메라의 FollowComponent를 캐릭터로 다시 설정
        if let character = manager.character {
            if let followComponent = camera.components[FollowComponent.self] {
                followComponent.targetOverride = character.id
                followComponent.cameraComponent = manager.savedCameraState
                camera.components.set(followComponent)
            } else {
                // FollowComponent가 없으면 새로 추가
                let followComponent = FollowComponent(
                    targetId: character.id,
                    cameraComponent: manager.savedCameraState
                )
                camera.components.set(followComponent)
            }
        }

        // 캐릭터 움직임 재개
        if let character = manager.character,
            var movementComponent = character.components[
                CharacterMovementComponent.self
            ]
        {
            movementComponent.paused = false
            character.components.set(movementComponent)
        }

        manager.setBackpackAvailable()

        manager.savedCameraState = nil // 카메라 상태 초기화
    }

    // MARK: - 신문 아이템 상호작용 함수

    func handleNewspaperItem(item: Entity, camera: Entity) {
        do {
            if manager.isFocusedOnItem {
                manager.updateStatus(to: .common)
                try returnToPlayerView(camera: camera)
            } else {
                manager.updateStatus(to: .read)
                try closeupNewspaper(newspaper: item, camera: camera)
            }
        } catch {
            print("Error during newspaper interaction: \(error)")
        }
    }

    // MARK: - 치즈 아이템 상호작용 메소드

    func setCharacterScaleUp() async {
        guard let character = manager.character else { return }

        let bounds = await character.visualBounds(relativeTo: character.parent)

        await character.setScale([2.0, 2.0, 2.0], relativeTo: character.parent)

        // 충돌 형상 생성
        let collisionRadius = bounds.extents.x / 2 - 0.2
        let collisionHeight = bounds.extents.y

        await character.components.set(
            [
                CharacterControllerComponent(
                    radius: collisionRadius,
                    height: collisionHeight,
                    collisionFilter: CollisionFilter(
                        group: GameCollisionGroup.player,
                        mask: .all
                    )
                )
            ]
        )
    }

    // MARK: - 보틀 아이템 상호작용 메소드

    func setCharacterRunButtonAvailable() {
        manager.runButtonEnabled = true
    }

    // MARK: - 플래시라이트 아이템 상호작용 메소드

    func setCameraAngleToMapCompass(mapCompass: Entity) throws {
        guard let camera = manager.gameCamera else {
            print("⚠️ Warning: Camera is not available.")
            return
        }

        guard let currentCameraSetting = camera.components[WorldCameraComponent.self] else { return }

        let orientAction = CameraOrientAction(
            transitionIn: 2.0, transitionOut: 2.0,
            azimuth: .pi / 2, elevation: currentCameraSetting.elevation,
            radius: 10.0, targetOffset: .zero, target: mapCompass.id
        )

        let orientAnim = try AnimationResource.makeActionAnimation(
            for: orientAction, duration: 6.0
        )
        CameraOrientActionHandler.register { _ in CameraOrientActionHandler() }
        camera.playAnimation(orientAnim)

        mapCompass.isEnabled = true
        mapCompass.components.set(
            OpacityComponent(opacity: 0.0)
        )

        // Pause the hero.
        if let character = manager.character,
           var movementComponent = character.components[CharacterMovementComponent.self]
        {
            movementComponent.paused = true
            character.components.set(movementComponent)
        }

        CameraOrientAction.subscribe(to: .ended) { _ in

            // 캐릭터 움직임 재개
            if let character = manager.character,
               var movementComponent = character.components[CharacterMovementComponent.self]
            {
                movementComponent.paused = false
                character.components.set(movementComponent)
            }
        }

        let fadeInAction = FromToByAction(to: Float(1.0))
        let fadeInAnim = try AnimationResource.makeActionAnimation(
            for: fadeInAction, duration: 3, bindTarget: .opacity, delay: 1
        )
        mapCompass.playAnimation(fadeInAnim)
    }

    func setMapCompassItemAvailable(mapCompass: Entity) {
        if manager.visibleItems.count == 5,
           manager.visibleItems[4].outlinedImageName == "Mystery_Outline"
        {
            manager.visibleItems[3].isSolid = true
            manager.visibleItems[4] = StatusItem(
                solidImageName: "Map",
                outlinedImageName: "Map_Outline",
                isSolid: false
            )
        } else {
            print("⚠️ Warning: MapCompass is not available yet.")
        }

        do {
            try setCameraAngleToMapCompass(mapCompass: mapCompass)
        } catch {
            print("❌ Error: Failed to set camera angle to map compass - \(error.localizedDescription)")
        }
    }
}

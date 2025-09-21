//
//  ItemSystem.swift
//  TtouchIsland
//
//  Created by 김현기 on 7/18/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import CharacterMovement
import RealityKit
import SwiftUI
import WorldCamera
import simd

struct ItemSystem: System {
    @State var manager = GameManager.shared

    init(scene _: RealityKit.Scene) {}

    // 왜 Static으로 설정하는가?
    /* ItemSystem의 모든 인스턴스가 동일한 쿼리(EntityQuery)를 공유하도록 하기 위함입니다.
     이렇게 하면 쿼리 객체가 한 번만 생성되고, 매번 시스템이 생성될 때마다 새로 만들 필요 없이 재사용할 수 있어 성능과 코드 효율성이 좋아집니다.
     즉, 쿼리가 시스템 전체에서 공통적으로 사용되는 "정적 자원"이기 때문에 static으로 선언합니다. */
    private static let query = EntityQuery(where: .has(ItemComponent.self))

    func update(context: SceneUpdateContext) {
        // 현재 nearItem이 설정되어 있다면 해당 엔티티와의 거리만 확인
        if let currentNearItem = manager.nearItem,
            let currentItemComponent = currentNearItem.components[
                ItemComponent.self
            ],
            let target = currentItemComponent.targetEntity
        {
            let itemPosition = currentNearItem.transform.translation
            let characterPosition = target.transform.translation
            let distance = simd.distance(itemPosition, characterPosition)

            // 현재 nearItem이 여전히 유효한 거리 내에 있다면 유지
            if distance <= currentItemComponent.maxDistance {
                return
            } else {
                // 유효 거리에서 벗어나면 nil로 설정
                manager.nearItem = nil
            }
        }

        // nearItem이 nil인 경우, 모든 엔티티를 순회하며 아이템을 찾는다.
        for entity in context.entities(
            matching: Self.query,
            updatingSystemWhen: .rendering
        ) {
            guard var itemComponent = entity.components[ItemComponent.self],
                let target = itemComponent.targetEntity  // 상호작용하려는 캐릭터 엔티티
            else { continue }

            // 1. 캐릭터와 아이템 사이 거리 계산
            let itemPosition = entity.transform.translation
            let characterPosition = target.transform.translation
            let distance = simd.distance(itemPosition, characterPosition)

            if distance <= itemComponent.maxDistance {
                manager.nearItem = entity
                itemComponent.isCollected = true
                entity.components.set(itemComponent)
                break  // 가까운 엔티티를 찾으면 루프 종료
            }
        }
        // 루프 밖에서 다 모았는지 확인
        checkItemAtEndPoint(context: context)
    }

    // endPint에서 모든 아이템을 수집했는지 확인
    func checkItemAtEndPoint(context: SceneUpdateContext) {
        guard let character = manager.gameRoot?.findEntity(named: "Ttouch"),
            let endPoint = manager.gameRoot?.findEntity(named: "Leaf")
        else { return }

        // 1. 캐릭터와 아이템 사이 거리 계산
        let endPointPosition = endPoint.transform.translation
        let characterPosition = character.transform.translation
        let endPointDistance = simd.distance(
            endPointPosition,
            characterPosition
        )

        var collectedItem: [ItemComponent] = []

        // ItemComponent가 있는 모든 엔티티 중 isCollectedItem이 true인지 확인
        // ItemComponent인 모든 entity를 불러옴
        let itemEntity = context.entities(
            matching: Self.query,
            updatingSystemWhen: .rendering
        )
        // compactMap: nil이 아닌 것을 반환, ItemComponent 목록만 남게
        //        .compactMap { $0.components[ItemComponent.self] }
        for entity in itemEntity {
            if let item = entity.components[ItemComponent.self] {
                collectedItem.append(item)
            }
        }
        // 모든 아이템이 isCollectedItem = true인지 검사(1나라도 false면 false)
        //        .allSatisfy { $0.isCollectedItem }

        var isCollectedAllItem = true

        for item in collectedItem {
            if !item.isCollected {
                isCollectedAllItem = false
                break
            }
        }

        // 모든 조건 충족하면 애니메이션 재생
        if isCollectedAllItem && endPointDistance < 0.5
            && !manager.isGameFinished
        {
            manager.isGameFinished = true
            manager.showInfoButton = false
            manager.showResetButton = false

            print("complete")
            // 엔딩 애니메이션: 물 차오르는 애니메이션 재생
            playMapEndingAnimation()
        }
    }

    func playMapEndingAnimation() {
        guard let ocean = manager.gameRoot?.findEntity(named: "OceanPlane"),
            let character = manager.gameRoot?.findEntity(named: "Ttouch")
        else { return }

        // 땃쥐 멈춰
        if var movementComponent = character.components[
            CharacterMovementComponent.self
        ]  //            var stateComponent = character.components[
        //                CharacterStateComponent.self
        //            ]
        {
            movementComponent.paused = true
            character.components.set(movementComponent)
            //            stateComponent.currentState = .idle
            //            character.components.set(stateComponent)
        }

        manager.showInterface = false

        // 땃쥐 y좌표 가져오기
        let characterPosition = character.transform.translation.y
        // OceanPlane의 현재 transform(위치 등등) 저장
        var oceanPosition = ocean.transform

        // OceanPlane의 y를 땃쥐 높이까지 올릴거야
        oceanPosition.translation.y = characterPosition

        ocean.move(
            to: oceanPosition,
            relativeTo: nil,
            duration: 5.0
        )
        // 카메라 페이드 아웃되고 섬 전체 보여주는 애니메이션
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            playZoomOutOceanAnimation()
        }
    }

    func playZoomOutOceanAnimation() {
        guard let character = manager.gameRoot?.findEntity(named: "Ttouch"),
            let camera = manager.gameRoot?.findEntity(named: "camera")
        else { return }

        // 카메라 줌아웃하는 액션 생성
        let orientAction = CameraOrientAction(
            transitionIn: 0.5,
            transitionOut: 0.5,
            azimuth: .pi / 12,  // 약 15도(오른쪽으로 살짝 회전)으로 땃쥐 바라보게 됨
            elevation: .pi / 6,  // 약 30도로 위에서 내려다보는 시점으로 설정
            radius: 12,  // 카메라 멀리 보내기
            targetOffset: .zero,
            target: character.id
        )

        // 무한 재생되는 카메라 애니메이션 리소스 생성
        if let orientAnim = try? AnimationResource.makeActionAnimation(
            // CameraOrientAction 같은 Action 타입을 RealityKit에서 이해할 수 있는 애니메이션 리소스(AnimationResource)로 바꿔줍니다
            for: orientAction,
            duration: Double.infinity
        ) {
            // CameraOrientAction이 어떻게 실행될지 정의하는 핸들러를 등록
            // 내부적으로 CameraOrientAction의 매개변수를 실제 카메라의 transform으로 변환하는 작업을 수행
            CameraOrientActionHandler.register { _ in
                CameraOrientActionHandler()
            }
            // 변환된 orientAnim 애니메이션 리소스를 카메라엔티티에 적용해서 실제로 움직이게함
            camera.playAnimation(orientAnim)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            manager.showEndCredits = true
        }

        GameCenterManager.shared.reportAchievement(
            identifier: "game_clear",
            percentComplete: 100.0
        )
        reportGameCenterAchievement()
    }

    func reportGameCenterAchievement() {
        GameCenterManager.shared.reportAchievement(
            identifier: "game_clear",
            percentComplete: 100.0
        )
    }
}

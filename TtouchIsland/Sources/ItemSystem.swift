//
//  ItemSystem.swift
//  TtouchIsland
//
//  Created by 김현기 on 7/18/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import RealityKit
import simd
import SwiftUI

struct ItemSystem: System {
    @State var appModel = AppModel.shared

    init(scene _: RealityKit.Scene) {}

    // 왜 Static으로 설정하는가?
    /* ItemSystem의 모든 인스턴스가 동일한 쿼리(EntityQuery)를 공유하도록 하기 위함입니다.
     이렇게 하면 쿼리 객체가 한 번만 생성되고, 매번 시스템이 생성될 때마다 새로 만들 필요 없이 재사용할 수 있어 성능과 코드 효율성이 좋아집니다.
     즉, 쿼리가 시스템 전체에서 공통적으로 사용되는 "정적 자원"이기 때문에 static으로 선언합니다. */
    private static let query = EntityQuery(where: .has(ItemComponent.self))

    func update(context: SceneUpdateContext) {
        // 현재 nearItem이 설정되어 있다면 해당 엔티티와의 거리만 확인
        if let currentNearItem = appModel.nearItem,
           let currentItemComponent = currentNearItem.components[ItemComponent.self],
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
                appModel.nearItem = nil
            }
        }

        // nearItem이 nil인 경우, 모든 엔티티를 순회하며 아이템을 찾는다.
        for entity in context.entities(
            matching: Self.query,
            updatingSystemWhen: .rendering
        ) {
            guard var itemComponent = entity.components[ItemComponent.self],
                  let target = itemComponent.targetEntity // 상호작용하려는 캐릭터 엔티티
            else { continue }

            // 1. 캐릭터와 아이템 사이 거리 계산
            let itemPosition = entity.transform.translation
            let characterPosition = target.transform.translation
            let distance = simd.distance(itemPosition, characterPosition)

            if distance <= itemComponent.maxDistance {
                appModel.nearItem = entity
                itemComponent.isCollected = true
                entity.components.set(itemComponent)
                break // 가까운 엔티티를 찾으면 루프 종료
            }
        }
        // 루프 밖에서 다 모았는지 확인
        checkItemAtEndPoint(context: context)
    }

    // endPint에서 모든 아이템을 수집했는지 확인
    func checkItemAtEndPoint(context: SceneUpdateContext) {
        guard let character = appModel.gameRoot?.findEntity(named: "Ttouch"),
              let endPoint = appModel.gameRoot?.findEntity(named: "Item")
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
        if isCollectedAllItem && endPointDistance < 1.5
            && !appModel.isGameFinished
        {
            appModel.isGameFinished = true
            print("complete")
            // 엔딩 애니메이션: 물 차오르는 애니메이션 재생
            playMapEndingAnimation()
        }
    }

    func playMapEndingAnimation() {
        guard let ocean = appModel.gameRoot?.findEntity(named: "OceanPlane"),
              let character = appModel.gameRoot?.findEntity(named: "Ttouch")
        else { return }

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
        // TO DO: 카메라 페이드 아웃되고 땃쥐가 떠나는 애니메이션 구현
    }
}

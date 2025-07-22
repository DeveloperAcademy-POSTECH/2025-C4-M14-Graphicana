//
//  ItemSystem.swift
//  TtouchIsland
//
//  Created by 김현기 on 7/18/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import RealityKit
import SwiftUI
import simd

struct ItemSystem: System {
    private var appModel: AppModel = .shared

    init(scene _: RealityKit.Scene) {}

    // 왜 Static으로 설정하는가?
    /* ItemSystem의 모든 인스턴스가 동일한 쿼리(EntityQuery)를 공유하도록 하기 위함입니다.
     이렇게 하면 쿼리 객체가 한 번만 생성되고, 매번 시스템이 생성될 때마다 새로 만들 필요 없이 재사용할 수 있어 성능과 코드 효율성이 좋아집니다.
     즉, 쿼리가 시스템 전체에서 공통적으로 사용되는 "정적 자원"이기 때문에 static으로 선언합니다. */
    private static let query = EntityQuery(where: .has(ItemComponent.self))

    func update(context: SceneUpdateContext) {
        for entity in context.entities(
            matching: Self.query,
            updatingSystemWhen: .rendering
        ) {
            guard var itemComponent = entity.components[ItemComponent.self],
                let target = itemComponent.targetEntity  // 상호작용하려는 캐릭터 엔티티
            //                  var modelComponent = entity.components[ModelComponent.self] // 현재 엔티티의 ModelComponent
            else { continue }

            // 1. 캐릭터와 아이템 사이 거리 계산
            let itemPosition = entity.transform.translation
            let characterPosition = target.transform.translation
            let distance = simd.distance(itemPosition, characterPosition)

            appModel.isNearNewspaper = distance <= itemComponent.maxDistance

            // 거리 안에 들어오면 isCollectedItem(수집 상태) true로
            if distance <= itemComponent.maxDistance {
                itemComponent.isCollected = true
                print("get \(itemComponent.type)")
            }

            // 업데이트된 itemComponent 다시 설정
            entity.components.set(itemComponent)

            //            // 2. 거리가 maxDistance 이내이면 1.0(최대 밝기), 아니면 0.0(꺼짐)을 반환
            //            let glowIntensity: Float = distance <= itemComponent.maxDistance ? 1.0 : 0.0

            //            // 3. EmissiveColor 속성 업데이트
            //            let emissiveColor = Material.Color.white.withAlphaComponent(CGFloat(glowIntensity))

            //            // 3. 모든 모델컴포넌트에 대해 EmissiveColor 업데이트
            //            for i in 0 ..< modelComponent.materials.count {
            //                if var pbrMaterial = modelComponent.materials[i] as? PhysicallyBasedMaterial {
            //                    // 발광색 설정
            //                    pbrMaterial.emissiveColor = .init(color: emissiveColor)
            //
            //                    // 수정된 메터리얼 할당
            //                    modelComponent.materials[i] = pbrMaterial
            //                }
            //            }
            //
            //            entity.components.set(modelComponent)
        }
        // 루프 밖에서 다 모았는지 확인
        checkItemAtEndPoint(context: context)
    }

    // endPint에서 모든 아이템을 수집했는지 확인
    func checkItemAtEndPoint(context: SceneUpdateContext) {

        var isCompleted = false

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

        // 모든 조건 충족하면 애니메이션 재생(TO DO)
        if isCollectedAllItem && endPointDistance < 1.5 {
            if !isCompleted {
                isCompleted = true
                print("complete")
                // TO DO: 물 차오르는 애니메이션 재생 구현}
            }
        }
    }
}

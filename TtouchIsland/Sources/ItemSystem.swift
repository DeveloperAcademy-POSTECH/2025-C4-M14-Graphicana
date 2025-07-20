//
//  ItemSystem.swift
//  TtouchIsland
//
//  Created by 김현기 on 7/18/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import Foundation
import RealityKit
import simd

struct ItemSystem: System {
    init(scene _: RealityKit.Scene) {}

    // 왜 Static으로 설정하는가?
    /* ItemSystem의 모든 인스턴스가 동일한 쿼리(EntityQuery)를 공유하도록 하기 위함입니다.
     이렇게 하면 쿼리 객체가 한 번만 생성되고, 매번 시스템이 생성될 때마다 새로 만들 필요 없이 재사용할 수 있어 성능과 코드 효율성이 좋아집니다.
     즉, 쿼리가 시스템 전체에서 공통적으로 사용되는 "정적 자원"이기 때문에 static으로 선언합니다. */
    private static let query = EntityQuery(where: .has(ItemComponent.self))

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let itemComponent = entity.components[ItemComponent.self],
                  let target = itemComponent.targetEntity // 상호작용하려는 캐릭터 엔티티
//                  var modelComponent = entity.components[ModelComponent.self] // 현재 엔티티의 ModelComponent
            else { continue }

            // 1. 캐릭터와 아이템 사이 거리 계산
            let itemPosition = entity.transform.translation
            let characterPosition = target.transform.translation
            let distance = simd.distance(itemPosition, characterPosition)


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
    }
}

//
//  ItemComponent.swift
//  TtouchIsland
//
//  Created by 김현기 on 7/18/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import RealityKit

struct ItemComponent: Component {
    enum ItemType {
        case newspaper
        case food
    }

    // 아이템 종류
    var type: ItemType
    // 아이템 감지 거리
    var maxDistance: Float = 1.5
    // 아이템과의 거리를 추적할 엔티티
    var targetEntity: Entity?

    public init(type: ItemType, targetEntity: Entity? = nil) {
        self.type = type
        self.targetEntity = targetEntity

        Task {
            await ItemSystem.registerSystem()
            print("⚙️ ItemSystem Registered with type: \(type)")
        }
    }
}

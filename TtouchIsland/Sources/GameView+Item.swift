//
//  GameView+Item.swift
//  TtouchIsland
//
//  Created by 김현기 on 7/18/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import RealityKit
import SwiftUI

extension GameView {
    func setupItems(character: Entity, newspaper: Entity, content _: some RealityViewContentProtocol) {
        newspaper.components.set([
            ItemComponent(type: .newspaper, targetEntity: character),
            ModelComponent(mesh: .generateSphere(radius: 0.1), materials: [PhysicallyBasedMaterial()]),
        ])

        // 필요없는거 같긴함
        newspaper.components[CollisionComponent.self]?.mode = .trigger
        newspaper.components[CollisionComponent.self]?.filter = GameCollisionFilters.itemFilter
    }
}

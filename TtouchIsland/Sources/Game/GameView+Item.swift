//
//  GameView+Item.swift
//  TtouchIsland
//
//  Created by 김현기 on 7/18/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import CharacterMovement
import ControllerInput
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
}

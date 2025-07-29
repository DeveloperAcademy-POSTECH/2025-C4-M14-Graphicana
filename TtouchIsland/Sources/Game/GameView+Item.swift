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
        newspaper.components.set([
            ItemComponent(type: .newspaper, targetEntity: character),
        ])
        backpack.components.set([
            ItemComponent(type: .backpack, targetEntity: character),
        ])
        cheese.components.set([
            ItemComponent(type: .cheese, targetEntity: character),
        ])
        bottle.components.set([
            ItemComponent(type: .bottle, targetEntity: character),
        ])
        flashlight.components.set([
            ItemComponent(type: .flashlight, targetEntity: character),
        ])
        mapCompass.components.set([
            ItemComponent(type: .mapCompass, targetEntity: character),
        ])

        mapCompass.isEnabled = false
    }

    // TODO: 멍청코드 수정하기
    func playItemAnimations(game: Entity) {
        let items: [(entityName: String, animKey: String)] = [
            ("Backpack_Anim", "default subtree animation"),
            ("Bottle_Anim", "default subtree animation"),
            ("Flashlight_Anim", "default subtree animation"),
            ("Cheese_Anim", "default subtree animation"),
            ("MapCompass_Anim", "default subtree animation"),
        ]

        for (entityName, animKey) in items {
            guard let entity = game.findEntity(named: entityName),
                  let animLibrary = entity.components[
                      AnimationLibraryComponent.self
                  ],
                  let animation = animLibrary.animations[animKey]
            else { continue }
            let loopingAnimation = animation.repeat()
            entity.playAnimation(loopingAnimation, transitionDuration: 0.0)
        }
    }
}

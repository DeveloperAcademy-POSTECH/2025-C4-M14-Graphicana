//
//  StageComponent.swift
//  TtouchIsland
//
//  Created by 김현기 on 7/29/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import RealityKit

struct StageComponent: Component {
    enum StageType {
        case first
    }

    // 아이템 종류
    var type: StageType
    // 아이템 감지 거리
    var maxDistance: Float = 37.5
    // 경계선과의 거리를 추적할 엔티티
    var targetEntity: Entity?

    public init(type: StageType, targetEntity: Entity? = nil) {
        self.type = type
        self.targetEntity = targetEntity

        Task {
            await StageSystem.registerSystem()
            print("⚙️ StageSystem Registered with type: \(type)")
        }
    }
}

struct StageSystem: System {
    var manager = GameManager.shared

    init(scene _: RealityKit.Scene) {}

    private static let query = EntityQuery(where: .has(StageComponent.self))

    func update(context: SceneUpdateContext) {
        for entity in context.entities(
            matching: Self.query,
            updatingSystemWhen: .rendering
        ) {
            guard let stageComponent = entity.components[StageComponent.self],
                  let target = stageComponent.targetEntity // 상호작용하려는 캐릭터 엔티티
            else { continue }

            // 1. 캐릭터와 아이템 사이 거리 계산
            let stagePosition = entity.transform.translation
            let characterPosition = target.transform.translation
            let distance = simd.distance(stagePosition, characterPosition)

            if distance <= stageComponent.maxDistance {
                manager.currentSpeechStatus = .needNewspaper
                break
            }
        }
    }
}

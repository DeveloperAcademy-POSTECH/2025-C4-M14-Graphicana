import CharacterMovement
import Combine
import Foundation
import RealityKit
import SwiftUI

// import ControllerInput

extension GameView {
    func setupEnvironmentCollisions(
        on world: Entity,
        content _: any RealityViewContentProtocol
    ) async {
        // 맵 바운더리에 대하여 설정
        if let boundary = world.findEntity(named: "MapBoundary") {
            try? await boundary.generateStaticShapeResources(
                recursive: true,
                filter: GameCollisionFilters.terrainFilter
            ) // 맵은 플레이어나 적과만 충돌하도록 설정한 필터 적용
        }

        // 가방 먹기 전 길막용 바운더리
        if let stageBoundary = world.findEntity(named: "StageBoundary") {
            try? await stageBoundary.generateStaticShapeResources(
                recursive: true,
                filter: GameCollisionFilters.stageBoundaryFilter
            )
        }

        // 맵에 대하여 설정
        if let map = world.findEntity(named: "EnvironmentMap") {
            try? await map.generateStaticShapeResources(
                recursive: true,
                filter: GameCollisionFilters.terrainFilter
            )
        }
    }
}

extension Entity {
    // 충돌 모양을 생성하고 Collision, Physicsbody를 적용하는 함수
    func generateStaticShapeResources(
        recursive: Bool = true,
        filter: CollisionFilter
    ) async throws {
        var shapes: [ShapeResource] = []
        if let meshResource = components[ModelComponent.self]?.mesh {
            let shape = try await ShapeResource.generateStaticMesh(from: meshResource)
            let shiftedShape = shape.offsetBy(translation: [0, 0, -0.065])
            shapes.append(shiftedShape)
        }
        components.set([
            // collision 적용, static
            CollisionComponent(
                shapes: shapes,
                mode: .default,
                collisionOptions: .static,
                filter: filter
            ),
            // 물리바디 적용
            PhysicsBodyComponent(shapes: shapes, mass: 1, mode: .static),
        ])

        // 재귀적으로 하위 엔티티들까지 전부 같은 방식으로 콜리전, 물리 바디 세팅
        if recursive {
            for child in children {
                try await child.generateStaticShapeResources(
                    recursive: true,
                    filter: filter
                )
            }
        }
    }
}

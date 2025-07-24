/*
 See the LICENSE.txt file for this sample’s licensing information.

 Abstract:
 The component and system for moving an entity toward another entity.
 */

import RealityKit

/// A component that tells an entity to move toward another entity.
public class FollowComponent: Component {
    var smoothing: SIMD3<Float> = .one * 0.5
    let targetId: Entity.ID
    public var targetOverride: Entity.ID?
    public var cameraComponent: WorldCameraComponent? // 카메라와 타겟 간 거리

    public init(targetId: Entity.ID, smoothing: SIMD3<Float> = .one * 3, cameraComponent: WorldCameraComponent? = nil) {
        self.targetId = targetId
        self.smoothing = smoothing
        self.cameraComponent = cameraComponent
        Task {
            await FollowSystem.registerSystem()
        }
    }

    var currentTarget: Entity.ID { targetOverride ?? targetId }
}

/// A system that moves entities that have a follow component.
struct FollowSystem: System {
    init(scene _: Scene) {}

    @MainActor
    static let query = EntityQuery(where: .has(FollowComponent.self))

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let component = entity.components[FollowComponent.self],
                  let target = context.scene.findEntity(id: component.currentTarget),
                  var cameraComponent = entity.components[WorldCameraComponent.self]
            else { continue }

            // FollowComponent의 cameraComponent 값을 처음에만 사용
            if let initialCameraComponent = component.cameraComponent {
                cameraComponent.azimuth = initialCameraComponent.azimuth
                cameraComponent.elevation = initialCameraComponent.elevation
                cameraComponent.radius = initialCameraComponent.radius
                cameraComponent.bounds = initialCameraComponent.bounds

                // 사용 후 cameraComponent를 nil로 설정
                component.cameraComponent = nil
                entity.components.set(cameraComponent)
            }

            let targetPosition = target.position(relativeTo: entity.parent)

            entity.position = mix(entity.position, targetPosition,
                                  t: component.smoothing * Float(context.deltaTime))
        }
    }
}

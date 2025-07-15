import RealityKit
import WorldCamera

extension GameView {

    // 게임에서 월드 카메라 설정
    @discardableResult
    func setupWorldCamera(target: Entity) -> Entity {  // target: 카메라가 바라볼 목표 entity
        let elevationBounds: ClosedRange<Float> = (.zero)...(.pi / 3)  // 위아래로 움직일 수 있는 범위 (0 ~ 60도)
        let initialElevation: Float = .pi / 14  // 초기 카메라 각도 (약 12.8도)

        var worldCameraComponent = WorldCameraComponent(
            azimuth: .pi,  // 좌우 회전 (기본적으로 π = 180도 → 뒤에서 바라봄)
            elevation: initialElevation,  // 위쪽 각도
            radius: 3,  // 카메라가 target으로부터 떨어진 거리
            bounds: WorldCameraComponent.CameraBounds(
                elevation: elevationBounds
            )  // elevation 제한 범위
        )

        worldCameraComponent.targetOffset = [0, 0.5, 0]  // 오프셋 0.5로.. (오프셋이란.. 기준점으로부터의 위치 차이

        // Entity에 WorldCameraComponent와 FollowComponent를 붙임
        let worldCamera = Entity(
            components:
                worldCameraComponent,
            FollowComponent(targetId: target.id, smoothing: [3, 1.2, 3])  // 캐릭터 움직임을 따라감
        )
        worldCamera.name = "camera"
        worldCamera.addChild(Entity(components: PerspectiveCameraComponent()))  // RealityKit의 실제 렌더링 카메라 역할

        let simulationParent =
            PhysicsSimulationComponent.nearestSimulationEntity(for: target)
        worldCamera.setParent(simulationParent ?? target.parent)  // 물리 시뮬레이션을 사용하는 엔티티가 있다면 거기 붙이고 아니면 타켓의 부모로 붙임

        return worldCamera
    }
}

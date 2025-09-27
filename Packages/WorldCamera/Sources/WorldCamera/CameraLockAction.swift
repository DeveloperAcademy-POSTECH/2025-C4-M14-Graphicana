/*
 See the LICENSE.txt file for this sample’s licensing information.

 Abstract:
 An action that transitions and locks the camera and reverses it.
 */

import Foundation
import RealityKit

/// An action that transitions and locks the camera to a specific radius and orientation
/// before moving it back to its original pose.
///
/// This camera temporarily removes ``FollowComponent`` if the animating entity has one.
///
/// ```swift
/// let lockAction = CameraLockAction(
///     azimuth: azimuth,
///     elevation: 0,
///     radius: radius,
///     transitionIn: 1,
///     transitionOut: 1
/// )
///
/// CameraLockActionHandler.register { event in
///     CameraLockActionHandler()
/// }
///
/// let anim1 = try AnimationResource.makeActionAnimation(
///     for: lockAction, duration: 4
/// )
/// camera.playAnimation(anim1)
/// ```

/// 카메라의 위치와 방향(azimuth, elevation, radius, targetOffset)을 일정 시간 동안 부드럽게 전환(transition)하고,
/// 전환이 끝나면 원래 상태로 되돌리는 액션(CameraLockAction)을 정의
public struct CameraLockAction: EntityAction {
    public var animatedValueType: (any AnimatableData.Type)?

    /// 카메라가 이동할 목표 위치 및 방향(각도, 거리, 오프셋)
    // 카메라의 수평 회전 각도(방위각)를 나타냅니다.
    // 카메라가 기준점(예: 타겟) 주위를 수평으로 얼마나 회전했는지를 라디안(또는 도) 단위로 표현합니다
    public let azimuth: Float?
    public let elevation: Float?
    public let radius: Float?
    public let targetOffset: SIMD3<Float>?
    // 이동 시작/종료 시 부드럽게 전환되는 시간(초)
    public let transitionIn: TimeInterval
    public let transitionOut: TimeInterval

    public init(
        azimuth: Float?, elevation: Float?, radius: Float?, targetOffset: SIMD3<Float>?,
        transitionIn: TimeInterval = .zero, transitionOut: TimeInterval = .zero
    ) {
        CameraLockAction.registerAction()

        self.azimuth = azimuth
        self.elevation = elevation
        self.radius = radius
        self.targetOffset = targetOffset
        self.transitionIn = transitionIn
        self.transitionOut = transitionOut
    }

    // x에서 y로 t만큼 선형 보간(lerp)하여 중간값을 계산
    /*
     보간(Interpolation, 보간법)은 두 값 사이의 중간값을 계산하는 수학적 방법입니다.
     여기서 **선형 보간(lerp, linear interpolation)**은 두 값 \(x\)와 \(y\) 사이를 \(t\) (0~1)만큼 비율로 이동한 값을 구하는 방식입니다.

     예를 들어,
     - \(t = 0\)이면 \(x\) (시작값)
     - \(t = 1\)이면 \(y\) (끝값)
     - \(t = 0.5\)면 \(x\)와 \(y\)의 정확히 중간값

     ### 왜 필요한가?
     애니메이션, 카메라 이동, 색상 변화 등에서
     **시작값에서 끝값까지 부드럽게 변화**시키기 위해 사용합니다.
     즉, 한 번에 값이 확 바뀌지 않고, 시간에 따라 자연스럽게 변하도록 만드는 핵심 수단입니다.

     ### 예시
     - 카메라가 A 위치에서 B 위치로 1초 동안 이동할 때,
       0초~1초 사이의 모든 중간 위치를 선형 보간으로 계산해 부드럽게 이동시킴

     따라서, lerp는 **부드러운 전환**을 위해 꼭 필요한 기법입니다.
     */
    func transition(_ x: Float, _ y: Float, _ t: Float) -> Float {
        return (1 - t) * x + t * y
    }

    // 액션 시작 시점에서 전환 효과의 진행률(0~1)을 반환
    // (transitionIn 구간에서만 0→1로 증가, 그 외엔 1)
    func transitionInValue(normalizedTime: Double, eventDuration: Double) -> Float {
        if normalizedTime <= 0 {
            return 0.0
        } else if normalizedTime <= 1 && eventDuration > 0 {
            let normalizedDuration = transitionIn / eventDuration
            let fadeInNormalizedTime = Float(normalizedTime / normalizedDuration)
            let fadeInClampedTime = min(max(fadeInNormalizedTime, 0.0), 1.0)
            return fadeInClampedTime
        }

        return 1.0
    }

    // 액션 종료 시점에서 전환 효과의 진행률(1→0)을 반환
    // (transitionOut 구간에서만 1→0으로 감소, 그 외엔 1)
    func transitionOutValue(normalizedTime: Double, eventDuration: Double) -> Float {
        if normalizedTime >= 1 {
            return 0.0
        } else if normalizedTime >= 0 && eventDuration > 0 {
            let normalizedDuration = transitionOut / eventDuration
            let fadeOutNormalizedTime = Float((normalizedTime + normalizedDuration - 1) / normalizedDuration)
            let fadeOutClampedTime = min(max(fadeOutNormalizedTime, 0.0), 1.0)
            return 1 - fadeOutClampedTime
        }

        return 1.0
    }
}

// 카메라의 위치와 방향을 일시적으로 잠그고 원래 상태로 되돌리는 애니메이션 액션을 처리하는 핸들러(CameraLockActionHandler)
// 카메라 엔티티에 특정 뷰포인트(각도, 거리, 오프셋)로 부드럽게 이동시키고, 액션이 끝나면 원래 상태로 복원하는 역할
public struct CameraLockActionHandler: @preconcurrency ActionHandlerProtocol {
    // typealias란?
    // ActionHandlerProtocol을 준수하는 타입의 별칭을 정의
    public typealias ActionType = CameraLockAction
    // 액션 시작 시점의 카메라 상태(WorldCameraComponent)를 저장
    var originalComponent: WorldCameraComponent?
    // 액션 시작 시점에 카메라에 붙어있던 FollowComponent(자동 추적 기능)를 임시로 저장
    var followComponent: FollowComponent?

    public init() {}

    // 액션이 시작될 때 호출됨
    @MainActor
    public mutating func actionStarted(event: EventType) {
        guard let targetEntity = event.playbackController.entity else {
            return
        }
        if let followComponent = targetEntity.components[FollowComponent.self] {
            self.followComponent = followComponent
            targetEntity.components.remove(FollowComponent.self)
        }

        if let originalComponent = targetEntity.components[WorldCameraComponent.self] {
            self.originalComponent = originalComponent
        }
    }

    // 액션이 진행되는 동안 매 프레임마다 호출됨
    @MainActor
    public mutating func actionUpdated(event: EventType) {
        let action = event.action

        guard let targetEntity = event.playbackController.entity else {
            print("Handler for \(String(describing: ActionType.self)) failed to obtain target entity.")
            return
        }

        guard var component = targetEntity.components[WorldCameraComponent.self] else {
            print("""
            Handler for \(String(describing: ActionType.self)) failed to get world camera component
            from target entity named '\(targetEntity.name)'.
            """)
            return
        }

        guard let originalComponent else { return }

        // 애니메이션 진행률 계산
        var norm = event.playbackController.time / event.playbackController.duration
        norm = min(1, max(norm, 0))

        var animationPosition = action.transitionInValue(
            normalizedTime: norm, eventDuration: event.playbackController.duration
        )

        animationPosition *= action.transitionOutValue(
            normalizedTime: norm, eventDuration: event.playbackController.duration
        )

        if let azimuth = action.azimuth {
            component.azimuth = lerpFloat(originalComponent.azimuth, azimuth, animationPosition)
        }
        if let elevation = action.elevation {
            component.elevation = lerpFloat(originalComponent.elevation, elevation, animationPosition)
        }
        if let radius = action.radius {
            component.radius = lerpFloat(originalComponent.radius, radius, animationPosition)
        }
        if let targetOffset = action.targetOffset {
            component.targetOffset = simd_mix(
                originalComponent.targetOffset,
                targetOffset,
                .one * animationPosition
            )
        }

        targetEntity.components.set(component)
    }

    private func lerpFloat(_ a: Float, _ b: Float, _ t: Float) -> Float {
        a * (1 - t) + b * t
    }

    // 액션이 끝날 때 호출됨
    @MainActor
    public mutating func actionEnded(event: EventType) {
        if let originalComponent {
            event.playbackController.entity?.components.set(originalComponent)
        }
        if let followComponent {
            event.playbackController.entity?.components.set(followComponent)
        }
    }
}

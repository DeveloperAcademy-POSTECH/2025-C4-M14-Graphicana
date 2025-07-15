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
public struct CameraLockAction: EntityAction {
    public var animatedValueType: (any AnimatableData.Type)?

    public let azimuth: Float?
    public let elevation: Float?
    public let radius: Float?
    public let targetOffset: SIMD3<Float>?
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

    internal func transition(_ x: Float, _ y: Float, _ t: Float) -> Float {
        return (1 - t) * x + t * y
    }

    internal func transitionInValue(normalizedTime: Double, eventDuration: Double) -> Float {
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

    internal func transitionOutValue(normalizedTime: Double, eventDuration: Double) -> Float {
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

public struct CameraLockActionHandler: @preconcurrency ActionHandlerProtocol {
    public typealias ActionType = CameraLockAction
    var originalComponent: WorldCameraComponent?
    var followComponent: FollowComponent?

    public init() {}

    /// The function that the action calls at the beginning.
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
        var norm = event.playbackController.time / event.playbackController.duration
        norm = min(1, max(norm, 0))

        var animationPosition = action.transitionInValue(
            normalizedTime: norm, eventDuration: event.playbackController.duration)

        animationPosition *= action.transitionOutValue(
            normalizedTime: norm, eventDuration: event.playbackController.duration)

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

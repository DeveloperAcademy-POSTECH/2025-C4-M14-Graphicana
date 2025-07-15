/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Implements a RealityKit action for camera orientations in space.
*/

import RealityKit
import Foundation

public struct CameraOrientAction: EntityAction {
    public var animatedValueType: (any AnimatableData.Type)? { Float.self }

    var azimuth: Float?
    let elevation: Float?
    let radius: Float?
    let targetOffset: SIMD3<Float>?
    let target: Entity.ID?

    var transitionIn: TimeInterval
    var transitionOut: TimeInterval

    public init(
        transitionIn: TimeInterval,
        transitionOut: TimeInterval,
        azimuth: Float? = nil, elevation: Float? = nil,
        radius: Float? = nil, targetOffset: SIMD3<Float>? = nil,
        target: Entity.ID? = nil,
    ) {
        CameraOrientAction.registerAction()

        self.transitionIn = transitionIn
        self.transitionOut = transitionOut
        self.azimuth = azimuth
        self.elevation = elevation
        self.radius = radius
        self.targetOffset = targetOffset
        self.target = target
    }
}

extension ActionEvent where ActionType: EntityAction {
    @MainActor
    var timeNormal: Float {
        min(1, Float(self.playbackController.time / self.playbackController.duration))
    }
}

@MainActor
extension ActionEvent where ActionType == CameraOrientAction {
    fileprivate enum Stage {
        case transitionIn(TimeInterval)
        case waiting
        case transitionOut(TimeInterval)
    }

    fileprivate var currentStage: Stage {
        let currentTime = self.playbackController.time
        let totalDuration = self.playbackController.duration

        // Calculate adjusted durations, in case transitions are too long.
        let totalTransitionDuration = action.transitionIn + action.transitionOut
        let delayDuration = max(0, totalDuration - totalTransitionDuration)

        // Adjust transition durations proportionally if the total exceeds the available time.
        let adjustmentFactor = totalDuration < totalTransitionDuration
            ? totalDuration / totalTransitionDuration
            : 1

        let transitionInDuration = action.transitionIn * adjustmentFactor
        let transitionOutDuration = action.transitionOut * adjustmentFactor
        let transitionOutStartTime = transitionInDuration + delayDuration

        return switch currentTime {
        case ..<transitionInDuration: .transitionIn(currentTime / transitionInDuration)
        case ..<transitionOutStartTime: .waiting
        default: .transitionOut((currentTime - transitionOutStartTime) / transitionOutDuration)
        }
    }
}

public struct CameraOrientActionHandler: @preconcurrency ActionHandlerProtocol {
    public typealias ActionType = CameraOrientAction
    var originalAzimuth: Float?
    var originalElevation: Float?
    var originalRadius: Float?
    var originalTargetOffset: SIMD3<Float>?
    var originalTarget: Entity.ID?

    public init() {}

    @MainActor
    mutating public func actionStarted(event: EventType) {
        guard let targetEntity = event.playbackController.entity else {
            return
        }

        if let originalComponent = targetEntity.components[WorldCameraComponent.self] {
            self.originalAzimuth = originalComponent.azimuth
            self.originalElevation = originalComponent.elevation
            self.originalRadius = originalComponent.radius
            self.originalTargetOffset = originalComponent.targetOffset
            self.originalTarget = targetEntity.components[
                FollowComponent.self]?.targetId
        } else {
            print("""
            Handler for \(String(describing: ActionType.self)) failed to obtain
            original world camera component
            """)
        }
        if let target = event.action.target {
            targetEntity.components[FollowComponent.self]?.targetOverride = target
        }
    }

    @MainActor
    mutating public func actionUpdated(event: EventType) {
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

        let stagedNorm: Float
        switch event.currentStage {
        case .transitionIn(let norm):
            stagedNorm = Float(norm)
        case .waiting:
            stagedNorm = 1
        case .transitionOut(let norm):
            if event.playbackController.entity?.components[FollowComponent.self]?.targetOverride != nil {
                event.playbackController.entity?.components[FollowComponent.self]?.targetOverride = nil
            }
            stagedNorm = Float(1 - norm)
        }

        if let azimuth = action.azimuth, let originalAzimuth {
            component.azimuth = lerpAngleShortestPath(
                originalAzimuth, azimuth, t: stagedNorm)
        }
        if let elevation = action.elevation, let originalElevation {
            component.elevation = lerpFloat(
                originalElevation, elevation, t: stagedNorm)
        }
        if let radius = action.radius, let originalRadius {
            component.radius = lerpFloat(
                originalRadius, radius, t: stagedNorm)
        }
        if let targetOffset = action.targetOffset, let originalTargetOffset {
            component.targetOffset = mix(
                originalTargetOffset, targetOffset, t: stagedNorm)
        }

        targetEntity.components.set(component)
    }

    private func lerpFloat(_ a: Float, _ b: Float, t: Float) -> Float {
        a * (1 - t) + b * t
    }

    private func lerpAngleShortestPath(_ a: Float, _ b: Float, t: Float) -> Float {
        let twoPi: Float = .pi * 2
        var delta = (b - a).truncatingRemainder(dividingBy: twoPi)

        // Wrap delta to `[-π, π]`.
        if delta > .pi {
            delta -= twoPi
        } else if delta < -.pi {
            delta += twoPi
        }

        return a + delta * t
    }

    @MainActor
    mutating public func actionEnded(event: EventType) {}
}

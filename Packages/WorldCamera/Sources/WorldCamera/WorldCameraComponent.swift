/*
 See the LICENSE.txt file for this sample’s licensing information.

 Abstract:
 Implements a RealityKit component for cameras in a space.
 */

import Foundation
import RealityKit

/// A component that represents a camera in a space that orients around a spherical area.
public struct WorldCameraComponent: Component {
    /// The horizontal angle or direction of the camera from its center target.
    public var azimuth: Float
    /// The vertical angle of the camera from its center target.
    public var elevation: Float
    /// The distance of the camera from its center target.
    public var radius: Float

    public var targetOffset: SIMD3<Float> = .zero
    /// The containing scene that the system for this component moves.
    var worldParentId: Entity.ID?

    // SIMD3는 3차원 벡터를 표현하는 구조체로, 주로 3D 그래픽스에서 위치, 방향 등을 나타내는 데 사용됩니다.
    public internal(set) var continuousMotion: SIMD2<Float> = .zero

    public internal(set) var cameraVelocity: (linear: SIMD3<Float>, angular: SIMD3<Float>) = (.zero, .zero)

    public enum CameraFollowMode {
        case exact
    }

    public var followMode: CameraFollowMode = .exact
    public enum CameraMovementStyle {
        case instantaneous
        case smooth(Float) // recommend 3
    }

    public var isRealityKitCamera: Bool = true

    public var movementStyle: CameraMovementStyle = .instantaneous // .smooth(3)

    public struct CameraBounds {
        var azimuth: ClosedRange<Float>?
        var elevation: ClosedRange<Float>?
        var radius: ClosedRange<Float>?
        public init(
            azimuth: ClosedRange<Float>? = nil, elevation: ClosedRange<Float>? = nil,
            radius: ClosedRange<Float>? = nil
        ) {
            self.azimuth = azimuth
            self.elevation = elevation
            self.radius = radius
        }
    }

    public var bounds: CameraBounds?

    public init(azimuth: Float = 0, elevation: Float = 0, radius: Float = 1, bounds: CameraBounds? = nil) {
        self.azimuth = azimuth
        self.elevation = elevation
        self.radius = radius
        self.bounds = bounds
        Task { @MainActor in
            WorldCameraSystem.registerSystem()
        }
    }

    // azimuth, elevation 값을 이용해 카메라의 회전(quaternion) 반환
    // (y축으로 azimuth, x축으로 elevation 회전)
    public func cameraAxisOrientation() -> simd_quatf {
        simd_quatf(angle: -azimuth, axis: [0, 1, 0]) *
            simd_quatf(angle: -elevation, axis: [1, 0, 0])
    }

    // 지속적인 입력값을 저장(실제 각도 변경은 아님)
    public mutating func updateWith(continuousMotion: SIMD2<Float>) {
        self.continuousMotion = continuousMotion
    }

    // 조이스틱 입력에 따라 azimuth, elevation 값을 변경
    // bounds가 있으면 각도를 제한
    public mutating func updateWith(joystickMotion: SIMD2<Float>) {
        azimuth += joystickMotion.x / 50
        elevation -= joystickMotion.y / 50
        if let bounds {
            if let azimuthBounds = bounds.azimuth {
                azimuth = min(max(azimuthBounds.lowerBound, azimuth), azimuthBounds.upperBound)
            }
            if let elevationBounds = bounds.elevation {
                elevation = min(max(elevationBounds.lowerBound, elevation), elevationBounds.upperBound)
            }
        }
    }
}

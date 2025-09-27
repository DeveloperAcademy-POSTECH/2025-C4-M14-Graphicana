/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Implements a RealityKit component to lock cameras to a target entity.
*/

import RealityKit
import Foundation

public struct LockCameraComponent: Component {
    public let azimuth: Float?
    public let elevation: Float?
    public let radius: Float?
    public let targetOffset: SIMD3<Float>?
    public let target: Entity.ID?
    public init(
        azimuth: Float? = nil, elevation: Float? = nil,
        radius: Float? = nil, targetOffset: SIMD3<Float>? = nil,
        target: Entity.ID? = nil
    ) {
        self.azimuth = azimuth
        self.elevation = elevation
        self.radius = radius
        self.targetOffset = targetOffset
        self.target = target
    }
}

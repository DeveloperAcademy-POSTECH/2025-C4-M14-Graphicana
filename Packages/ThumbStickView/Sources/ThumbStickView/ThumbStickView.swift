/*
 See the LICENSE.txt file for this sample’s licensing information.

 Abstract:
 A view for thumbstick control.
 */

import RealityKit
import SwiftUI

/// A SwiftUI view that renders a virtual thumbstick control for directional input.
///
/// `ThumbStickView` displays a circular joystick-like UI with an outer boundary and a movable inner circle.
/// You can drag the inner circle to simulate directional input, and the view updates a bound `CGPoint`
/// representing the direction and magnitude of movement.
///
/// This is particularly useful in games, simulators, or any interactive app requiring analog-style input.
///
/// ```swift
/// @State private var joystickValue: CGPoint = .zero
///
/// var body: some View {
///     ThumbStickView(updatingValue: $joystickValue, radius: 60)
/// }
/// ```
///
/// The `updatingValue` binding updates with the offset from the center,
/// allowing you to interpret it as velocity, direction, and so forth.
///
/// - Note: The coordinate values in `updatingValue` are relative to the center of the joystick.
///   They reset to zero when the drag gesture ends.
///
/// - Parameters:
///   - updatingValue: A binding to a `CGPoint` that receives continuous updates based on user interaction.
///   - radius: The radius of the outer (static) circle. The inner circle automatically sets to half of this.
@available(iOS, introduced: 26.0)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(visionOS, unavailable)
public struct ThumbStickView: View {
    // MARK: - Properties

    private let outerRadius: CGFloat
    private let innerRadius: CGFloat

    @Binding private var updatingValue: CGPoint
    @State private var innerCircleOffset: CGPoint = .zero

    //    private var smallCircleCenter: CGPoint {
    //        CGPoint(x: largeRadius - smallerRadius, y: largeRadius - smallerRadius)
    //    }

    // MARK: - Initializer

    public init(updatingValue: Binding<CGPoint>, radius: CGFloat = 75) {
        outerRadius = radius
        innerRadius = radius / 2
        _updatingValue = updatingValue
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            // 외부 원
            Circle()
                .foregroundColor(.clear)
                .frame(width: outerRadius * 2, height: outerRadius * 2)
//                .glassEffect(.clear, in: .circle)

            // 내부 움직이는 원
            Circle()
                .foregroundColor(.clear)
                .background(.regularMaterial)
                .cornerRadius(innerRadius)
                .frame(width: innerRadius * 1.7, height: innerRadius * 1.7)
                .offset(x: innerCircleOffset.x, y: innerCircleOffset.y)
                .gesture(fingerDrag)
        }
        .onAppear { resetThumbstick() }
        .onChange(of: innerCircleOffset) { _, newValue in
            updatingValue = newValue
        }
    }

    // MARK: - Gesture

    private var fingerDrag: some Gesture {
        DragGesture(minimumDistance: 5)
            .onChanged { value in
                let translation = value.translation
                let distance = hypot(translation.width, translation.height)
                let angle = atan2(translation.height, translation.width)

                // 최대 이동거리 : 외부 원 반지름 - 내부 원 반지름
                let maxDistance = outerRadius - innerRadius
                let clampedDistance = min(distance, maxDistance)

                let newX = cos(angle) * clampedDistance
                let newY = sin(angle) * clampedDistance

                innerCircleOffset = CGPoint(x: newX, y: newY)
            }
            .onEnded { _ in resetThumbstick() }
    }

    // MARK: - Helpers

    private func resetThumbstick() {
        innerCircleOffset = .zero
    }
}

public struct CameraThumbStickView: View {
    // MARK: - Properties

    private let width: CGFloat
    private let height: CGFloat

    @Binding private var updatingValue: CGPoint
    @State private var innerLocation: CGPoint = .zero

    private var center: CGPoint {
        CGPoint(x: width / 2, y: height / 2)
    }

    // MARK: - Initializer

    public init(
        updatingValue: Binding<CGPoint>,
        width: CGFloat = UIScreen.main.bounds.width / 2, // width: 스크린의 절반
        height: CGFloat = UIScreen.main.bounds.height
    ) {
        self.width = width
        self.height = height
        _updatingValue = updatingValue
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            Color.clear
                // contentShape: hit testing 속성을 뷰에 적용하는 방법
                .contentShape(Rectangle())
                .foregroundColor(.clear)
                .frame(width: width, height: height)
                .gesture(CameraFingerDrag)
        }
        .onAppear { CameraResetThumbstick() }
        .onChange(of: innerLocation) { _, newValue in
            updatingValue = CGPoint(
                x: newValue.x - center.x,
                y: newValue.y - center.y
            )
        }
    }

    // MARK: - Gesture

    private var CameraFingerDrag: some Gesture {
        DragGesture(minimumDistance: 5)
            .onChanged { value in
                let translation = value.translation
                let distance = hypot(translation.width, translation.height)
                let angle = atan2(translation.height, translation.width)
                let maxDistance = center.x
                let clampedDistance = min(distance, maxDistance)

                let newX = cos(angle) * clampedDistance + maxDistance
                let newY = sin(angle) * clampedDistance + maxDistance

                innerLocation = CGPoint(x: newX, y: newY)
            }
            .onEnded { _ in CameraResetThumbstick() }
    }

    // MARK: - Helpers

    private func CameraResetThumbstick() {
        innerLocation = center
    }
}

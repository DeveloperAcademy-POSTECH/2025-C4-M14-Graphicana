/*
 See the LICENSE.txt file for this sample’s licensing information.

 Abstract:
 A view for thumbstick control.
 */

import RealityKit
import SwiftUI

import RealityKit

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
import SwiftUI

@available(iOS, introduced: 18.0)
public struct ThumbStickView: View {
    private let outerRadius: CGFloat
    private let innerRadius: CGFloat

    @Binding private var updatingValue: CGPoint
    @State private var offset: CGPoint = .zero
    @State private var dragging = false

    public init(updatingValue: Binding<CGPoint>, radius: CGFloat = 70) {
        _updatingValue = updatingValue
        outerRadius = radius
        innerRadius = radius / 2
    }

    public var body: some View {
        ZStack {
            // Track
            Circle()
                .fill(Color.black.opacity(0.25))
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.15),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: Color.black.opacity(0.35), radius: 6, y: 4)

            // Stick
            Circle()
                .fill(Color.white)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.4), radius: 5, y: 3)
                .shadow(color: Color.white.opacity(0.25), radius: 3)
                .frame(width: innerRadius * 1.55, height: innerRadius * 1.55)
                .scaleEffect(dragging ? 1.05 : 1.0)
                .animation(.easeOut(duration: 0.18), value: dragging)
                .offset(x: offset.x, y: offset.y)
                .gesture(dragGesture)
        }
        .frame(width: outerRadius * 2, height: outerRadius * 2)
        .contentShape(Circle())
        .onAppear { reset() }
        .onChange(of: offset) { _, newValue in
            updatingValue = newValue
        }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { value in
                if !dragging { dragging = true }
                let t = value.translation
                let dist = hypot(t.width, t.height)
                let angle = atan2(t.height, t.width)
                let limit = outerRadius - innerRadius
                let clamped = min(dist, limit)
                offset = CGPoint(
                    x: cos(angle) * clamped,
                    y: sin(angle) * clamped
                )
            }
            .onEnded { _ in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                    reset()
                    dragging = false
                }
            }
    }

    private func reset() { offset = .zero }
}

// 화면 전체 Pan 기반(카메라 등) 간결 버전
public struct CameraThumbStickView: View {
    private let width: CGFloat
    private let height: CGFloat
    @Binding private var updatingValue: CGPoint
    @State private var point: CGPoint = .zero
    @State private var dragging = false

    private var center: CGPoint { .init(x: width / 2, y: height / 2) }

    public init(
        updatingValue: Binding<CGPoint>,
        width: CGFloat = UIScreen.main.bounds.width / 2,
        height: CGFloat = UIScreen.main.bounds.height
    ) {
        _updatingValue = updatingValue
        self.width = width
        self.height = height
    }

    public var body: some View {
        Color.clear
            .contentShape(Rectangle())
            .gesture(dragGesture)
            .onAppear { reset() }
            .onChange(of: point) { _, p in
                updatingValue = CGPoint(x: p.x - center.x, y: p.y - center.y)
            }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { v in
                if !dragging { dragging = true }
                let t = v.translation
                let dist = hypot(t.width, t.height)
                let ang = atan2(t.height, t.width)
                let maxDist = center.x
                let clamp = min(dist, maxDist)
                point = CGPoint(
                    x: cos(ang) * clamp + center.x,
                    y: sin(ang) * clamp + center.x
                )
            }
            .onEnded { _ in
                withAnimation(.easeOut(duration: 0.25)) {
                    reset()
                    dragging = false
                }
            }
    }

    private func reset() { point = center }
}

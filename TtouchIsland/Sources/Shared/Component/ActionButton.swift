//
//  ActionButton.swift
//  TtouchIsland
//
//  Created by 김현기 on 7/26/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import SwiftUI

struct ActionButton: View {
    let name: String
    var size: CGFloat = 60
    var color: Color = .cyan
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Image(name)
                .resizable()
                .scaledToFit()
        }
        .buttonStyle(GameActionButtonStyle(size: size, color: color))
        .contentShape(Circle())
    }
}

struct GameActionButtonStyle: ButtonStyle {
    var size: CGFloat
    var color: Color

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed

        return ZStack {
            // 베이스(둥근 그라디언트)
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            color.opacity(0.9),
                            color.opacity(0.7),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                // 광택 하이라이트
                .overlay(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .center
                            )
                        )
                        .blur(radius: size * 0.08)
                )
                // 외곽 라인(메탈릭 테두리)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        .blendMode(.overlay)
                )

            // 버튼 라벨(아이콘)
            configuration.label
                .scaleEffect(pressed ? 0.96 : 1.0)
                .opacity(pressed ? 0.95 : 1.0)
        }
        .frame(width: size, height: size)
        .scaleEffect(pressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.18, dampingFraction: 0.75), value: pressed)
        .compositingGroup()
    }
}

#Preview {
    VStack(spacing: 24) {
        ActionButton(name: "InfoIcon", size: 70, color: .IconBG) {
            // 액션
        }
        ActionButton(name: "JumpIcon", size: 70, color: .IconBG)
        DisabledActionButton(name: "JumpIcon", size: 70)
        ActionButton(name: "JumpIcon", size: 60, color: .orange)
    }
    .padding()
}

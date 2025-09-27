//
//  DisabledActionButton.swift
//  TtouchIsland
//
//  Created by 김현기 on 7/29/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import SwiftUI

struct DisabledActionButton: View {
    let name: String
    var size: CGFloat = 60
    var color: Color = .gray

    var body: some View {
        ZStack {
            ActionButton(name: name, size: size, color: color)
                .brightness(-0.25)
                .saturation(0.0)
                .blur(radius: 0.5)
                .disabled(true)

            // 잠금 배지
            Circle()
                .fill(Color.black.opacity(0.55))
                .frame(width: size * 0.5, height: size * 0.5)
                .overlay(
                    Image(systemName: "lock.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * 0.22, height: size * 0.22)
                        .foregroundColor(.white.opacity(0.9))
                )
                .overlay(
                    Circle().stroke(Color.white.opacity(0.35), lineWidth: 1)
                )
        }
        .frame(width: size, height: size)
        .contentShape(Circle())
        .compositingGroup()
        .accessibilityLabel(Text("사용 불가"))
        .accessibilityHint(Text("잠금 상태"))
    }
}

#Preview {
    VStack(spacing: 24) {
        ActionButton(name: "RunIcon", size: 70, color: .cyan)
        DisabledActionButton(name: "RunIcon", size: 70, color: .cyan)
        DisabledActionButton(name: "JumpIcon", size: 86, color: .purple)
        DisabledActionButton(name: "JumpIcon", size: 60, color: .orange)
    }
    .padding()
}

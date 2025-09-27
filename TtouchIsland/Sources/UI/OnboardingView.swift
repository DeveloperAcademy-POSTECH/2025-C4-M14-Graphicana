//
//  OnboardingView.swift
//  TtouchIsland
//
//  Created by jiwon on 7/29/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import SwiftUI

struct OnboardingView: View {
    let manager: GameManager = .shared

    var body: some View {
        // 화면 크기를 가져와서 그거보다 조금 더 크게 설정
        let width: CGFloat = UIScreen.main.bounds.width + 10
        let height: CGFloat = UIScreen.main.bounds.height + 15

        ZStack(alignment: .bottom) {
            Color.black
                .opacity(0.7)
                .ignoresSafeArea()

            ZStack(alignment: .bottom) {
                Image("OnBoarding_fix")
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .ignoresSafeArea()

                Button {
                    manager.showOnboarding = false
                } label: {
                    Text("탐험 시작")
                        .foregroundStyle(.black)
                        .font(.system(size: 18, weight: .semibold))
                }
                .buttonStyle(ExploreWarmStyle())
//                .glassEffect(.regular.interactive())
                .padding(.bottom, 70)
                .padding(.leading, 450)
            }
        }
        .ignoresSafeArea()
    }
}

struct ExploreWarmStyle: ButtonStyle {
    var cornerRadius: CGFloat = 15

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed

        configuration.label
            .frame(minWidth: 150, minHeight: 60)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        Color(red: 1.00, green: 0.90, blue: 0.55)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
            .shadow(
                color: Color(red: 0.95, green: 0.45, blue: 0.35).opacity(0.30),
                radius: pressed ? 6 : 12,
                x: 0, y: pressed ? 3 : 8
            )
            .scaleEffect(pressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.12), value: pressed)
    }
}

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
                    Text("탐험 시작").foregroundStyle(Color.gray)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                }.glassEffect(.regular.interactive())
                    .padding(.bottom, 70)
                    .padding(.leading, 450)

            }
        }.ignoresSafeArea()
            .padding(.top, 25)
    }
}

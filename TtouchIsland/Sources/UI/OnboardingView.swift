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
    @State private var currentPageIndex = 0

    let onboardingImage = [
        "OnBoarding_1", "OnBoarding_2", "OnBoarding_3", "OnBoarding_4",
    ]

    var body: some View {
        // 화면 크기를 가져와서 그거보다 조금 더 크게 설정
        let width: CGFloat = UIScreen.main.bounds.width + 10
        let height: CGFloat = UIScreen.main.bounds.height + 15

        ZStack(alignment: .bottom) {
            TabView(selection: $currentPageIndex) {
                ForEach(0..<onboardingImage.count, id: \.self) {
                    i in
                    ZStack(alignment: .bottom) {
                        Image(onboardingImage[i])
                            .resizable()
                            .scaledToFill()
                            .frame(width: width, height: height)
                            .ignoresSafeArea()
                        if i == onboardingImage.count - 1 {
                            Button {
                                manager.showOnboarding = false
                            } label: {
                                Text("게임 시작").foregroundStyle(Color.gray)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 14)
                            }.glassEffect(.regular.interactive())
                                .padding(.bottom, 70)

                        }
                    }

                }
                // 기본 땡땡이 없애기
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                // 전체화면을 위한.. 발버둥
                .indexViewStyle(
                    PageIndexViewStyle(backgroundDisplayMode: .never)
                )
            // 커스텀 땡땡이바
            HStack(spacing: 8) {
                ForEach(0..<onboardingImage.count, id: \.self) { i in
                    Circle()
                        .fill(
                            i == currentPageIndex
                                ? Color.white : Color.gray.opacity(0.5)
                        )
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 40)
        }.ignoresSafeArea()
            .padding(.top, 25)
    }
}

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
        let width: CGFloat = UIScreen.main.bounds.width + 2
        let height: CGFloat = UIScreen.main.bounds.height + 2
        ZStack {
            Image("OnBoarding_1")
                .resizable()
                .scaledToFit()
                .frame(width: width, height: height)
                .ignoresSafeArea()

            Button {
                manager.showOnboarding = false
            } label: {
                Text("게임 시작")
            }
        }
    }
}

#Preview {
    OnboardingView()
}

//
//  LaunchView.swift
//  TtouchIsland
//
//  Created by jiwon on 7/27/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import Lottie
import SwiftUI

struct LaunchView: View {
    let height: CGFloat = UIScreen.main.bounds.height

    var body: some View {
        LottieView(animation: .named("LoadingLottie"))
            .playbackMode(.playing(.fromProgress(0, toProgress: 1, loopMode: .loop)))
            .resizable()
            .scaledToFill()
            .frame(height: height)
            .padding(.bottom, -20)
            .ignoresSafeArea()
    }
}

//
//  EndCreditsView.swift
//  TtouchIsland
//
//  Created by jiwon on 7/29/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import Lottie
import SwiftUI

struct EndCreditsView: View {
    let height: CGFloat = UIScreen.main.bounds.height

    var body: some View {
        LottieView(animation: .named("EndcreditsLottie"))
            .playbackMode(.playing(.fromProgress(0, toProgress: 1, loopMode: .playOnce)))
            .resizable()
            .scaledToFill()
            .frame(height: height)
            .padding(.bottom, -20)
            .ignoresSafeArea()
    }
}

#Preview {
    EndCreditsView()
}

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
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            LottieLaunchView(animationName: "LoadingScreen", loopMode: .loop)
        }
    }
}

// SwiftUI에서는 직접 UIView를 쓸 수 없어서 UIKit의 UIView를 SwiftUI에서 사용할 수 있게 해줌
struct LottieLaunchView: UIViewRepresentable {
    let animationName: String
    var loopMode: LottieLoopMode = .loop

    // UIKit뷰를 생성하고 초기화
    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: animationName)
        // 로티가 화면에 맞춰서 표시되도록 설정
        view.contentMode = .scaleAspectFit
        view.loopMode = loopMode
        view.play()
        // 생성한 Lottie 뷰를 SwiftUI에 넘겨줌
        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}

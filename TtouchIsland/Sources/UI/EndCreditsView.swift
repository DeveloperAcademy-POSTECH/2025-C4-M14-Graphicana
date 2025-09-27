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

struct LottieEndCreditsView: UIViewRepresentable {
    let animationName: String
    var loopMode: LottieLoopMode = .playOnce

    // UIKit뷰를 생성하고 초기화
    func makeUIView(context _: Context) -> UIView {
        // swift ui에서 사용할 UIView 컨테이너 생성(사이즈 조절용)
        let container = UIView()

        let view = LottieAnimationView(name: animationName)
        // 자동으로 리사이즈 되는 설정 off
        // (UIKit에서는 기본적으로 뷰가 자체 크기를 가지게 되는데, 이걸 끄지 않으면 SwiftUI의 .frame() 제약이 무시됩니다.)
        view.translatesAutoresizingMaskIntoConstraints = false

        // 로티가 화면에 맞춰서 표시되도록 설정
        view.contentMode = .scaleAspectFit
        view.loopMode = loopMode
        view.play()

        // 로티뷰를 컨테이너에 넣음
        container.addSubview(view)

        // SwiftUI 프레임에 따라 Lottie 뷰가 정확히 맞춰지도록 AutoLayout 제약을 설정
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            view.topAnchor.constraint(equalTo: container.topAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        return container
    }

    func updateUIView(_: UIView, context _: Context) {}
}

#Preview {
    EndCreditsView()
}

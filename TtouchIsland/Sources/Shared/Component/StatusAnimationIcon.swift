//
//  StatusAnimationIcon.swift
//  TtouchIsland
//
//  Created by 김현기 on 7/26/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import Lottie
import SwiftUI

struct StatusAnimationIcon: View {
    let file: String
    let isLoop: Bool = false

    var body: some View {
        LottieView(animation: .named(file))
            .playbackMode(.playing(.fromProgress(0, toProgress: 1, loopMode: isLoop ? .loop : .playOnce)))
            .frame(width: 100, height: 100)
    }
}

#Preview {
    StatusAnimationIcon(file: "TtouchMouse_Happy")
}

//
//  GameStatusView.swift
//  TtouchIsland
//
//  Created by 김현기 on 7/24/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import Lottie
import SwiftUI

struct GameStatusView: View {
    let appModel: GameManager = .shared

    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 0) {
                StatusAnimationIcon(file: "TtouchMouse_Basic")

                if !appModel.isFocusedOnItem {
                    StatusAnimationItems()
                }

                Spacer()
            }

            Spacer()
        }
        .padding(.top, 6)
        .padding(.leading, 36)
        .ignoresSafeArea()
    }
}

#Preview {
    GameStatusView()
}

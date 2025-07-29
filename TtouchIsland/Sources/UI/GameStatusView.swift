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
    let manager: GameManager = .shared

    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack(alignment: .top, spacing: 0) {
                StatusAnimationIcon(file: manager.currentActStatus.filename, isLoop: manager.currentActStatus.isLoop)

                if !manager.isFocusedOnItem {
                    StatusAnimationItems()
                }
            }
            if manager.currentSpeechStatus != .none {
                CharacterSpeechBallon(file: manager.currentSpeechStatus.filename)
                    .padding(.leading, 60)
                    .padding(.top, 70)
            }
        }
    }
}

#Preview {
    GameStatusView()
}

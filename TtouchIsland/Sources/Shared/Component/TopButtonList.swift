//
//  TopButtonList.swift
//  TtouchIsland
//
//  Created by 김현기 on 9/27/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import SwiftUI

struct TopButtonList: View {
    let manager = GameManager.shared

    @Binding var showResetAlert: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Info
            if manager.showInfoButton {
                ActionButton(
                    name: "InfoIcon",
                    size: 40,
                    color: .IconBG
                ) {
                    manager.showOnboarding = true
                }
            }

            // Reset
            if manager.showResetButton {
                ActionButton(
                    name: "ResetIcon",
                    size: 40,
                    color: .IconBG
                ) {
                    showResetAlert = true
                }
            }
        }
    }
}

#Preview {
    TopButtonList(showResetAlert: .constant(false))
}

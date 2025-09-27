//
//  InfoButton.swift
//  TtouchIsland
//
//  Created by jiwon on 8/15/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import SwiftUI

struct InfoButton: View {
    let manager = GameManager.shared
    var body: some View {
        VStack {
            HStack {
                Button {
                    manager.showOnboarding = true
                } label: {
                    ActionButton(name: "InfoIcon")
                }
                .scaleEffect(0.6)
            }
            .padding(.top, 30)
            .padding(.leading, 600)
            Spacer()
        }
    }
}

#Preview {
    InfoButton()
}

//
//  DisabledActionButton.swift
//  TtouchIsland
//
//  Created by 김현기 on 7/29/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import SwiftUI

struct DisabledActionButton: View {
    let name: String

    var body: some View {
        ZStack {
            Image(name)
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .glassEffect(.regular.interactive())
                .opacity(0.5)

            // 잠금 아이콘 추가
            Image(systemName: "lock.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    DisabledActionButton(name: "Disabled_Action_Button")
}

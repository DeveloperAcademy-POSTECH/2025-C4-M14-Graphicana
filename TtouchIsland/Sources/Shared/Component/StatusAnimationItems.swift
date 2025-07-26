//
//  StatusAnimationItems.swift
//  TtouchIsland
//
//  Created by 김현기 on 7/26/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import SwiftUI

struct StatusAnimationItems: View {
    let manager = GameManager.shared

    var body: some View {
        ZStack {
            // 배경 사각형
            if !manager.visibleItems.isEmpty {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.white, lineWidth: 2)
                    .fill(.gray)
                    .opacity(0.5) // 배경 투명도 설정
                    .frame(width: CGFloat(manager.visibleItems.count) * 54.0 + 20, height: 60)
            }

            // 아이템들
            HStack(alignment: .center, spacing: 4) {
                ForEach(manager.visibleItems, id: \.solidImageName) { item in item }
            }
        }
        .padding(.top)
    }
}

#Preview {
    StatusAnimationItems()
}

//
//  GameStatusView.swift
//  TtouchIsland
//
//  Created by 김현기 on 7/24/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import SwiftUI

struct GameStatusView: View {
    let appModel: AppModel = .shared

    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 20) {
                statusIcon(
                    solidImageName: "backpack",
                    size: CGSize(width: 80, height: 80)
                )
                if appModel.displayAllItemsVisible && !appModel.isFocusedOnItem {
                    statusIcon(
                        solidImageName: "backpack",
                        outlinedImageName: "backpack",
                        size: CGSize(width: 70, height: 70),
                        isSolid: false
                    )
                    statusIcon(
                        solidImageName: "backpack",
                        outlinedImageName: "backpack",
                        size: CGSize(width: 70, height: 70),
                        isSolid: false
                    )
                }
                Spacer()
            }
            Spacer()
        }
        .padding(.vertical)
    }

    fileprivate func statusIcon(solidImageName: String, outlinedImageName: String? = nil, size: CGSize, isSolid: Bool = true) -> some View {
        Image(isSolid ? solidImageName : outlinedImageName ?? solidImageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size.width, height: size.height)
    }
}

#Preview {
    GameStatusView()
}

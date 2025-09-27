//
//  CloseNewspaper.swift
//  TtouchIsland
//
//  Created by 김현기 on 7/28/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import RealityKit
import SwiftUI

struct CloseNewspaperComponent: View {
    let manager = GameManager.shared
    let itemAction: (Entity, Entity) -> Void

    var body: some View {
        Button(action: {
            // 뒤로가기 액션 호출
            if let item = manager.nearItem,
               let camera = manager.gameCamera
            {
                itemAction(item, camera)
            }
        }) {
            Image(systemName: "xmark")
                .frame(width: 36, height: 36)
                .foregroundColor(.black)
                .font(.system(size: 24))
//                .glassEffect(.regular.interactive())
        }
        .padding()
    }
}

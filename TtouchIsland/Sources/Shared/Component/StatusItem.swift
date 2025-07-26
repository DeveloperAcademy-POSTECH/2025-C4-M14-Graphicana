//
//  StatusItem.swift
//  TtouchIsland
//
//  Created by 김현기 on 7/26/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import SwiftUI

struct StatusItem: View {
    let solidImageName: String
    let outlinedImageName: String
    let size: CGFloat
    let isSolid: Bool

    init(solidImageName: String, outlinedImageName: String, size: CGFloat = 50.0, isSolid: Bool) {
        self.solidImageName = solidImageName
        self.outlinedImageName = outlinedImageName
        self.size = size
        self.isSolid = isSolid
    }

    var body: some View {
        Image(isSolid ? solidImageName : outlinedImageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size)
    }
}

#Preview {
    StatusItem(
        solidImageName: "Backpack",
        outlinedImageName: "Backpack_Outline",
        isSolid: false
    )
}

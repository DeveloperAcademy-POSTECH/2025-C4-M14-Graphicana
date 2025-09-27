//
//  ActionButton.swift
//  TtouchIsland
//
//  Created by 김현기 on 7/26/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import SwiftUI

struct ActionButton: View {
    let name: String

    var body: some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: 70, height: 70)
            .glassEffect(.regular.interactive())
    }
}

#Preview {
    ActionButton(name: "JumpIcon")
}

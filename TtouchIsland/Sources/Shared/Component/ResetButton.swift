//
//  ResetButton.swift
//  TtouchIsland
//
//  Created by jiwon on 8/15/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import SwiftUI

struct ResetButton: View {
    var action: () -> Void
    var body: some View {
        VStack {
            HStack {
                Spacer()

                Button(action: action) {
                    ActionButton(name: "ResetIcon")
                        .scaleEffect(0.7)
                }
            }
            .padding(.all, 30)
            Spacer()
        }
    }
}

#Preview {
    ResetButton(action: {})
}

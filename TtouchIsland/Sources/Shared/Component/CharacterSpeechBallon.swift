//
//  CharacterSpeechBallon.swift
//  TtouchIsland
//
//  Created by 김현기 on 7/29/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import Lottie
import SwiftUI

struct CharacterSpeechBallon: View {
    let file: String

    let manager = GameManager.shared

    var body: some View {
        LottieView(animation: .named(file))
            .playbackMode(.playing(.fromProgress(0, toProgress: 1, loopMode: .playOnce)))
            .animationDidFinish { completed in
                if completed {
                    // 다시 CharacterSpeech를 표시하지 않도록 설정
                    manager.currentSpeechStatus = .none
                }
            }
            .resizable()
            .frame(width: 300, height: 100, alignment: .leading) // 크기 조정 및 왼쪽 정렬
            .padding(.leading, 10) // 왼쪽 여백 추가
    }
}

#Preview {
    CharacterSpeechBallon(file: "Speech_Bag")
}

//
//  GameCenterManager.swift
//  TtouchIsland
//
//  Created by jiwon on 8/25/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import Foundation
import GameKit
import SwiftUI

class GameCenterManager: ObservableObject {

    static let shared = GameCenterManager()

    private init() {}

    @Published var isAuthenticated = false
    @Published var achievements = [GKAchievement]()

    func authenticatePlayer() {
        let player = GKLocalPlayer.local

        player.authenticateHandler = { viewController, error in
            if let controller = viewController {
                UIApplication.shared.windows.first?.rootViewController?.present(
                    controller,
                    animated: true,
                    completion: nil
                )
            } else if player.isAuthenticated {
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                    print("Game Center 인증 성공")
                }
            } else {
                print(
                    "Game Center 인증 실패: \(error?.localizedDescription ?? "Unknown error")"
                )
            }
        }
    }

    func reportAchievement(identifier: String, percentComplete: Double) {
        let achievement = GKAchievement(identifier: identifier)
        achievement.percentComplete = percentComplete
        achievement.showsCompletionBanner = true

        GKAchievement.report([achievement]) { error in
            if let error {
                print("업적 보고 실패: \(error.localizedDescription)")
                return
            }

            print("업적이 성공적으로 보고되었습니다.")
        }
    }
}

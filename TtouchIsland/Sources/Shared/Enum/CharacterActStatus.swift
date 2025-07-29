//
//  CharacterStatus.swift
//  TtouchIsland
//
//  Created by 김현기 on 7/27/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import Foundation

public enum CharacterActStatus: String, CaseIterable {
    case common = "TtouchMouse_Basic"
    case jump = "TtouchMouse_Jump"
    case run = "TtouchMouse_Run"
    case getItem = "TtouchMouse_Happy"
    case read = "TtouchMouse_News"

    var filename: String { rawValue }

    var isLoop: Bool {
        switch self {
        case .common, .run, .read:
            return true
        case .jump, .getItem:
            return false
        }
    }
}

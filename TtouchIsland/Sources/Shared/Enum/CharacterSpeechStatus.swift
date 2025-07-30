//
//  CharacterSpeechStatus.swift
//  TtouchIsland
//
//  Created by 김현기 on 7/29/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

public enum CharacterSpeechStatus: String, CaseIterable {
    case none = ""
    case getBag = "Speech_Bag"
    case getBottle = "Speech_Bottle"
    case getCheeze = "Speech_Cheeze"
    case getFlashlight = "Speech_Flashlight"
    case getMap = "Speech_Map"
    case needBag = "Speech_NeedBag"
    case needNewspaper = "Speech_NeedNewspaper"

    var filename: String { rawValue }
}

//
//  Settings.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 02/11/2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import Foundation
import CoreGraphics

struct ImageScrollSettings {
    static let maxZoom:CGFloat = 5.0
    static let minZoom:CGFloat = 0.1
}

struct EmojiSettings {
    static let DefaultEmoji = "😀😋😡😱🐱🐴🐝🐥🐟🐉🍔🍎".map{ String($0)}
}

struct SegueSettings {
    static let PresentDynamicCollection = "presentDynamicCollection"
    static let PresentCompositeImage = "presentCompositeImage"
    static let PresentModallyStats = "presentStats"
}

struct DocumentStatsSettings {
    static let HorizontalPadding: CGFloat = 30.0
    static let VerticalPadding: CGFloat = 30.0
}

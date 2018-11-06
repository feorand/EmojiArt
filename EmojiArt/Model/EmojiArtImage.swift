//
//  EmojiArtImage.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 06/11/2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import Foundation

class EmojiArtImage: Codable {
    var emoji: [EmojiInfo] = []
    var backgroundImageData: Data?
}

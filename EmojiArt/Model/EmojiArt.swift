//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 06/11/2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import Foundation

// Type for storing all data of app's state
// Currently it's an emoji image and a list of available emoji
class EmojiArt: Codable {
    var image = EmojiArtImage()
}

//
//  EmojiArtImage.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 06/11/2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import Foundation

//Type for storing data of an image, composing of a background and a list of emoji on top of it
class EmojiArtImage: Codable {
    var emoji: [EmojiInfo] = []
    var backgroundImageData: Data? = nil
}

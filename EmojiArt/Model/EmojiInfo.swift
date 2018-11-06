//
//  EmojiInfo.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 06/11/2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import Foundation

//Type for storing data of a particular Emoji symbol
struct EmojiInfo: Codable {
    var x: Float
    var y: Float
    let symbol: String
    var size: Int
}

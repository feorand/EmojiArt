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
struct EmojiArt: Codable {
    var image = EmojiArtImage()
    
    init(emoji: [String] = [], image: EmojiArtImage = EmojiArtImage()) {
        self.image = image
    }
    
    init?(fromJson json: Data) {
        if let newEmojiArt = try? JSONDecoder().decode(EmojiArt.self, from: json) {
            self = newEmojiArt
        }
        
        return nil
    }
    
    func json() -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try! encoder.encode(self)
    }
}

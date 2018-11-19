//
//  FileManager+Extension.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 06/11/2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import Foundation

extension FileManager {
    // URL for Application Support directory
    static var ApplicationSupportDirectoryURL: URL {
        return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    }
}

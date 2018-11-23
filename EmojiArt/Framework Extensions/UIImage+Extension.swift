//
//  UIImage+Extension.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 14/11/2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import UIKit

extension UIImage {
    convenience init?(fromOptionalData data: Data?) {
        if let data = data {
            self.init(data: data)
        } else {
            return nil
        }
    }
}

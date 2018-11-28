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
    
    func scaled(by factor: CGFloat) -> UIImage? {
        let newSize = CGSize(width: size.width * factor, height: size.height * factor)
        UIGraphicsBeginImageContext(newSize)
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage
    }
}

//
//  EmojiInfo+Extension.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 14/11/2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import UIKit

extension EmojiInfo {
    init(fromAttributedString attrString: NSAttributedString, andPosition position: CGPoint) {
        x = Float(position.x)
        y = Float(position.y)
        symbol = attrString.string
        
        let font = attrString.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
        let uiSize = font?.pointSize ?? UIFont.systemFontSize
        size = Float(uiSize)
    }
    
    var attributedString: NSAttributedString {
        let attributes = [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: CGFloat(size))
        ]
        
        return NSAttributedString(string: symbol, attributes: attributes)
    }
    
    var position: CGPoint {
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
}

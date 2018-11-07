//
//  BackgroundView.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 23.02.2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import UIKit

class CompositeImageView: UIView
{
    private(set) var background: UIImage? { didSet { setNeedsDisplay() } }
    
    var symbols: [UILabel] {
        get {
            return _symbols
        }
    }
    
    private var _symbols: [UILabel] = [] { didSet { setNeedsLayout() }}
    
    func addSymbol(_ symbol: NSAttributedString, position: CGPoint) {
        let symbolLabel = UILabel()
        symbolLabel.attributedText = symbol
        symbolLabel.backgroundColor = .clear
        symbolLabel.sizeToFit()
        symbolLabel.center = position
        addSubview(symbolLabel)
        _symbols.append(symbolLabel)
    }
    
    func changeBackgroundImage(to image: UIImage?) {
        background = image
        frame = CGRect(origin: CGPoint.zero, size: image?.size ?? CGSize.zero)
    }
    
    override func draw(_ rect: CGRect) {
        background?.draw(in: bounds)
    }
    
}

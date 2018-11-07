//
//  CompositeImageViewControllerDelegate.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 06/11/2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import UIKit

protocol CompositeImageViewControllerDelegate {
    
    func compositeImageVCDidChangeBackground(to image: UIImage?)
    
    func compositeImageVCDidAddSymbol(_ symbol: NSAttributedString, position: CGPoint)
}

extension CompositeImageViewControllerDelegate {
    
    func compositeImageVCDidChangeBackground(to image: UIImage?) {
        // Optional method
    }
    
    func compositeImageVCDidAddSymbol(_ symbol: NSAttributedString, position: CGPoint) {
        // Optional method
    }
}

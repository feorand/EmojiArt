//
//  CompositeImageViewControllerDelegate.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 06/11/2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import UIKit

protocol CompositeImageViewControllerDelegate {
    func backgroundImageChanged(to image: UIImage?)
    func addedSymbol(_ symbol: NSAttributedString, position: CGPoint)
}

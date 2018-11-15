//
//  CompositeImageViewControllerDelegate.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 06/11/2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import UIKit

protocol CompositeImageViewControllerDelegate {
    
    func compositeImageVCDidUpdateImage(_ compositeImage: (image: UIImage?, symbols: [UILabel]))
}

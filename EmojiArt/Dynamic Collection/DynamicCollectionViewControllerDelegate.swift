//
//  DynamicCollectionViewControllerDelegate.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 14/11/2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import UIKit

protocol DynamicCollectionViewControllerDelegate {
    func dynamicCollectionVCDidUpdateItems(_ items: [String])
}

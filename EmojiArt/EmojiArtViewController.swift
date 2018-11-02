//
//  ViewController.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 23.02.2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import UIKit

class EmojiArtViewController: UIViewController
{
    var emojiCollectionViewController: DynamicCollectionViewController!
        
    override func viewDidLoad() {
        guard let firstChild = children.first as? DynamicCollectionViewController else {
            fatalError("StoryBoard - missing connection to DynamicCollectionVC")
        }
        
        emojiCollectionViewController = firstChild
    }
}

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
    
    var dropZoneViewController: CompositeImageViewController!
        
    override func viewDidLoad() {
        guard let firstChild = children.first as? DynamicCollectionViewController else {
            fatalError("Storyboard - missing connection to DynamicCollectionVC")
        }
        
        guard let secondChild = children.last as? CompositeImageViewController else {
            fatalError("Storyboard - missing connection to CompositeImageVC")
        }
        
        emojiCollectionViewController = firstChild
        dropZoneViewController = secondChild
    }
}

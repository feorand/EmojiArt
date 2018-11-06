//
//  ViewController.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 23.02.2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import UIKit

class EmojiArtViewController: UIViewController, CompositeImageViewControllerDelegate
{
    var emojiCollectionViewController: DynamicCollectionViewController!
    
    var resultImageViewController: CompositeImageViewController!
        
    override func viewDidLoad() {
        guard let firstChild = children.first as? DynamicCollectionViewController else {
            fatalError("Storyboard - missing connection to DynamicCollectionVC")
        }
        
        guard let secondChild = children.last as? CompositeImageViewController else {
            fatalError("Storyboard - missing connection to CompositeImageVC")
        }
        
        emojiCollectionViewController = firstChild
        resultImageViewController = secondChild
        
        resultImageViewController.delegate = self
    }
    
    //MARK:- CompositeImageViewControllerDelegate methods
    
    func compositeImageVCDidChangeBackground(
        _ controller: CompositeImageViewController,
        to image: UIImage?) {
        
        print("New image load")
    }
    
    func compositeImageVCDidAddSymbol(
        _ controller: CompositeImageViewController,
        _ symbol: NSAttributedString,
        position: CGPoint) {
        
        print("Added emoji \(symbol.string)")
    }
}

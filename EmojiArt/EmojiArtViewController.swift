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
    //MARK:- Properties
    
    var emojiSource = EmojiArt()
    
    var emojiCollectionViewController: DynamicCollectionViewController!
    
    var resultImageViewController: CompositeImageViewController!
    
    //MARK:- ViewController life cycle
    
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

        emojiSource.image.backgroundImageData = image?.pngData()
    }
    
    func compositeImageVCDidAddSymbol(
        _ controller: CompositeImageViewController,
        _ symbol: NSAttributedString,
        position: CGPoint) {

        let emojiInfo = EmojiInfo(
            x: Float(position.x),
            y: Float(position.y),
            symbol: symbol.string,
            size: Int(symbol.size().height)
        )
        
        emojiSource.image.emoji.append(emojiInfo)
    }
}

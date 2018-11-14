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
    
    var currentEmojiArt = EmojiArt() {
        didSet {
            self.emojiImageVC.image = UIImage(fromOptionalData: self.document.emojiArt?.image.backgroundImageData)
            
            for emoji in self.document.emojiArt?.image.emoji ?? [] {
                self.emojiImageVC.addSymbol(symbol: emoji.attributedString, inPosition: emoji.position)
            }
        }
    }
    
    var document: EmojiArtDocument!
    
    var emojiImageVC: CompositeImageViewController!
    
    //MARK:- ViewController life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let secondChild = children.last as? CompositeImageViewController else {
            fatalError("Storyboard - missing connection to CompositeImageVC")
        }
        
        emojiImageVC = secondChild
        emojiImageVC.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        document.open() {success in
            if success {
                self.title = self.document.localizedName
                
                if let emojiArt = self.document.emojiArt {
                    self.currentEmojiArt = emojiArt
                }
            }
        }
    }
    
    //MARK:- Actions
    
    @IBAction func saveButtonPressed() {
        //TODO: change to using incremental auto-save
        document.emojiArt = currentEmojiArt
        
        if document.emojiArt != nil {
            document.save(to: document.fileURL, for: .forOverwriting)
        }
    }
    
    @IBAction func doneButtonPressed() {
        //TODO: change to using incremental auto-save
        document.emojiArt = currentEmojiArt
        
        if document.emojiArt != nil {
            document.save(to: document.fileURL, for: .forOverwriting) { [weak self] success in
                self?.dismiss(animated: true)
            }
        }
    }
    
    //MARK:- CompositeImageViewControllerDelegate methods
    
    func compositeImageVCDidChangeBackground(to image: UIImage?) {
        currentEmojiArt.image.backgroundImageData = image?.pngData()
    }
    
    func compositeImageVCDidAddSymbol(_ symbol: NSAttributedString, position: CGPoint) {
        let emojiInfo = EmojiInfo(fromAttributedString: symbol, andPosition: position)
        currentEmojiArt.image.emoji.append(emojiInfo)
    }    
}

//
//  ViewController.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 23.02.2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import UIKit

class EmojiArtViewController: UIViewController, CompositeImageViewControllerDelegate, DynamicCollectionViewControllerDelegate
{
    //MARK:- Properties
    
    var currentEmojiArt = EmojiArt() {
        didSet {
            possibleEmojiVC.source = currentEmojiArt.possibleEmoji
            
            emojiImageVC.image = UIImage(fromOptionalData: currentEmojiArt.image.backgroundImageData)
            
            for emoji in currentEmojiArt.image.emoji {
                emojiImageVC.addSymbol(symbol: emoji.attributedString, inPosition: emoji.position)
            }
        }
    }
    
    var document: EmojiArtDocument!
    
    var possibleEmojiVC: DynamicCollectionViewController!
    
    var emojiImageVC: CompositeImageViewController!
    
    //MARK:- ViewController life cycle
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        document.open() {success in
//            if success {
//                self.title = self.document.localizedName
//
//                if let emojiArt = self.document.emojiArt {
//                    self.currentEmojiArt = emojiArt
//                }
//            }
//        }
//    }
    
    override func loadView() {
        super.loadView()
        
        document.open() {success in
            if success {
                self.title = self.document.localizedName
                self.currentEmojiArt = self.document.emojiArt
            }
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueSettings.PresentDynamicCollection {
            if let dynamicCollectionVC = segue.destination as? DynamicCollectionViewController {
                possibleEmojiVC = dynamicCollectionVC
                possibleEmojiVC.delegate = self
            }
        } else if segue.identifier == SegueSettings.PresentCompositeImage {
            if let compositeImageVC = segue.destination as? CompositeImageViewController {
                emojiImageVC = compositeImageVC
                emojiImageVC.delegate = self
            }
        }
    }
    
    //MARK:- Actions
    
    @IBAction func saveButtonPressed() {
        //TODO: change to using incremental auto-save
        document.emojiArt = currentEmojiArt
        document.save(to: document.fileURL, for: .forOverwriting)
    }
    
    @IBAction func doneButtonPressed() {
        //TODO: change to using incremental auto-save
        document.emojiArt = currentEmojiArt
        
        document.save(to: document.fileURL, for: .forOverwriting) { [weak self] success in
            self?.dismiss(animated: true)
        }
    }
    
    //MARK:- CompositeImageVCDelegate methods
    
    func compositeImageVCDidChangeBackground(to image: UIImage?) {
        currentEmojiArt.image.backgroundImageData = image?.pngData()
    }
    
    func compositeImageVCDidAddSymbol(_ symbol: NSAttributedString, position: CGPoint) {
        let emojiInfo = EmojiInfo(fromAttributedString: symbol, andPosition: position)
        currentEmojiArt.image.emoji.append(emojiInfo)
    }
    
    //MARK:- DynamicCollectionVCDelegate methods
    
    func dynamicCollectionVCDidUpdateItems(_ items: [String]) {
        if currentEmojiArt.possibleEmoji != items {
            currentEmojiArt.possibleEmoji = items
        }
    }
}

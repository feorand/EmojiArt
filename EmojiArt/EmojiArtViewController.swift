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
    
    var currentEmojiArt = EmojiArt()
    
    var document: EmojiArtDocument!
    
    var possibleEmojiVC: DynamicCollectionViewController!
    
    var emojiImageVC: CompositeImageViewController!
    
    //MARK:- ViewController life cycle
    
    override func loadView() {
        super.loadView()
        
        document.open() {[weak self] success in
            if success {
                self?.title = self!.document.localizedName
                self?.currentEmojiArt = self!.document.emojiArt
                
                self?.possibleEmojiVC.source = self!.currentEmojiArt.possibleEmoji
                self?.possibleEmojiVC.collectionView.reloadData()
                
                self?.emojiImageVC.image = UIImage(fromOptionalData: self!.currentEmojiArt.image.backgroundImageData)
                
                for emoji in self?.currentEmojiArt.image.emoji ?? [] {
                    self?.emojiImageVC.addSymbol(symbol: emoji.attributedString, inPosition: emoji.position)
                }
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
        
    func compositeImageVCDidUpdateImage(_ compositeImage: (image: UIImage?, symbols: [UILabel])) {
        currentEmojiArt.image.backgroundImageData = compositeImage.image?.pngData()
        
        currentEmojiArt.image.emoji = compositeImage
            .symbols
            .map{ EmojiInfo(fromAttributedString: $0.attributedText!, andPosition: $0.center) }        
    }
    
    //MARK:- DynamicCollectionVCDelegate methods
    
    func dynamicCollectionVCDidUpdateItems(_ items: [String]) {
        if currentEmojiArt.possibleEmoji != items {
            currentEmojiArt.possibleEmoji = items
        }
    }
}

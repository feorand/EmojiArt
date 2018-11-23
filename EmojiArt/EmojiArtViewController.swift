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
    
    var emojiImageDidChangeObserver: NSObjectProtocol!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emojiImageDidChangeObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.CompositeImageDidChange,
            object: nil,
            queue: nil,
            using: {[weak self] notification in
                let userInfo = notification.userInfo
                
                let image = userInfo?["image"] as? (UIImage?, [UILabel])
                let snapshot = userInfo?["snapshot"] as? UIImage
                
                self?.currentEmojiArt.image.backgroundImageData = image?.0?.pngData()
                
                self?.currentEmojiArt.image.emoji = (image?.1 ?? [])
                    .map{ EmojiInfo(fromAttributedString: $0.attributedText!, andPosition: $0.center) }
                
                self?.document.emojiArt = self!.currentEmojiArt
                self?.document.thumbnailImage = snapshot
                self?.document.updateChangeCount(.done)

        }
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(emojiImageDidChangeObserver)
    }
    
    //MARK:- Segues
    
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
        } else if segue.identifier == SegueSettings.PresentModallyStats {
            if let statsVC = segue.destination as? StatsViewController {
                statsVC.document = document
            }
        }
    }
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
        
    }
    
    //MARK:- Actions
    
    @IBAction func doneButtonPressed() {
        dismiss(animated: true) {
            self.document.close()
        }

    }
    
    //MARK:- CompositeImageVCDelegate methods
        
    func compositeImageVCDidUpdateImage(_ compositeImage: (image: UIImage?, symbols: [UILabel]), snapshot: UIImage?) {
//        currentEmojiArt.image.backgroundImageData = compositeImage.image?.pngData()
//
//        currentEmojiArt.image.emoji = compositeImage.symbols
//            .map{ EmojiInfo(fromAttributedString: $0.attributedText!, andPosition: $0.center) }
//
//        document.emojiArt = currentEmojiArt
//        document.thumbnailImage = snapshot
//        document.updateChangeCount(.done)
    }
    
    //MARK:- DynamicCollectionVCDelegate methods
    
    func dynamicCollectionVCDidUpdateItems(_ items: [String]) {
        if currentEmojiArt.possibleEmoji != items {
            currentEmojiArt.possibleEmoji = items
        }
    }
}

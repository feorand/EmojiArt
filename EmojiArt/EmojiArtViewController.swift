//
//  ViewController.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 23.02.2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import UIKit
import MobileCoreServices

class EmojiArtViewController: UIViewController, CompositeImageViewControllerDelegate, DynamicCollectionViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate
{
    //MARK:- Outlets
    
    @IBOutlet weak var embeddedStatsHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var embeddedStatsWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem! {
        didSet {
            cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        }
    }
    
    //MARK:- Properties
    
    var currentEmojiArt = EmojiArt()
    
    var document: EmojiArtDocument!
    
    var possibleEmojiVC: DynamicCollectionViewController!
    
    var emojiImageVC: CompositeImageViewController!
    
    var documentStatsVC: StatsViewController!
    
    var emojiImageDidChangeObserver: NSObjectProtocol! {
        didSet {
            
        }
    }
    
    var documentStateDidChangeObserver: NSObjectProtocol!
    
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
        
        emojiImageDidChangeObserver = NotificationCenter.default.addObserver(
            forName: .CompositeImageDidChange,
            object: nil,
            queue: nil,
            using: {[weak self] notification in
                let userInfo = notification.userInfo
                
                let image = userInfo?["image"] as? (UIImage?, [UILabel])
                let snapshot = userInfo?["snapshot"] as? UIImage
                
                self?.documentChanged(image: image, snapshot: snapshot)
            }
        )
        
        documentStateDidChangeObserver = NotificationCenter.default.addObserver(
            forName: UIDocument.stateChangedNotification,
            object: document,
            queue: OperationQueue.main,
            using: { notification in
                if self.document.documentState == .normal, let statsVC = self.documentStatsVC {
                    statsVC.document = self.document
                    self.embeddedStatsWidthConstraint.constant = statsVC.preferredContentSize.width
                    self.embeddedStatsHeightConstraint.constant = statsVC.preferredContentSize.height
                }
            }
        )
    }
    
    private func documentChanged(image: (UIImage?, [UILabel])?, snapshot: UIImage?) {
        currentEmojiArt.image.backgroundImageData = image?.0?.pngData()
        
        currentEmojiArt.image.emoji = (image?.1 ?? [])
            .map{ EmojiInfo(fromAttributedString: $0.attributedText!, andPosition: $0.center) }
        
        document.emojiArt = currentEmojiArt
        document.thumbnailImage = snapshot
        document.updateChangeCount(.done)
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
        } else if segue.identifier == SegueSettings.PresentStatsEmbedded {
            if let destination = segue.destination as? StatsViewController {
                documentStatsVC = destination
            }
        } else if segue.identifier == SegueSettings.PresentStats {
            if let statsVC = segue.destination as? StatsViewController {
                if document.thumbnailImage == nil {
                    document.thumbnailImage = emojiImageVC.snapshot
                }
                
                statsVC.document = document
                
                statsVC.modalPresentationStyle = .formSheet
                
                if let popoverVC = statsVC.popoverPresentationController {
                    popoverVC.delegate = self
                }
            }
        }
    }
    
    //MARK:- Actions
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
        close()
    }

    @IBAction func close() {
        dismiss(animated: true) {
            NotificationCenter.default.removeObserver(self.emojiImageDidChangeObserver)
            NotificationCenter.default.removeObserver(self.documentStateDidChangeObserver)
            self.document.close()
        }
    }
    
    @IBAction func cameraButtonTapped() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("camera not available")
            return
        }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let availableMediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)
        
        guard let media = availableMediaTypes, media.contains(kUTTypeImage as String) else {
            print("image media type is not available")
            return
        }
        
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeImage as String]
        imagePickerController.sourceType = .camera
        
        present(imagePickerController, animated: true)
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
    
    //MARK:- ImagePickerVCDelegate methods
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let editedImage = info[.editedImage] as? UIImage
        let originalmage = info[.originalImage] as? UIImage
        let resultImage = editedImage ?? originalmage ?? UIImage()
        
        picker.dismiss(animated: true) {
            self.emojiImageVC.image = resultImage.scaled(by: ImageSettings.photoScale)
            
            let snapshot = self.emojiImageVC.snapshot
            let image = self.emojiImageVC.compositeImage
            self.documentChanged(image: image, snapshot: snapshot)
        }
    }
    
    //MARK:- PopoverPresentationVCDelegate Methods
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

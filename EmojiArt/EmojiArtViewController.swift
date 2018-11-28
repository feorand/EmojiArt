//
//  ViewController.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 23.02.2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import UIKit
import MobileCoreServices

class EmojiArtViewController: UIViewController, CompositeImageViewControllerDelegate, DynamicCollectionViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    //MARK:- Outlets
    
    @IBOutlet weak var embeddedStatsHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var embeddedStatsWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
//    {
//        didSet {
//            cameraButton.isEnabled = UIImagePickerController.isCameraDeviceAvailable(.front) || UIImagePickerController.isCameraDeviceAvailable(.rear)
//        }
//    }
    
    //MARK:- Properties
    
    var currentEmojiArt = EmojiArt()
    
    var document: EmojiArtDocument!
    
    var possibleEmojiVC: DynamicCollectionViewController!
    
    var emojiImageVC: CompositeImageViewController!
    
    var documentStatsVC: StatsViewController!
    
    var emojiImageDidChangeObserver: NSObjectProtocol!
    
    var documentStateDidChangeObserver: NSObjectProtocol!
    
    var imagePickerController: UIImagePickerController?
    
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
            forName: .CompositeImageDidChange,
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(emojiImageDidChangeObserver)
        NotificationCenter.default.removeObserver(documentStateDidChangeObserver)
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
            }
        }
    }
    
    //MARK:- Actions
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
        close()
    }

    @IBAction func close() {
        dismiss(animated: true) {
            self.document.close()
        }
    }
    
    @IBAction func cameraButtonTapped() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("camera not available")
            return
        }
        
        imagePickerController = UIImagePickerController()
        imagePickerController?.delegate = self
        
        let availableMediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)
        
        guard let media = availableMediaTypes, media.contains(kUTTypeImage as String) else {
            print("image media type is not available")
            return
        }
        
        imagePickerController?.allowsEditing = true
        imagePickerController?.mediaTypes = [kUTTypeImage as String]
        imagePickerController?.sourceType = .camera
        
        present(imagePickerController!, animated: true)
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
        imagePickerController?.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let editedImage = info[.editedImage] as? UIImage
        let originalmage = info[.originalImage] as? UIImage
        let resultImage = editedImage ?? originalmage ?? UIImage()
        
        emojiImageVC.image = resultImage.scaled(by: ImageSettings.photoScale)
        
        imagePickerController?.dismiss(animated: true)
    }
}

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
    
    var document: EmojiArtDocument?
    
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
        
        document?.open() {success in
            if success {
                self.title = self.document?.localizedName
                self.emojiImageVC.image = UIImage(data: self.document?.emojiArt?.image.backgroundImageData ?? Data())
            }
        }
    }
    
    //MARK:- Actions
    
    @IBAction func saveButtonPressed() {
        let emojiJson = emojiSource.json()
        let documentsDitectoryUrl = FileManager.DocumentsUrl()
        let destinationFileUrl = documentsDitectoryUrl
            .appendingPathComponent("Untitled")
            .appendingPathExtension("json")
        
        do {
            try emojiJson.write(to: destinationFileUrl)
        } catch {
            print("ERROR: Writing JSON to Documents, \(error)")
        }
    }
    
    @IBAction func doneButtonPressed() {
        dismiss(animated: true)
    }
    
    //MARK:- CompositeImageViewControllerDelegate methods
    
    func compositeImageVCDidChangeBackground(to image: UIImage?) {
        emojiSource.image.backgroundImageData = image?.pngData()
    }
    
    func compositeImageVCDidAddSymbol(_ symbol: NSAttributedString, position: CGPoint) {
        let emojiInfo = EmojiInfo(
            x: Float(position.x),
            y: Float(position.y),
            symbol: symbol.string,
            size: Int(symbol.size().height)
        )
        
        emojiSource.image.emoji.append(emojiInfo)
    }
}

//
//  StatsViewController.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 23/11/2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController
{
    //MARK:- Outlets
    
    @IBOutlet weak var previewImageView: UIImageView!
    
    @IBOutlet weak var sizeLabel: UILabel!
    
    @IBOutlet weak var modifiedDateLabel: UILabel!
    
    @IBOutlet weak var aspectRatioConstraint: NSLayoutConstraint!
    
    //MARK:- Model
    
    var document: EmojiArtDocument!
    
    //MARK:- ViewController lifecycle
    
    override func viewDidLoad() {
        updateUI()
    }
    
    @IBAction func returnButtonPressed() {
        presentingViewController?.dismiss(animated: true)
    }
    
    //MARK:- Utilities
    
    private func updateUI() {
        if let documentAttributes = try? FileManager.default.attributesOfItem(atPath: document.fileURL.path) {
            if let fileSize = documentAttributes[FileAttributeKey.size] as? Int {
                sizeLabel.text = "\(fileSize) bytes"
            }

            if let modificationDate = documentAttributes[FileAttributeKey.modificationDate] as? Date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
                
                modifiedDateLabel.text = dateFormatter.string(from: modificationDate)
            }
            
            previewImageView.image = document.thumbnailImage

            if let image = document.thumbnailImage {
                previewImageView.removeConstraint(aspectRatioConstraint)
                
                let newAspectRatioConstraint = NSLayoutConstraint(
                    item: previewImageView,
                    attribute: .width,
                    relatedBy: .equal,
                    toItem: previewImageView,
                    attribute: .height,
                    multiplier: image.size.width / image.size.height,
                    constant: 0
                )
                
                previewImageView.addConstraint(newAspectRatioConstraint)
            }
        }
    }
}

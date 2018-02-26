//
//  ViewController.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 23.02.2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    var imageURL: URL? {
        didSet {
            if let url = imageURL {
                DispatchQueue.global(qos: .userInitiated).async {
                    let imageData = try? Data(contentsOf: url)
                    if let imageData = imageData, let image = UIImage(data: imageData) {
                        DispatchQueue.main.async {
                            self.backgroundView.image = image
                        }
                    }

                }
            }
        }
    }
    
    @IBOutlet weak var dropView: UIView!
    
    @IBOutlet weak var backgroundView: BackgroundView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        
        let dropInteraction = UIDropInteraction(delegate: self)
        dropView.addInteraction(dropInteraction)
    }
}

extension ViewController: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSURL.self) { [weak self] urls in
            if let urlItem = urls.first, let url = urlItem as? URL {
                self?.imageURL = url
            }
        }
        
        session.loadObjects(ofClass: UIImage.self) { [weak self] images in
            if let imageItem = images.first, let image = imageItem as? UIImage {
                self?.backgroundView.image = image
            }
        }
    }
}

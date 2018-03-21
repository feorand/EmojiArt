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
    let emojis = "😀😋😡😱🐱🐴🐝🐥🐟🐉🍔🍎".map{ String($0) }
    
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
    
    @IBOutlet weak var dropView: UIView! {
        didSet {
            let dropInteraction = UIDropInteraction(delegate: self)
            dropView.interactions += [dropInteraction]
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var backgroundView = BackgroundView()
    
    var imageView = UIImageView()
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
}

extension ViewController: UIDropInteractionDelegate
{
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

extension ViewController: UICollectionViewDelegate
{
}

extension ViewController: UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
        if let cell = cell as? EmojiCollectionViewCell {
            cell.label.text = emojis[indexPath.item]
        }
        return cell
    }
}

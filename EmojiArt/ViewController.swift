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

    @IBOutlet weak var dropView: UIView! {
        didSet {
            let dropInteraction = UIDropInteraction(delegate: self)
            dropView.interactions += [dropInteraction]
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.maximumZoomScale = 5.0
            scrollView.minimumZoomScale = 0.1
            scrollView.delegate = self
            scrollView.addSubview(backgroundView)
        }
    }
    @IBOutlet weak var scrollWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollHeightConstraint: NSLayoutConstraint!
    
    var backgroundView = BackgroundView()
    var image: UIImage? {
        get {
            return backgroundView.image
        }
        
        set {
            scrollView?.zoomScale = 1.0
            backgroundView.image = newValue
            let size = newValue?.size ?? CGSize.zero
            backgroundView.frame = CGRect(origin: CGPoint.zero, size: size)
            scrollView?.contentSize = size
            
            if let dropView = dropView, size.width > 0, size.height > 0 {
                scrollView?.zoomScale = max(dropView.bounds.size.width / size.width, dropView.bounds.size.height / size.height)
            }
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.dragDelegate = self
        }
    }
    
    private func setImageFromNetAsync(imageURL: URL?) {
        if let url = imageURL {
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = try? Data(contentsOf: url)
                if let imageData = imageData, let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.image = image
                    }
                }
            }
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
                self?.setImageFromNetAsync(imageURL: url)
            }
        }
        
        session.loadObjects(ofClass: UIImage.self) { [weak self] images in
            if let imageItem = images.first, let image = imageItem as? UIImage {
                self?.image = image
            }
        }
    }
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

extension ViewController: UICollectionViewDelegate { }

extension ViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let cell = collectionView.cellForItem(at: indexPath) as! EmojiCollectionViewCell
        let itemProvider = NSItemProvider(object: cell.label.attributedText!)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
}

extension ViewController: UIScrollViewDelegate
{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return backgroundView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollWidthConstraint.constant = scrollView.contentSize.width
        scrollHeightConstraint.constant = scrollView.contentSize.height
    }
}

//
//  CompositeImageViewController.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 02/11/2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import UIKit

class CompositeImageViewController: UIViewController, UIScrollViewDelegate, UIDropInteractionDelegate
{
    // MARK:- Outlets
    
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
    
    //MARK:- Properties
    
    var backgroundView = CompositeImageView()
    
    var image: UIImage? {
        get {
            return backgroundView.background
        }
        
        set {
            let size = newValue?.size ?? CGSize.zero
            
            backgroundView.frame = CGRect(origin: CGPoint.zero, size: size)
            backgroundView.background = newValue
            
            if let dropView = dropView, size.width > 0, size.height > 0 {
                scrollView?.zoomScale = max(dropView.bounds.size.width / size.width, dropView.bounds.size.height / size.height)
            } else {
                scrollView?.zoomScale = 1.0
            }
            scrollView?.contentSize = size
        }
    }
        
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self) &&
            session.canLoadObjects(ofClass: UIImage.self) ||
            session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        if session.localDragSession?.localContext as? UICollectionView == nil {
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
        } else if let emoji = session.items.first?.localObject as? NSAttributedString {
            let position = session.location(in: self.backgroundView)
            let emojiView = UILabel()
            emojiView.attributedText = emoji
            emojiView.backgroundColor = .clear
            emojiView.sizeToFit()
            emojiView.center = position
            backgroundView.addSubview(emojiView)
        }
    }
    
    // MARK:- Scrolling
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return backgroundView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // Updating fixed width and height constraints to match new content size
        // Fixed size constraints have lower priority than centering constrains
        // and constraints that keep view inside edges
        // This is done in order to support both large (zoom) and small (center) images
        scrollWidthConstraint.constant = scrollView.contentSize.width
        scrollHeightConstraint.constant = scrollView.contentSize.height
    }
    
    //MARK:- Utilities
    
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

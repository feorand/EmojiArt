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
    
    @IBOutlet weak var dropImageHereLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.maximumZoomScale = ImageScrollSettings.maxZoom
            scrollView.minimumZoomScale = ImageScrollSettings.minZoom
            scrollView.delegate = self
            scrollView.addSubview(resultView)
        }
    }
    
    @IBOutlet weak var scrollWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var scrollHeightConstraint: NSLayoutConstraint!
    
    //MARK:- Properties
    
    var delegate: CompositeImageViewControllerDelegate? = nil
    
    var resultView = CompositeImageView()
    
    var compositeImage: (image: UIImage?, symbols: [UILabel]) {
        return (image, symbols)
    }
    
    var symbols: [UILabel] {
        return resultView.symbols
    }
    
    var image: UIImage? {
        get {
            return resultView.background
        }
        
        set {
            let size = newValue?.size ?? CGSize.zero
            
            resultView.changeBackgroundImage(to: newValue)
            
            if let dropView = dropView, size.width > 0, size.height > 0 {
                scrollView.zoomScale = max(dropView.bounds.size.width / size.width, dropView.bounds.size.height / size.height)
            } else {
                scrollView.zoomScale = 1.0
            }
            scrollView.contentSize = size
            
            dropImageHereLabel.isHidden = true
            dropView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            
            delegate?.compositeImageVCDidChangeBackground(to: newValue)
        }
    }
    
    func addSymbol(symbol: NSAttributedString, inPosition position: CGPoint) {
        resultView.addSymbol(symbol, position: position)
    }
    
    //MARK:- Drop
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
            // First load a miniature of an image so user has something to see
            session.loadObjects(ofClass: UIImage.self) { [weak self] images in
                if let imageItem = images.first, let image = imageItem as? UIImage {
                    self?.image = image
                }
            }
//
//            // Then load a full image from net (may be slow)
//            session.loadObjects(ofClass: NSURL.self) { [weak self] urls in
//                if let urlItem = urls.first, let url = urlItem as? URL {
//                    self?.setImageFromNetAsync(imageURL: url)
//                }
//            }
            
        } else if let symbol = session.items.first?.localObject as? NSAttributedString {
            let position = session.location(in: self.resultView)
            resultView.addSymbol(symbol, position: position)
            delegate?.compositeImageVCDidAddSymbol(symbol, position: position)
        } else {
            print("Unknown object dropped")
        }
    }
    
    // MARK:- Scrolling
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return resultView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // Updating fixed width and height constraints to match new content size
        // Fixed size constraints have lower priority than centering constrains
        // and constraints that keep view inside bounds
        // This is done in order to support both large (zoom) and small (center) images
        scrollWidthConstraint.constant = scrollView.contentSize.width
        scrollHeightConstraint.constant = scrollView.contentSize.height
    }
    
    //MARK:- Utilities
    
    private func setImageFromNetAsync(imageURL: URL?) {
        if let url = imageURL {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let imageData = try? Data(contentsOf: url)
                if let imageData = imageData, let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

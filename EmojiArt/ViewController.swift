//
//  ViewController.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 23.02.2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate
{
    var emojis = "😀😋😡😱🐱🐴🐝🐥🐟🐉🍔🍎".map{ String($0) }
    var isAdding = false

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
            let size = newValue?.size ?? CGSize.zero

            backgroundView.frame = CGRect(origin: CGPoint.zero, size: size)
            backgroundView.image = newValue
            
            if let dropView = dropView, size.width > 0, size.height > 0 {
                scrollView?.zoomScale = max(dropView.bounds.size.width / size.width, dropView.bounds.size.height / size.height)
            } else {
                scrollView?.zoomScale = 1.0
            }
            scrollView?.contentSize = size
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.dragDelegate = self
            collectionView.dropDelegate = self
        }
    }
    
    @IBAction func addCellButtonClicked() {
        isAdding = true
        collectionView.reloadSections([0])
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
}

extension ViewController: UICollectionViewDataSource
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        default: return emojis.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if isAdding {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InputItemsCell", for: indexPath)
                if let cell = cell as? InputItemsCollectionViewCell {
                    cell.textFieldDidEndEditingHandler = { [weak self, unowned cell] in
                        self?.emojis = cell.textField.text!.map{ String($0) } + self!.emojis
                        collectionView.reloadData()
                        cell.textField.text = ""
                        self?.isAdding = false
                    }
                }
                return cell
            } else {
                return collectionView.dequeueReusableCell(withReuseIdentifier: "AddItemsCell", for: indexPath)
            }
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
        if let cell = cell as? EmojiCollectionViewCell {
            cell.label.text = emojis[indexPath.item]
        }
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? InputItemsCollectionViewCell {
            cell.textField.becomeFirstResponder()
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 && isAdding {
            return CGSize(width: 200, height: 60)
        }
        
        return CGSize(width: 60, height: 60)
    }
}

extension ViewController: UICollectionViewDragDelegate
{
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        if indexPath.section == 0 {
            return []
        }
        
        let cell = collectionView.cellForItem(at: indexPath) as! EmojiCollectionViewCell
        let emoji = cell.label.attributedText!
        let itemProvider = NSItemProvider(object: emoji)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = emoji
        session.localContext = collectionView
        return [dragItem]
    }
}

extension ViewController: UICollectionViewDropDelegate
{
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if destinationIndexPath?.section == 0 {
            return UICollectionViewDropProposal(operation: .cancel)
        }
        
        let isLocal = session.localDragSession?.localContext as? UICollectionView == collectionView
        return UICollectionViewDropProposal(operation: isLocal ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                let stringItem = item.dragItem.localObject as! NSAttributedString
                
                collectionView.performBatchUpdates({
                    self.emojis.remove(at: sourceIndexPath.item)
                    self.emojis.insert(stringItem.string, at: destinationIndexPath.item)
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                })

                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            } else {
                let placeholder = UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "PlaceholderCell")
                let placeholderContext = coordinator.drop(item.dragItem, to: placeholder)

                item.dragItem.itemProvider.loadObject(ofClass: NSAttributedString.self) {(dragObject, error) in
                    DispatchQueue.main.async {
                        if let stringItem = dragObject as? NSAttributedString {
                            placeholderContext.commitInsertion{ insertionIndexPath in
                                self.emojis.insert(stringItem.string, at: insertionIndexPath.item)
                            }
                        } else {
                            placeholderContext.deletePlaceholder()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Scrolling

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
}

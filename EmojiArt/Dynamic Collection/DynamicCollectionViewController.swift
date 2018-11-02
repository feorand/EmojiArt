//
//  DynamicCollectionView.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 02/11/2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import UIKit

class DynamicCollectionViewController: UIViewController, UICollectionViewDragDelegate, UICollectionViewDropDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource
{
    
    //MARK:- Outlets
    
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
    
    //MARK:- Properties
    
    var source = "😀😋😡😱🐱🐴🐝🐥🐟🐉🍔🍎".map{ String($0) }
    
    var isAdding = false

    //MARK:- Data Source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        default: return source.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if isAdding {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InputCell", for: indexPath)
                if let cell = cell as? DynamicCollectionViewInputCell {
                    cell.textFieldDidEndEditingHandler = { [weak self, unowned cell] in
                        self?.source = cell.textField.text!.map{ String($0) } + self!.source
                        collectionView.reloadData()
                        cell.textField.text = ""
                        self?.isAdding = false
                    }
                }
                return cell
            } else {
                return collectionView.dequeueReusableCell(withReuseIdentifier: "AddCell", for: indexPath)
            }
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath)
        if let cell = cell as? DynamicCollectionViewItemCell {
            cell.label.text = source[indexPath.item]
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? DynamicCollectionViewInputCell {
            cell.textField.becomeFirstResponder()
        }
    }

    //MARK:- Flow Layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 && isAdding {
            return CGSize(width: 200, height: 60)
        }
        
        return CGSize(width: 60, height: 60)
    }
    
    //MARK:- Drag
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        if indexPath.section == 0 {
            return []
        }
        
        let cell = collectionView.cellForItem(at: indexPath) as! DynamicCollectionViewItemCell
        let item = cell.label.attributedText!
        let itemProvider = NSItemProvider(object: item)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        session.localContext = collectionView
        return [dragItem]
    }

    //MARK:- Drop
    
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
                    self.source.remove(at: sourceIndexPath.item)
                    self.source.insert(stringItem.string, at: destinationIndexPath.item)
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
                                self.source.insert(stringItem.string, at: insertionIndexPath.item)
                            }
                        } else {
                            placeholderContext.deletePlaceholder()
                        }
                    }
                }
            }
        }
    }
}

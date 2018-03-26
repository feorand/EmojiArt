//
//  InputItemsCollectionViewCell.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 26.03.2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import UIKit

class InputItemsCollectionViewCell: UICollectionViewCell, UITextFieldDelegate
{
    var inputEndHandler: (()->Void)?
    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        inputEndHandler?()
    }
    
}

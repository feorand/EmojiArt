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
    var imageURL: URL?
    
    @IBOutlet weak var dropView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        let dropInteraction = UIDropInteraction(delegate: self)
        dropView.addInteraction(dropInteraction)
    }
}

extension ViewController: UIDropInteractionDelegate {
    
}

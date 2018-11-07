//
//  EmojiArtDocumentBrowserViewController.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 07/11/2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import UIKit

class EmojiArtDocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        allowsDocumentCreation = true
        allowsPickingMultipleItems = false
        browserUserInterfaceStyle = .dark
        view.tintColor = .white
    }
}

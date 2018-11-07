//
//  EmojiArtDocumentBrowserViewController.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 07/11/2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import UIKit

class EmojiArtDocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    
    //MARK:- Properties
    
    var template: URL?
    
    //MARK:- ViewController life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        allowsDocumentCreation = true
        allowsPickingMultipleItems = false
        
        template = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("Untitled.json")
        
        if let url = template {
            FileManager.default.createFile(atPath: url.path, contents: Data(), attributes: nil)
        }
    }
    
    //MARK:- UIDocumentBrowserVCDelegate
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {

        importHandler(template, .copy)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        
        presentEmojiArtVC(withDocumentURL: documentURLs.first!)
    }
    
    //MARK:- Utilities
    
    private func presentEmojiArtVC(withDocumentURL url: URL) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let documentVC = mainStoryboard.instantiateViewController(withIdentifier: "EmojiArtNav")
        
        if let navigationVC = documentVC as? UINavigationController,
            let emojiArtVC = navigationVC.visibleViewController as? EmojiArtViewController  {
            emojiArtVC.document = EmojiArtDocument(fileURL: url)
        }
        
        present(documentVC, animated: true)
    }
}

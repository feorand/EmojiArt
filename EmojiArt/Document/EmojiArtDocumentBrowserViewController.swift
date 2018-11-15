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
    
    var templateURL: URL!
    
    //MARK:- ViewController life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        allowsDocumentCreation = true
        allowsPickingMultipleItems = false
        
        templateURL = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("Untitled.json")
        
        let template = EmojiArtDocument(fileURL: templateURL)
        template.emojiArt.possibleEmoji = EmojiSettings.DefaultEmoji
        template.save(to: templateURL, for: .forOverwriting)

        //FileManager.default.createFile(atPath: url.path, contents: Data(), attributes: nil)
    }
    
    //MARK:- UIDocumentBrowserVCDelegate
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {

        importHandler(templateURL, .copy)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        
        presentEmojiArtVC(withDocumentURL: documentURLs.first!)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        
        presentEmojiArtVC(withDocumentURL: destinationURL)
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

//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 07/11/2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import UIKit

// Class representing document for project Model
class EmojiArtDocument: UIDocument {
    
    //MARK:- Properties
    
    //Model for representing
    var emojiArt: EmojiArt = EmojiArt()
    
    var thumbnailImage: UIImage?
    
    //MARK:- UIDocument methods
    
    //Saving model to a document
    override func contents(forType typeName: String) throws -> Any {
        return emojiArt.json() as Any
    }
    
    //Loading model from a document
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let data = contents as? Data {
            emojiArt = EmojiArt(fromJson: data) ?? EmojiArt()
        }
    }
    
    //Thumbnail for document
    override func fileAttributesToWrite(to url: URL, for saveOperation: UIDocument.SaveOperation) throws -> [AnyHashable : Any] {
        var fileAttributes = try super.fileAttributesToWrite(to: url, for: saveOperation)
        if let thumbnail = thumbnailImage {
            fileAttributes[URLResourceKey.thumbnailDictionaryKey] = [URLThumbnailDictionaryItem.NSThumbnail1024x1024SizeKey: thumbnail]
        }
        
        return fileAttributes
    }
}

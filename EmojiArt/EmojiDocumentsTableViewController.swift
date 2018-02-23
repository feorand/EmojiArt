//
//  EmojiDocumentsTableViewController.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 23.02.2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import UIKit

class EmojiDocumentsTableViewController: UITableViewController
{
    var emojiDocuments = ["One", "Two", "Three"]
    
    @IBAction func addButtonTouched(_ sender: UIBarButtonItem) {
        emojiDocuments += ["Untitled"]
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emojiDocuments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmojiDocument", for: indexPath)
        cell.textLabel?.text = emojiDocuments[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            emojiDocuments.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

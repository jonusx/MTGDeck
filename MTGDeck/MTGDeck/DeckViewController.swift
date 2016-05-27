//
//  DeckViewController.swift
//  MTGDeck
//
//  Created by Mathew Cruz on 5/25/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//

import UIKit

class DeckViewController: UIViewController {
    private var decks:[MTGDeck] = []
    @IBOutlet weak var deckTable:UITableView?
    
    var deckDataSource:SimpleListDataSource<MTGDeck>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deckDataSource = SimpleListDataSource(context: DataManager.sharedManager.managedObjectContext)
        deckDataSource?.delegate = self
        deckDataSource?.tableView = deckTable
        
        deckTable?.reloadData()
    }
    
    @IBAction func addNewDeck() {
        let alert = UIAlertController(title: "Add a new deck", message: "Title your custom built deck", preferredStyle: .Alert)
        var titleTextField:UITextField?
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Deck Name"
            titleTextField = textField
        }
        alert.addAction(UIAlertAction(title: "Add", style: .Default, handler: { (action) in
            let newDeck = NSEntityDescription.insertNewObjectForEntityForName("MTGDeck", inManagedObjectContext: DataManager.sharedManager.managedObjectContext) as! MTGDeck
            newDeck.title = titleTextField?.text
            try! DataManager.sharedManager.managedObjectContext.save()
            self.deckDataSource?.reload()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        showDetailViewController(alert, sender: self)
    }

}

extension DeckViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let controller = storyboard?.instantiateViewControllerWithIdentifier("DeckDetailViewController") as! DeckDetailViewController
        controller.deck = deckDataSource?.items[indexPath.row]
        showViewController(controller, sender: self)
    }
}

extension DeckViewController: SimpleListDataSourceDelegate {
    var highlightedNameText:String? { get { return nil } }
    var fetchRequest:NSFetchRequest {
        get {
            let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "MTGDeck")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            return fetchRequest
        }
    }
}
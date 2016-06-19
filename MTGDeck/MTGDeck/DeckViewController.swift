//
//  DeckViewController.swift
//  MTGDeck
//
//  Created by Mathew Cruz on 5/25/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//

import UIKit

class DeckCell: CardCell {
    @IBOutlet weak var colorStack:UIStackView?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if let views = colorStack?.arrangedSubviews {
            for view in views {
                view.removeFromSuperview()
            }
        }
    }
}

class DeckViewController: UIViewController {
    private var decks:[MTGDeck] = []
    @IBOutlet weak var deckTable:UITableView?
    
    var deckDataSource:SimpleListDataSource<MTGDeck>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deckDataSource = SimpleListDataSource(contextUsingFetchedResultsController: DataManager.sharedManager.personalContext)
        deckDataSource?.delegate = self
        deckDataSource?.tableView = deckTable
        deckTable?.dataSource = self
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
            let newDeck = NSEntityDescription.insertNewObjectForEntityForName("MTGDeck", inManagedObjectContext: DataManager.sharedManager.personalContext) as! MTGDeck
            newDeck.title = titleTextField?.text
            try! DataManager.sharedManager.personalContext.save()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        showDetailViewController(alert, sender: self)
    }

}

extension DeckViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let controller = storyboard?.instantiateViewControllerWithIdentifier("DeckDetailViewController") as! DeckDetailViewController
        controller.deck = deckDataSource?[indexPath.row]
        showViewController(controller, sender: self)
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
}

extension DeckViewController:UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = deckDataSource?.tableView(tableView, cellForRowAtIndexPath: indexPath) as! DeckCell
        if let colors = deckDataSource?[indexPath.row]!.colorBreakDown?.colors {
            var colorsToAdd:[UIColor] = []
            if colors.red > 0 {
                colorsToAdd.append(UIColor.redColor())
            }
            if colors.white > 0 {
                colorsToAdd.append(UIColor.whiteColor())
            }
            if colors.black > 0 {
                colorsToAdd.append(UIColor.blackColor())
            }
            if colors.green > 0 {
                colorsToAdd.append(UIColor.greenColor())
            }
            if colors.blue > 0 {
                colorsToAdd.append(UIColor.blueColor())
            }
            for view:UIView in colorsToAdd.map({ (color) in
                let v = UIView()
                v.heightAnchor.constraintEqualToConstant(30).active = true
                v.widthAnchor.constraintEqualToConstant(30).active = true
                v.backgroundColor = color
                v.layer.borderColor = UIColor.blackColor().CGColor
                v.layer.borderWidth = 1.0
                return v
            }) {
                cell.colorStack?.addArrangedSubview(view)
            }
            
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deckDataSource!.tableView(tableView, numberOfRowsInSection: section)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if let itemToRemove = deckDataSource?[indexPath.row] {
                deckDataSource?.context.deleteObject(itemToRemove)
                try! deckDataSource?.context.save()
            }
        }
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
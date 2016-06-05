//
//  DeckDetailViewController.swift
//  MTGDeck
//
//  Created by Mathew Cruz on 5/26/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//

import UIKit

class DeckDetailViewController: UIViewController {
    var deck:MTGDeck?
    
    @IBOutlet weak var cardTable:UITableView?
    
    var cardDataSource:SimpleListDataSource<MTGCardInDeck>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardDataSource = SimpleListDataSource(context: DataManager.sharedManager.managedObjectContext)
        cardDataSource?.tableView = cardTable
        cardDataSource?.delegate = self
        cardTable?.dataSource = self
        cardTable?.reloadData()
        
        title = deck?.title
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func fish() {
        guard let controller = storyboard?.instantiateViewControllerWithIdentifier("FisherViewController") as? FisherViewController else { return }
        controller.deck = deck
        showViewController(controller, sender: self)
    }
    
    @IBAction func addCard() {
        guard let controller = storyboard?.instantiateViewControllerWithIdentifier("CardSearchViewController") as? CardSearchViewController else { return }
        controller.delegate = self
        let navController = UINavigationController(rootViewController: controller)
        let close = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(drop))
        controller.navigationItem.leftBarButtonItem = close
        showDetailViewController(navController, sender: self)
    }
    
    func drop() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addCard(card:MTGCard, count:Int) {
        if let cards = deck?.cards as? Set<MTGCardInDeck>, currentCard = cards.filter({ $0.card?.multiverseid == card.multiverseid }).first {
            currentCard.count = currentCard.count as! Int + count
        }
        else
        {
            let newCard = NSEntityDescription.insertNewObjectForEntityForName("MTGCardInDeck", inManagedObjectContext: DataManager.sharedManager.managedObjectContext) as! MTGCardInDeck
            newCard.card = card
            newCard.count = count
            newCard.deck = deck
        }
        try! DataManager.sharedManager.managedObjectContext.save()
        cardDataSource?.reload()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let controller = segue.destinationViewController as? DeckBreakdownViewController else { return }
        controller.deck = deck
    }
    
}

extension DeckDetailViewController: CardSearchViewControllerDelegate {
    func didSelectCard(card: MTGCard) {
        let controller = UIAlertController(title: "How many?", message: "", preferredStyle: .Alert)
        var textField:UITextField?
        controller.addTextFieldWithConfigurationHandler { (field) in
            textField = field
            field.keyboardType = .NumberPad
            field.placeholder = "Count"
        }
        controller.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) in
            self.addCard(card, count: Int(textField!.text ?? "0")!)
            
        }))
        presentedViewController?.showDetailViewController(controller, sender: self)
    }
}

extension DeckDetailViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = cardDataSource?.tableView(tableView, cellForRowAtIndexPath: indexPath) as! CardCell
        cell.cardTextLabel?.text = "Number in deck -- \(cardDataSource!.items[indexPath.row].count!)"
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardDataSource!.tableView(tableView, numberOfRowsInSection: section)
    }
}

extension DeckDetailViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = storyboard?.instantiateViewControllerWithIdentifier("CardDetailViewController") as! CardDetailViewController
        controller.card = cardDataSource?.items[indexPath.row].card
        showViewController(controller, sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension DeckDetailViewController: SimpleListDataSourceDelegate {
    var highlightedNameText:String? { get { return nil } }
    var fetchRequest:NSFetchRequest {
        get {
            let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "MTGCardInDeck")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "card.name", ascending: true)]
            
            let predicate = NSPredicate(format: "deck == %@", deck!)    
            fetchRequest.predicate = predicate
            return fetchRequest
        }
    }
}

//
//  CollectionViewController.swift
//  MTGDeck
//
//  Created by Mathew Cruz on 5/25/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//

import UIKit

class CollectionCell: CardCell {
    
}

class CollectionViewController: UIViewController {
    let searchController:UISearchController = UISearchController(searchResultsController: nil)
    private var cards:[MTGCard] = []
    private var searchText:String?
    @IBOutlet weak var resultsTable:UITableView?
    
    var cardDataSource:SimpleListDataSource<MTGCard>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardDataSource = SimpleListDataSource(contextUsingFetchedResultsController: DataManager.sharedManager.personalContext)
        cardDataSource?.delegate = self
        cardDataSource?.tableView = resultsTable
        resultsTable?.dataSource = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        
        definesPresentationContext = true
        resultsTable?.tableHeaderView = searchController.searchBar
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        cardDataSource?.reload()
    }
}

extension CollectionViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let controller = storyboard?.instantiateViewControllerWithIdentifier("CardDetailViewController") as! CardDetailViewController
        controller.card = cardDataSource?[indexPath.row]
        showViewController(controller, sender: self)
    }
}

extension CollectionViewController:UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = cardDataSource?.tableView(tableView, cellForRowAtIndexPath: indexPath) as! CollectionCell
        let card = cardDataSource![indexPath.row]
        let decks = card!.cc!.flatMap { (cardInDeck) -> String? in
            let cardInDeck = cardInDeck as! MTGCardInDeck
            return cardInDeck.deck?.title
        }
        
        if decks.isEmpty == false {
            cell.typeLabel?.text = "In decks:"
            cell.cardTextLabel?.text = decks.joinWithSeparator(", ")
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardDataSource!.tableView(tableView, numberOfRowsInSection: section)
    }
}

extension CollectionViewController: SimpleListDataSourceDelegate {
    var highlightedNameText:String? { get { return searchText } }
    var fetchRequest:NSFetchRequest {
        get {
            let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "MTGCard")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            var predicate = NSPredicate(format: "cc.@count > 0")
            if let searchText = searchText {
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "name CONTAINS[cd] %@", searchText), predicate])
            }
            fetchRequest.predicate = predicate
            return fetchRequest
        }
    }
    
    func deletedItemAtIndexPath(indexPath: NSIndexPath) { }
}

extension CollectionViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchText = nil
        cardDataSource?.reload()
    }
}

extension CollectionViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if searchController.searchBar.isFirstResponder() {
            searchText = searchController.searchBar.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            cardDataSource?.reload()
        }
    }
}


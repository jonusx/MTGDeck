//
//  CardSearchViewController.swift
//  MTGDeck
//
//  Created by Mathew Cruz on 5/21/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//

import UIKit

protocol CardSearchViewControllerDelegate {
    func didSelectCard(card:MTGCard)
}

class CardSearchViewController: UIViewController {
    let searchController:UISearchController = UISearchController(searchResultsController: nil)
    private var cards:[MTGCard] = []
    private var searchText:String?
    var delegate:CardSearchViewControllerDelegate?
    
    @IBOutlet weak var resultsTable:UITableView?
    
    var cardDataSource:SimpleListDataSource<MTGCard>?

    override func viewDidLoad() {
        super.viewDidLoad()
        cardDataSource = SimpleListDataSource(context: DataManager.sharedManager.managedObjectContext)
        cardDataSource?.delegate = self
        cardDataSource?.tableView = resultsTable
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        resultsTable?.tableHeaderView = searchController.searchBar
        resultsTable?.reloadData()
    }

}

extension CardSearchViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let delegate = delegate {
            delegate.didSelectCard(cardDataSource!.items[indexPath.row])
            return
        }
        let controller = storyboard?.instantiateViewControllerWithIdentifier("CardDetailViewController") as! CardDetailViewController
        controller.card = cardDataSource?.items[indexPath.row]
        showViewController(controller, sender: self)
    }
}

extension CardSearchViewController: SimpleListDataSourceDelegate {
    var highlightedNameText:String? {
        get {
            return searchText
        }
    }
    var fetchRequest:NSFetchRequest {
        get {
            let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "MTGCard")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            if let searchText = searchText {
                fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
            }
            return fetchRequest
        }
    }
}

extension CardSearchViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchText = nil
        cardDataSource?.reload()
    }
}

extension CardSearchViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        searchText = searchController.searchBar.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        cardDataSource?.reload()
    }
}


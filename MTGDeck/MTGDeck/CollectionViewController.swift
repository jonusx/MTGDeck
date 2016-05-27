//
//  CollectionViewController.swift
//  MTGDeck
//
//  Created by Mathew Cruz on 5/25/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//

import UIKit

class CollectionViewController: UIViewController {
    let searchController:UISearchController = UISearchController(searchResultsController: nil)
    private var cards:[MTGCard] = []
    private var searchText:String?
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

extension CollectionViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let controller = storyboard?.instantiateViewControllerWithIdentifier("CardDetailViewController") as! CardDetailViewController
        controller.card = cardDataSource?.items[indexPath.row]
        showViewController(controller, sender: self)
    }
}

extension CollectionViewController: SimpleListDataSourceDelegate {
    var highlightedNameText:String? { get { return searchText } }
    var fetchRequest:NSFetchRequest {
        get {
            let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "MTGCard")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            //        fetchRequest.relationshipKeyPathsForPrefetching = []
            var predicate = NSPredicate(format: "cc.@count > 0")//"SUBQUERY(deck, $sub, $sub.@count > 0) > 0")
            if let searchText = searchText {
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "name CONTAINS[cd] %@", searchText), predicate])
            }
            fetchRequest.predicate = predicate
            return fetchRequest
        }
    }
}

extension CollectionViewController: UISearchBarDelegate {}

extension CollectionViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        searchText = searchController.searchBar.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        cardDataSource?.reload()
    }
}


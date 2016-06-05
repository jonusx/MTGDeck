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
    private var searchTokens:Set<String>?
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
        searchController.searchBar.showsBookmarkButton = true
        searchController.searchBar.setImage(UIImage(named: "camIcon"), forSearchBarIcon: .Bookmark, state: .Normal)
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
            if let searchTokens = searchTokens {
                let predicates = searchTokens.map({ NSPredicate(format: "name CONTAINS[cd] %@", $0)})
                fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
                return fetchRequest
            }
            if let searchText = searchText where searchText.isEmpty == false {
                fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
            }
            return fetchRequest
        }
    }
}

extension CardSearchViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchText = nil
        searchTokens = nil
        cardDataSource?.reload()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchTokens = nil
    }
    
    func searchBarBookmarkButtonClicked(searchBar: UISearchBar) {
        let controller = storyboard?.instantiateViewControllerWithIdentifier("OCRPreviewController") as! OCRPreviewController
        controller.delegate = self
        let navController = UINavigationController(rootViewController: controller)
        showDetailViewController(navController, sender: self)
    }
}

extension CardSearchViewController: OCRResultsDelegate {
    func ORCController(controller: OCRPreviewController?, didProduceAnnotations annotations: [Annotation]?) {
        guard let annotations = annotations, completeAnnotation = annotations.first else { return }
        let tokenArray:[String] = completeAnnotation.text.characters.split("\n").map({String($0)})
        searchTokens = Set<String>(tokenArray)
        searchController.searchBar.text = searchTokens?.joinWithSeparator(", ")
    }
}

extension CardSearchViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        searchText = searchController.searchBar.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        cardDataSource?.reload()
    }
}


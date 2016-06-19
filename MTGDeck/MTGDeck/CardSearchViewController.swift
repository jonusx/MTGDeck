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
    var deck:MTGDeck?
    var delegate:CardSearchViewControllerDelegate?
    
    @IBOutlet weak var resultsTable:UITableView?
    
    var cardDataSource:SimpleListDataSource<MTGCard>?

    override func viewDidLoad() {
        super.viewDidLoad()
        cardDataSource = SimpleListDataSource(contextUsingFetchedResultsController: DataManager.sharedManager.managedObjectContext)
        cardDataSource?.delegate = self
        cardDataSource?.tableView = resultsTable
        cardDataSource?.actionBlock = { [weak self] (item) in
            if let delegate = self?.delegate {
                delegate.didSelectCard(item)
            }
            else
            {
                self?.addCard(item)
            }
        }
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.showsBookmarkButton = true
        searchController.searchBar.setImage(UIImage(named: "camIcon"), forSearchBarIcon: .Bookmark, state: .Normal)
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        resultsTable?.tableHeaderView = searchController.searchBar
        resultsTable?.reloadData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardShown(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardShown(_:)), name: UIKeyboardWillHideNotification, object: nil)

    }
    
    func keyboardShown(notification:NSNotification) {
        let keyboardEndFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
  
        let oldInset = resultsTable!.contentInset
        resultsTable?.contentInset = UIEdgeInsets(top: oldInset.top, left: oldInset.left, bottom: keyboardEndFrame.height, right: oldInset.right)
        
    }
    
    func keyboardHidden(notification:NSNotification) {
        let oldInset = resultsTable!.contentInset
        resultsTable?.contentInset = UIEdgeInsets(top: oldInset.top, left: oldInset.left, bottom: 0.0, right: oldInset.right)
    }

    func addCard(card:MTGCard) {
        
        DataManager.sharedManager.personalContext.performBlock { 
            
            let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "MTGDeck")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            let decks = try! DataManager.sharedManager.personalContext.executeFetchRequest(fetchRequest) as! [MTGDeck]

            NSOperationQueue.mainQueue().addOperationWithBlock({
                
                let presenter = self.presentedViewController ?? self
                let controller = UIAlertController(title: "Select Deck to add to:", message: "", preferredStyle: .ActionSheet)
                for deck in decks {
                    controller.addAction(UIAlertAction(title: deck.title, style: .Default, handler: { (action) in
                        let deckManager = DeckManager(deck: deck)
                        deckManager.presentAddCard(card, onViewController: self)
                    }))
                }
                controller.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                presenter.showDetailViewController(controller, sender: nil)
            })
        }
    }
}

extension CardSearchViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let controller = storyboard?.instantiateViewControllerWithIdentifier("CardDetailViewController") as! CardDetailViewController
        controller.card = cardDataSource?[indexPath.row]
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
    func deletedItemAtIndexPath(indexPath: NSIndexPath) { }
}

extension CardSearchViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchText = nil
        searchTokens = nil
        cardDataSource?.isUsingFRC = true
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


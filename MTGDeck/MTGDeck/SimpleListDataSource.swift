//
//  SimpleListDataSource.swift
//  MTGDeck
//
//  Created by Mathew Cruz on 5/25/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//

import UIKit

protocol SimpleListDataSourceDelegate {
    var highlightedNameText:String? { get }
    var fetchRequest:NSFetchRequest { get }
}

public protocol SimpleListDisplayable {
    var title:String? { get }
    var subtitle:String? { get }
    var detailText:String? { get }
    var image:UIImage? { get set }
}

public protocol ActionableCell {
    var action:((UITableViewCell) -> ())? { get set }
}

extension MTGCard: SimpleListDisplayable {
    var title: String? {
        get { return name }
    }
    var subtitle: String? {
        get { return type }
    }
    var detailText: String? {
        get { return text }
    }
    var image: UIImage? {
        get {
            if let fullImage = fullImage {
                return UIImage(data: fullImage)
            }
            return nil
        }
        set {
            if let image = newValue {
                fullImage = UIImagePNGRepresentation(image)
            }
        }
    }
}

extension MTGCardInDeck: SimpleListDisplayable {
    var title: String? {
        get { return card?.title }
    }
    var subtitle: String? {
        get { return card?.subtitle }
    }
    var detailText: String? {
        get { return card?.text }
    }
    var image: UIImage? {
        get {
            return card?.image
        }
        set {
            card?.image = image
        }
    }
}

extension MTGDeck: SimpleListDisplayable {
    var subtitle: String? { return nil }
    var detailText: String? { return nil }
    var image: UIImage? { get { return nil } set {} }
}

public class SimpleListDataSource<T where T: SimpleListDisplayable, T: NSManagedObject>: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    var actionBlock:((T) -> ())?
    private var items:[T] = []
    subscript(index:Int) -> T? {
        get {
            if isUsingFRC {
                return fetchedResultsController?.objectAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? T
            }
            return items[index]
        }
    }
    
    var listItems:[T] {
        if isUsingFRC {
            return fetchedResultsController?.fetchedObjects as! [T]
        }
        return items
    }
    
    var objectCount:Int {
        return tableView(tableView!, numberOfRowsInSection: 0)
    }
    
    var delegate:SimpleListDataSourceDelegate? {
        didSet {
            reload()
        }
    }
    
    var fetchedResultsController:NSFetchedResultsController?
    
    var isUsingFRC:Bool = false {
        didSet {
            reload()
        }
    }
    
    let context:NSManagedObjectContext
    weak var tableView:UITableView? {
        didSet {
            tableView?.dataSource = self
        }
    }
    
    init(context:NSManagedObjectContext) {
        self.context = context
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SimpleListDataSource.reset), name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: self.context.persistentStoreCoordinator)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SimpleListDataSource.reset), name: DataManager.DataManagerDidMergeData, object: nil)
        
        
    }
    
    convenience init(contextUsingFetchedResultsController context:NSManagedObjectContext) {
        self.init(context: context)
        self.isUsingFRC = true
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let fetchedResultsController = fetchedResultsController,
            sections = fetchedResultsController.sections where isUsingFRC == true else {
            return items.count
        }
        return sections[section].numberOfObjects ?? 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cardCell", forIndexPath: indexPath) as! CardCell
        let item:T = self[indexPath.row]!

        let itemName = item.title ?? "" as NSString
        if let actionBlock = actionBlock where cell is ActionableCell == true {
            var actionCell = cell as! ActionableCell
            actionCell.action = { (cell) in actionBlock(item) }
        }
        if let art = item.image {
            cell.cardArtImageView?.image = art
        }
        else
        {
            if let item = item as? MTGCard ?? (item as? MTGCardInDeck)?.card {
                let completion:((UIImage?) -> ()) = { (image) in
                    guard let image = image else { return }
                    self.loadImage(image, atIndexPath: indexPath, tableView: tableView)
                }
                DataManager.sharedManager.artDownloader.artForCard(item, completion: completion)
            }
        }
        
        cell.typeLabel?.text = item.subtitle
        cell.cardTextLabel?.text = item.detailText
        
        if let highlightedNameText = delegate?.highlightedNameText {
            let attributedString = NSMutableAttributedString(string: itemName as String)
            let range = itemName.rangeOfString(highlightedNameText, options: [.CaseInsensitiveSearch, .DiacriticInsensitiveSearch])
            attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "Helvetica-Bold", size: 20)!, range: range)
            cell.nameLabel?.attributedText = attributedString
            return cell
        }
        cell.nameLabel?.text = item.title
        return cell
    }
    
    @objc func reset() {
        reload()
    }
    
    func reload() {
        guard let delegate = delegate else { return }
        context.performBlock { [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.isUsingFRC {
                let fetchRequest = delegate.fetchRequest
                fetchRequest.fetchBatchSize = 20
                strongSelf.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: strongSelf.context, sectionNameKeyPath: nil, cacheName: nil)
                strongSelf.fetchedResultsController?.delegate = self
                
                do {
                    try strongSelf.fetchedResultsController?.performFetch()
                } catch {
                    print("An error occurred")
                }
                strongSelf.tableView?.reloadData()
            }
            else
            {
                strongSelf.fetchedResultsController = nil
                delegate.fetchRequest.fetchBatchSize = 0
                strongSelf.reload(try! strongSelf.context.executeFetchRequest(delegate.fetchRequest) as! Array<T>)
            }
        }
    }
    
    func reload(items:[T]) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.items = items
            self.tableView?.reloadData()
        }
    }
    
    func loadImage(image:UIImage, atIndexPath indexPath:NSIndexPath, tableView:UITableView) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? CardCell else { return }
            cell.cardArtImageView?.image = image
            var item = self[indexPath.row]!
            item.image = image
        }
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Delete:
            tableView?.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Insert:
            tableView?.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Move:
            tableView?.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
        case .Update:
            tableView?.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        }
    }
    
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView?.beginUpdates()
    }
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView?.endUpdates()
    }
}

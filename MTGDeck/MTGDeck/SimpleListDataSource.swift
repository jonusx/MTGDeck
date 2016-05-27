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

public class SimpleListDataSource<T where T: SimpleListDisplayable, T: NSManagedObject>: NSObject, UITableViewDataSource {
    private(set) var items:[T] = []
    var delegate:SimpleListDataSourceDelegate? {
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
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cardCell", forIndexPath: indexPath) as! CardCell
        let item = items[indexPath.row]
        let itemName = item.title ?? "" as NSString
        
        if let art = item.image {
            cell.cardArtImageView?.image = art
        }
        else
        {
            if let item = item as? MTGCard {
                DataManager.sharedManager.artDownloader.artForCard(item, completion: { (image) in
                    guard let image = image else { return }
                    self.loadImage(image, atIndexPath: indexPath, tableView: tableView)
                })
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
        cell.nameLabel?.text = items[indexPath.row].title
        return cell
    }
    
    func reload() {
        guard let delegate = delegate else { return }
        items = try! context.executeFetchRequest(delegate.fetchRequest) as! Array<T>
        tableView?.reloadData()
    }
    
    func loadImage(image:UIImage, atIndexPath indexPath:NSIndexPath, tableView:UITableView) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? CardCell else { return }
            cell.cardArtImageView?.image = image
            self.items[indexPath.row].image = image
        }
    }
    
    
}

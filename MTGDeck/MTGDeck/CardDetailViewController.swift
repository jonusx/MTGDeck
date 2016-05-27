//
//  CardDetailViewController.swift
//  MTGDeck
//
//  Created by Mathew Cruz on 5/24/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//

import UIKit

class CardDetailViewController: UIViewController {
    @IBOutlet weak var nameLabel:UILabel?
    @IBOutlet weak var manaCostLabel:UILabel?
    @IBOutlet weak var typeLabel:UILabel?
    @IBOutlet weak var cardArtImageView:UIImageView?
    var card:MTGCard?

    override func viewDidLoad() {
        super.viewDidLoad()
        displayCard(card)
    }
}

extension CardDetailViewController {
    func displayCard(card:MTGCard?) {
        title = card?.name
        nameLabel?.text = card?.name
        manaCostLabel?.text = card?.manaCostString
        typeLabel?.text = card?.text
        guard let cardToDisplay = card else { return }
        DataManager.sharedManager.artDownloader.artForCard(cardToDisplay, completion: { (image) in
            guard let image = image else { return }
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                self.cardArtImageView?.image = image
            })
        })
    }
}

//
//  FisherViewController.swift
//  MTGDeck
//
//  Created by Mathew Cruz on 6/5/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//

import UIKit
import GameplayKit

class Fisher {
    private var cards:[MTGCard]
    var fishedCards:[MTGCard] = []
    init(cards:[MTGCard]) {
        self.cards = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(cards) as! [MTGCard]
    }
    
    func fish(count:Int) -> [MTGCard]? {
        var count = count
        if count == 0 {
            return nil
        }
        if count > cards.count {
            count = cards.count
        }
        let fished = (0..<count).map { _ in cards.removeFirst() }
        fishedCards.insertContentsOf(fished, at: 0)
        return fished
    }
    
    func drawHand() -> [MTGCard]? {
        return fish(7)
    }
    
    func total() -> Int {
        return cards.count
    }
}

class FisherViewController: UIViewController {
    var deck:MTGDeck? {
        didSet {
            self.title = deck?.title
            var allCards:[MTGCard] = []
            for cardInDeck in deck!.cards! {
                let cardInDeck = cardInDeck as! MTGCardInDeck
                for _ in 0..<(cardInDeck.count! as Int) {
                   allCards.append(cardInDeck.card!)
                }
            }
            fisher = Fisher(cards: allCards)
        }
    }
    
    var fisher:Fisher?
    
    @IBOutlet weak var cardTable:UITableView?
    
    var cardDataSource:SimpleListDataSource<MTGCard>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardDataSource = SimpleListDataSource(context: DataManager.sharedManager.personalContext)
        cardDataSource?.tableView = cardTable
        cardTable?.reloadData()
        
    }
    
    @IBAction func fish() {
        if fisher?.fishedCards.count == 0 {
            fisher?.drawHand()
            cardDataSource?.reload(fisher!.fishedCards)
        }
        else
        {
            fisher?.fish(1)
            cardDataSource?.reload(fisher!.fishedCards)
        }
    }
}

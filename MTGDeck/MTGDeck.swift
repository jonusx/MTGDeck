//
//  MTGDeck.swift
//  MTGDeck
//
//  Created by Mathew Cruz on 5/26/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//

import Foundation
import CoreData

typealias ColorMap = (red:Int, white:Int, black:Int, green:Int, blue:Int)
struct ColorBreakdown {
    enum breakdownColor {
        case Red, White, Green, Blue, Black
    }
    let red:Double
    let green:Double
    let blue:Double
    let white:Double
    let black:Double
    let colorless:Double
    init?(deck:MTGDeck) {
        guard let cards = deck.cards as? Set<MTGCardInDeck> else { return nil }
        var red = 0.0
        var green = 0.0
        var blue = 0.0
        var white = 0.0
        var black = 0.0
        var colorless = 0.0
        for cardInDeck in cards {
            let card = cardInDeck.card!
            red += card.manaCostRed as! Double * (cardInDeck.count as! Double)
            white += card.manaCostWhite as! Double * (cardInDeck.count as! Double)
            green += card.manaCostGreen as! Double * (cardInDeck.count as! Double)
            blue += card.manaCostBlue as! Double * (cardInDeck.count as! Double)
            black += card.manaCostBlack as! Double * (cardInDeck.count as! Double)
            colorless += card.manaCostColorless as! Double * (cardInDeck.count as! Double)
        }
        self.red = red
        self.green = green
        self.blue = blue
        self.white = white
        self.black = black
        self.colorless = colorless
    }
    func totalMana() -> Double {
        return red + green + blue + black + white + colorless
    }
    
    var colors:ColorMap {
        return ColorMap(Int(red), Int(white), Int(black), Int(green), Int(blue))
    }
}

struct CurveBreakDown {
    private var histogram:NSCountedSet = NSCountedSet()
    let maxCost:Int
    init?(deck:MTGDeck) {
        guard let cards = deck.cards as? Set<MTGCardInDeck> else { return nil }
        var maxCost = 0
        for cardInDeck in cards {
            let cost = cardInDeck.card!.convertedManaCost as! Int
            maxCost = max(maxCost, cost)
            for _ in 0..<(cardInDeck.count! as Int) { histogram.addObject(cost) }
        }
        self.maxCost = maxCost
    }
    subscript(index:Int) -> Int {
        get { return histogram.countForObject(index) }
    }
}

@objc(MTGDeck)
class MTGDeck: NSManagedObject {
    lazy var colorBreakDown:ColorBreakdown? = ColorBreakdown(deck:self)
    lazy var curveBreakDown:CurveBreakDown? = CurveBreakDown(deck: self)
    
    override func willSave() {
        super.willSave()
        colorBreakDown = ColorBreakdown(deck: self)
        curveBreakDown = CurveBreakDown(deck: self)
    }
    
    override func didChangeValueForKey(inKey: String, withSetMutation inMutationKind: NSKeyValueSetMutationKind, usingObjects inObjects: Set<NSObject>) {
        super.didChangeValueForKey(inKey, withSetMutation: inMutationKind, usingObjects: inObjects)
        if inKey == "cards" {
            colorBreakDown = ColorBreakdown(deck: self)
            curveBreakDown = CurveBreakDown(deck: self)
        }
    }
}

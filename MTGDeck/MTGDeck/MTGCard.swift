//
//  MTGCard.swift
//  MTGDeck
//
//  Created by Mathew Cruz on 5/21/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//

import UIKit
import CoreData

@objc(MTGCard)
class MTGCard: NSManagedObject {
    
    lazy var cardArt:UIImage? = {
        guard let fullImage = self.fullImage else {
            return nil
        }
        return UIImage(data:fullImage)
    }()
    
    override func willSave() {
        let total:Int = [manaCostWhite, manaCostGreen, manaCostBlack, manaCostBlue, manaCostRed, manaCostColorless].reduce(0) { (number, color) -> Int in
            let count = color ?? 0
            return number + count.integerValue
        }
        setPrimitiveValue(total, forKey: "convertedManaCost")
        super.willSave()
    }
    
    
}

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
    
    func toDictionary() -> NSDictionary {
        var dictionary:[NSObject : AnyObject] = [:]
        dictionary["name"] = name
        dictionary["manaCost"] = manaCostString
        dictionary["type"] = type
        dictionary["rarity"] = rarity?.rarity!
        dictionary["text"] = text
        dictionary["flavor"] = flavor
        dictionary["artist"] = artist?.name!
        dictionary["number"] = String(number)
        dictionary["power"] = power ?? "0"
        dictionary["toughness"] = toughness ?? "0"
        dictionary["multiverseid"] = String(multiverseid ?? 0)
        dictionary["imageName"] = imageName
        dictionary["id"] = cardID
        dictionary["loyalty"] = String(loyalty ?? 0)
        
        if let superTypes = superTypes as? Set<MTGType> {
            let types:[String] = superTypes.map({ $0.type! })
            dictionary["supertypes"] = types
        }
        
        if let types = types as? Set<MTGType> {
            let types:[String] = types.map({ $0.type! })
            dictionary["types"] = types
        }
        
        if let subtypes = subTypes as? Set<MTGType> {
            let types:[String] = subtypes.map({ $0.type! })
            dictionary["subtypes"] = types
        }
        
        if let colors = colors as? Set<MTGColor> {
            let colors:[String] = colors.map({ $0.color! })
            dictionary["colors"] = colors
        }
        return dictionary as NSDictionary
    }
}

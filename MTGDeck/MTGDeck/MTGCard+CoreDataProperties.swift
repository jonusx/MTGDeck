//
//  MTGCard+CoreDataProperties.swift
//  MTGDeck
//
//  Created by Mathew Cruz on 5/21/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension MTGCard {

    @NSManaged var cardID: String?
    @NSManaged var convertedManaCost: NSNumber?
    @NSManaged var flavor: String?
    @NSManaged var imageName: String?
    @NSManaged var loyalty: NSNumber?
    @NSManaged var manaCostAny: NSNumber?
    @NSManaged var manaCostBlack: NSNumber?
    @NSManaged var manaCostBlue: NSNumber?
    @NSManaged var manaCostColorless: NSNumber?
    @NSManaged var manaCostGreen: NSNumber?
    @NSManaged var manaCostRed: NSNumber?
    @NSManaged var manaCostWhite: NSNumber?
    @NSManaged var multiverseid: NSNumber?
    @NSManaged var name: String?
    @NSManaged var number: NSNumber?
    @NSManaged var power: String?
    @NSManaged var text: String?
    @NSManaged var toughness: String?
    @NSManaged var type: String?
    @NSManaged var manaCostString: String?
    @NSManaged var artist: MTGArtist?
    @NSManaged var colors: NSSet?
    @NSManaged var rarity: MTGRarity?
    @NSManaged var set: NSSet?
    @NSManaged var subTypes: NSSet?
    @NSManaged var superTypes: NSSet?
    @NSManaged var types: NSSet?
    @NSManaged var fullImage: NSData?
    @NSManaged var cc: NSSet?

}

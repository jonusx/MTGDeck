//
//  MTGCardInDeck+CoreDataProperties.swift
//  MTGDeck
//
//  Created by Mathew Cruz on 5/26/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension MTGCardInDeck {

    @NSManaged var count: NSNumber?
    @NSManaged var deck: MTGDeck?
    @NSManaged var card: MTGCard?

}

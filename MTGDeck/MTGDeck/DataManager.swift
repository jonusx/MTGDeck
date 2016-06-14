//
//  DataManager.swift
//  MTGDeck
//
//  Created by Mathew Cruz on 5/21/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//

import CoreData
import UIKit

class DataManager {
    static let DataManagerDidMergeData:String = "DataManagerDidMergeData"
    static let sharedManager = DataManager(name: "StoredData.sqlite", options: nil)
    lazy var personalManager:DataManager = DataManager(name: "StoredPersonalData.sqlite", options: [NSPersistentStoreUbiquitousContentNameKey : "mtgdeck"], local:false)
    var personalContext:NSManagedObjectContext {
        return personalManager.managedObjectContext ?? managedObjectContext
    }
    private let storeName:String
    private let options:[NSObject : AnyObject]?
    let artDownloader = CardArtDownloader()
    
    lazy var dateFormatter:NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "YYYY-MM-DD"
        return formatter
    }()
    
    init(name:String, options:[NSObject : AnyObject]?, local:Bool = true) {
        storeName = name
        self.options = options
        if local == false {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DataManager.resetStore), name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: managedObjectContext.persistentStoreCoordinator)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DataManager.merge(_:)), name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: managedObjectContext.persistentStoreCoordinator)

        }
    }
    
    @objc func merge(notification:NSNotification?) {
        if let notification = notification {
            managedObjectContext.performBlock({
                self.managedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
                NSNotificationCenter.defaultCenter().postNotificationName(DataManager.DataManagerDidMergeData, object: nil, userInfo: nil)
            })
        }
    }
    
    @objc func resetStore() {
        managedObjectContext.performBlock({ self.managedObjectContext.reset() })
    }
    
    lazy var applicationDocumentsDirectory: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("MTGDeck", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.storeName)
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: self.options)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as? AnyObject
            let wrappedError = NSError(domain: "MTG_DATA", code: 1000, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            try! NSFileManager.defaultManager().removeItemAtURL(url)
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
}

private typealias DataManagerSetParser = DataManager
extension DataManagerSetParser {
    
    static let regex = try! NSRegularExpression(pattern: "\\{(.+?)\\}", options: [])
    typealias ColorCost = (black:Int,white:Int,red:Int,green:Int,blue:Int,red:Int,colorless:Int)
    
    func parse(context:NSManagedObjectContext) {
        let data = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("AllSets-x", ofType: "json")!)!
        let json = try! NSJSONSerialization.JSONObjectWithData(data, options: []) as! NSDictionary
        
        let privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        
        var saveCounter = 0
        for (_, set) in json {
            parseSet(set as! NSDictionary, intoContext: privateContext)
            saveCounter += 1
            if saveCounter == 10 {
                saveCounter = 0
            }
        }
        
        
    }
    
    func parseSet(set:NSDictionary, intoContext context:NSManagedObjectContext) {
        context.performBlock {
            let fetchRequest = NSFetchRequest(entityName: "MTGSet")
            fetchRequest.predicate = NSPredicate(format: "code LIKE[c] %@", argumentArray: [set["code"]!])
            let result = context.countForFetchRequest(fetchRequest, error: nil)
            if result > 1 {
                return
            }
            
            let newSet = NSEntityDescription.insertNewObjectForEntityForName("MTGSet", inManagedObjectContext: context) as! MTGSet
            newSet.block = set["block"] as? String
            newSet.code = set["code"] as? String
            newSet.magicCardsInfoCode = set["magicCardsInfoCode"] as? String
            if let dateString = set["releaseDate"] as? String {
                newSet.releaseDate = self.dateFormatter.dateFromString(dateString)
            }
            newSet.type = set["type"] as? String
            newSet.name = set["name"] as? String
            
            if let cards = set["cards"] as? [NSDictionary] {
                for card in cards {
                    self.parseCard(card, intoContext: context)
                }
            }
            print(newSet.name)
            
            try! context.save()
            context.reset()
        }
    }
    
    func parseCard(card:NSDictionary, intoContext context:NSManagedObjectContext) -> MTGCard? {
        let fetchRequest = NSFetchRequest(entityName: "MTGCard")
        fetchRequest.predicate = NSPredicate(format: "cardID == %@", argumentArray: [card["id"]!])
        let result = context.countForFetchRequest(fetchRequest, error: nil)
        if result > 1 {
            return nil
        }
        let newCard = NSEntityDescription.insertNewObjectForEntityForName("MTGCard", inManagedObjectContext: context) as! MTGCard
        if let types = card["supertypes"] as? [String] where types.isEmpty == false {
            newCard.superTypes = Set<MTGType>(typeFromTypeArray(types, context: context))
        }
        if let types = card["types"] as? [String] where types.isEmpty == false {
            newCard.types = Set<MTGType>(typeFromTypeArray(types, context: context))
        }
        if let types = card["subtypes"] as? [String] where types.isEmpty == false {
            newCard.subTypes = Set<MTGType>(typeFromTypeArray(types, context: context))
        }
        if let colors = card["colors"] as? [String] where colors.isEmpty == false {
            newCard.colors = Set<MTGColor>(colorsFromColorArray(colors, context: context))
        }
        
        newCard.name = card["name"] as? String
        if let costString = card["manaCost"] as? String {
            newCard.manaCostString = costString
            let cost = manaCostFromString(costString)
            newCard.manaCostColorless = cost.colorless
            newCard.manaCostRed = cost.red
            newCard.manaCostBlue = cost.blue
            newCard.manaCostBlack = cost.black
            newCard.manaCostGreen = cost.green
            newCard.manaCostWhite = cost.white
        }
        newCard.type = card["type"] as? String
        newCard.rarity = rarityFromString(card["rarity"] as! String, context: context)
        newCard.text = card["text"] as? String
        newCard.flavor = card["flavor"] as? String
        newCard.artist = artistFromString(card["artist"] as! String, context: context)
        if let numberString = card["number"] as? String, number = Int(numberString) {
            newCard.number = number
        }
        newCard.power = card["power"] as? String
        newCard.toughness = card["toughness"] as? String
        
        if let multiverseidString = card["multiverseid"] as? String, multiverseid = Int(multiverseidString) {
            newCard.multiverseid = multiverseid
        }
        newCard.imageName = card["imageName"] as? String
        newCard.cardID = card["id"] as? String
        if let loyaltyString = card["loyalty"] as? String {
            newCard.loyalty = Int(loyaltyString)!
        }
        return newCard
    }
    
    func colorsFromColorArray(colors:[String], context:NSManagedObjectContext) -> [MTGColor] {
        let fetchRequest = NSFetchRequest(entityName: "MTGColor")
        fetchRequest.predicate = NSPredicate(format: "color IN %@", colors)
        var colorObjects:[MTGColor] = []
        colorObjects += try! context.executeFetchRequest(fetchRequest) as! [MTGColor]
        if colorObjects.count != colors.count {
            colorObjects += colors.filter({ (color) -> Bool in
                return colorObjects.count == 0 || colorObjects.indexOf({ $0.color == color }) == nil
            }).map { (colorString) -> MTGColor in
                let newColor = NSEntityDescription.insertNewObjectForEntityForName("MTGColor", inManagedObjectContext: context) as! MTGColor
                newColor.color = colorString
                return newColor
            }
        }
        return colorObjects
    }
    
    func typeFromTypeArray(types:[String], context:NSManagedObjectContext) -> [MTGType] {
        let fetchRequest = NSFetchRequest(entityName: "MTGType")
        fetchRequest.predicate = NSPredicate(format: "type IN %@", types)
        var typeObjects:[MTGType] = []
        typeObjects += try! context.executeFetchRequest(fetchRequest) as! [MTGType]
        if typeObjects.count != types.count {
            typeObjects += types.filter({ (type) -> Bool in
                return typeObjects.count == 0 || typeObjects.indexOf({ $0.type == type }) == nil
            }).map { (typeString) -> MTGType in
                let newType = NSEntityDescription.insertNewObjectForEntityForName("MTGType", inManagedObjectContext: context) as! MTGType
                newType.type = typeString
                return newType
            }
        }
        return typeObjects
    }
    
    func rarityFromString(rarityString:String, context:NSManagedObjectContext) -> MTGRarity {
        let fetchRequest = NSFetchRequest(entityName: "MTGRarity")
        fetchRequest.predicate = NSPredicate(format: "rarity LIKE[cd] %@", rarityString)
        let rarityObjects = try! context.executeFetchRequest(fetchRequest) as! [MTGRarity]
        if rarityObjects.isEmpty {
            let newRarity = NSEntityDescription.insertNewObjectForEntityForName("MTGRarity", inManagedObjectContext: context) as! MTGRarity
            newRarity.rarity = rarityString
            return newRarity
        }
        return rarityObjects.first!
    }
    
    func artistFromString(artistString:String, context:NSManagedObjectContext) -> MTGArtist {
        let fetchRequest = NSFetchRequest(entityName: "MTGArtist")
        fetchRequest.predicate = NSPredicate(format: "name LIKE[cd] %@", artistString)
        let artistObjects = try! context.executeFetchRequest(fetchRequest) as! [MTGArtist]
        if artistObjects.isEmpty {
            let newArtist = NSEntityDescription.insertNewObjectForEntityForName("MTGArtist", inManagedObjectContext: context) as! MTGArtist
            newArtist.name = artistString
            return newArtist
        }
        return artistObjects.first!
    }
    
    
    func manaCostFromString(costString:String) -> ColorCost {
        return DataManagerSetParser.regex.matchesInString(costString, options: [], range: NSRange(location: 0, length: costString.characters.count)).reduce(ColorCost(black: 0,white:0,red:0,green:0,blue:0,red:0,colorless:0), combine: { (cost, result) -> ColorCost in
            let startIndex = costString.startIndex.advancedBy(result.rangeAtIndex(1).location)
            let matchRange = startIndex..<startIndex.advancedBy(result.rangeAtIndex(1).length)
            var match = costString.substringWithRange(matchRange)
            var multiplier = 1
            
            if matchRange.count > 1 {
                multiplier = Int(String(match.characters.first!)) ?? 1
                match = String(match.characters.last!)
            }
            var cost = cost
            switch match {
            case "B":
                cost.black += multiplier
            case "U":
                cost.blue += multiplier
            case "R":
                cost.red += multiplier
            case "G":
                cost.green += multiplier
            case "W":
                cost.white += multiplier
            case "X":
                break
            default:
                cost.colorless += Int(match) ?? 1
            }
            return cost
        })
    }

}

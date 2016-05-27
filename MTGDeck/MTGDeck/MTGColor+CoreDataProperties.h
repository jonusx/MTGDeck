//
//  MTGColor+CoreDataProperties.h
//  MTGDeck
//
//  Created by Mathew Cruz on 5/16/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MTGColor.h"
@class MTGCard;

NS_ASSUME_NONNULL_BEGIN

@interface MTGColor (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *color;
@property (nullable, nonatomic, retain) NSSet<MTGCard *> *cards;

@end

@interface MTGColor (CoreDataGeneratedAccessors)

- (void)addCardsObject:(MTGCard *)value;
- (void)removeCardsObject:(MTGCard *)value;
- (void)addCards:(NSSet<MTGCard *> *)values;
- (void)removeCards:(NSSet<MTGCard *> *)values;

@end

NS_ASSUME_NONNULL_END

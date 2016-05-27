//
//  MTGSet+CoreDataProperties.h
//  MTGDeck
//
//  Created by Mathew Cruz on 5/16/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MTGSet.h"
@class MTGCard;

NS_ASSUME_NONNULL_BEGIN

@interface MTGSet (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSString *magicCardsInfoCode;
@property (nullable, nonatomic, retain) NSDate *releaseDate;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSString *block;
@property (nullable, nonatomic, retain) NSSet<MTGCard *> *cards;

@end

@interface MTGSet (CoreDataGeneratedAccessors)

- (void)addCardsObject:(MTGCard *)value;
- (void)removeCardsObject:(MTGCard *)value;
- (void)addCards:(NSSet<MTGCard *> *)values;
- (void)removeCards:(NSSet<MTGCard *> *)values;

@end


NS_ASSUME_NONNULL_END

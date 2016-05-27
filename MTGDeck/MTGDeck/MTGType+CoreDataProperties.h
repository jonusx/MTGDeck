//
//  MTGType+CoreDataProperties.h
//  MTGDeck
//
//  Created by Mathew Cruz on 5/16/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MTGType.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTGType (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSSet<MTGCard *> *cardsOfSuperType;
@property (nullable, nonatomic, retain) NSSet<MTGCard *> *cardsOfType;
@property (nullable, nonatomic, retain) NSSet<MTGCard *> *cardsOfSubType;

@end

@interface MTGType (CoreDataGeneratedAccessors)

- (void)addCardsOfSuperTypeObject:(MTGCard *)value;
- (void)removeCardsOfSuperTypeObject:(MTGCard *)value;
- (void)addCardsOfSuperType:(NSSet<MTGCard *> *)values;
- (void)removeCardsOfSuperType:(NSSet<MTGCard *> *)values;

- (void)addCardsOfTypeObject:(MTGCard *)value;
- (void)removeCardsOfTypeObject:(MTGCard *)value;
- (void)addCardsOfType:(NSSet<MTGCard *> *)values;
- (void)removeCardsOfType:(NSSet<MTGCard *> *)values;

- (void)addCardsOfSubTypeObject:(MTGCard *)value;
- (void)removeCardsOfSubTypeObject:(MTGCard *)value;
- (void)addCardsOfSubType:(NSSet<MTGCard *> *)values;
- (void)removeCardsOfSubType:(NSSet<MTGCard *> *)values;

@end

NS_ASSUME_NONNULL_END

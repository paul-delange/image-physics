//
//  InAppPurchaseProvider.h
//  app
//
//  Created by MacBook Pro on 24/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import <Foundation/Foundation.h>

extern NSString* kProductPurchasedNotification;
extern NSString* kProductPurchasedIdentifierKey;

extern NSString* kProductIdentifierAlternativeSearches;
extern NSString* kProductIdentifierPaginatedSearches;

@interface InAppPurchaseProvider : NSObject

/*
 * Returns NO if a product with this identifier was not found,
 * otherwise YES if the purchase sequence started normally.
 */
+ (BOOL) purchase: (NSString*) identifier;

@end

@interface SKProduct (LocalizedPrice)

@property (nonatomic, readonly) NSString* localizedPrice;

@end
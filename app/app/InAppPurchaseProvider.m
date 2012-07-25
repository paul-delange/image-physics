//
//  InAppPurchaseProvider.m
//  app
//
//  Created by MacBook Pro on 24/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import "InAppPurchaseProvider.h"
#import "InAppPurchaseProvider+SecurityBreach.h"

#import <RestKit/RestKit.h>

NSString* kProductPurchasedNotification = @"ProductPurchased";
NSString* kProductPurchasedIdentifierKey = @"ProductPurchasedIdentifier";
NSString* kProductIdentifierAlternativeSearches = @"Unlock.Other.Search";
NSString* kProductIdentifierPaginatedSearches = @"Unlock.More.Search";


@interface InAppPurchaseProvider ()

+ (BOOL) verifyPurchase: (SKPaymentTransaction*) transaction;

@end

@implementation InAppPurchaseProvider

static NSMutableArray* IAPproducts = nil;

+ (void) load {
    
    @autoreleasepool {
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(reachabilityWasDetermined:)
                                                     name: RKReachabilityWasDeterminedNotification
                                                   object: nil];
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver: (id<SKPaymentTransactionObserver>)self];
    }
}

+ (void) reachabilityWasDetermined: (NSNotification*) notification {
    RKReachabilityObserver* observer = notification.object;
    
    if( [observer isNetworkReachable] ) {
        if( [SKPaymentQueue canMakePayments] ) {
            NSSet* identifierSet = [NSSet setWithObjects: kProductIdentifierAlternativeSearches, kProductIdentifierPaginatedSearches, nil];
            SKProductsRequest* request = [[SKProductsRequest alloc] initWithProductIdentifiers: identifierSet];
            request.delegate = (id<SKProductsRequestDelegate>)[self class];
            [request start];
        }
    }
}

+ (BOOL) purchase: (NSString*) identifier {
    NSPredicate* predicate = [NSPredicate predicateWithFormat: @"productIdentifier == %@", identifier];
    SKProduct* product = [[IAPproducts filteredArrayUsingPredicate: predicate] lastObject];
    
    if( product ) {
        
        SKPayment* payment = [SKPayment paymentWithProduct: product];
        [[SKPaymentQueue defaultQueue] addPayment: payment];
        
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark - SKProductRequestDelegate
+ (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        IAPproducts = [[NSMutableArray alloc] init];
    });
    
    [IAPproducts removeAllObjects];
    [IAPproducts addObjectsFromArray: response.products];
    
    if( [response.products count] ) {
        NSLog(@"Available IAPs %@", [response.products valueForKeyPath: @"@unionOfObjects.productIdentifier"]);
    }
    
    if( [response.invalidProductIdentifiers count] ) {
        NSLog(@"These products were invalid %@",  response.invalidProductIdentifiers);
    }
}

+ (void) request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"App Store request failed with error: %@", error);
}

#pragma mark - SKPaymentTransactionObserver
+ (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored:
            {/*
                BOOL goodPurchase = [self verifyPurchase: transaction];
                if( goodPurchase ) {
                    
                    
                    kInAppPurchaseVerificationComplete verificationComplete = ^(BOOL verified ) {
                        if( verified ) { 
                            UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"IAP"
                                                                            message: @"This in app purchase is verified"
                                                                           delegate: nil
                                                                  cancelButtonTitle: @"OK"
                                                                  otherButtonTitles: nil];
                            [alert show];
                            */
                
                [[NSUserDefaults standardUserDefaults] setBool: YES forKey: transaction.payment.productIdentifier];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                            NSDictionary* userInfo = [NSDictionary dictionaryWithObject: transaction.payment.productIdentifier
                                                                                 forKey: kProductPurchasedIdentifierKey];
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName: kProductPurchasedNotification
                                                                                object: nil
                                                                              userInfo: userInfo];
                
                
                
                      /*  }
                        else {
                            UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"IAP"
                                                                            message: @"This in app purchase has a fake receipt"
                                                                           delegate: nil
                                                                  cancelButtonTitle: @"OK"
                                                                  otherButtonTitles: nil];
                            [alert show];
                        }
                    };
                    
                    [self verifyReceipt: transaction.transactionReceipt
                             completion: verificationComplete];
                    
                }
                else {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"IAP"
                                                                    message: @"This in app purchase is not verified!!"
                                                                   delegate: nil
                                                          cancelButtonTitle: @"OK"
                                                          otherButtonTitles: nil];
                    [alert show];
                } */
                break;
            }
            case SKPaymentTransactionStateFailed:
            {   
                switch (transaction.error.code) {
                    case SKErrorPaymentCancelled:
                    case SKErrorPaymentInvalid:
                    case SKErrorPaymentNotAllowed:
                    case SKErrorUnknown:
                    case SKErrorClientInvalid:
                        break;
                        
                    default:
                        break;
                }
                
                break;
            }
            default:
                break;
        }
        if( transaction.transactionState != SKPaymentTransactionStatePurchasing )
            [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    }
}

@end

@implementation SKProduct (LocalizedPrice)

- (NSString *)localizedPrice {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale: self.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:self.price];
    return formattedString;
}

@end

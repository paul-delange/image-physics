//
//  InAppPurchaseProvider+SecurityBreach.h
//  app
//
//  Created by MacBook Pro on 24/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import "InAppPurchaseProvider.h"

// There is a security breach
// http://developer.apple.com/library/ios/#releasenotes/StoreKit/IAP_ReceiptValidation/_index.html

typedef void (^kInAppPurchaseVerificationComplete)(BOOL verified);

@interface InAppPurchaseProvider (SecurityBreach)

+ (BOOL) verifyTransaction: (SKPaymentTransaction*) transaction;
+ (void) verifyReceipt: (NSData*) transactionReceipt completion: (kInAppPurchaseVerificationComplete) completion;

@end

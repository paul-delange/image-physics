//
//  DataProviderTest.m
//  app
//
//  Created by MacBook Pro on 17/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import "configureRestKit.h"

#import <RestKit/RestKit.h>
#import <GHUnitIOS/GHUnit.h>

@interface DataProviderTest : GHAsyncTestCase

@end

@implementation DataProviderTest

- (void) setUpClass {
    RKObjectManager* manager = [RKObjectManager objectManagerWithBaseURLString: @""];
    manager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename: @"Database"];
    configureRestKit(manager);
}

- (void) testSearch {
    
}

@end

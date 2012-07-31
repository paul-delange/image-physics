//
//  AssetsPaginator.h
//  app
//
//  Created by MacBook Pro on 25/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import "Paginator.h"

@interface AssetsPaginator : NSObject <Paginator>

@property (nonatomic, readonly) NSUInteger perPage;
@property (nonatomic, readonly) NSUInteger objectCount;

@end

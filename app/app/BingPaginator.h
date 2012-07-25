//
//  BingPaginator.h
//  app
//
//  Created by MacBook Pro on 17/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import "Paginator.h"

@interface BingPaginator : NSObject <Paginator>

+ (id) paginatorWithSearchTerm: (NSString*) searchTerm;

@property (nonatomic, readonly) NSUInteger perPage;
@property (nonatomic, readonly) NSUInteger objectCount;

@end
//
//  FlikrPaginator.h
//  app
//
//  Created by MacBook Pro on 03/08/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import "Paginator.h"

@interface FlikrPaginator : NSObject <Paginator>

+ (id) paginatorWithSearchTerm: (NSString*) searchTerm;

@property (nonatomic, readonly) NSUInteger perPage;
@property (nonatomic, readonly) NSUInteger objectCount;

@end

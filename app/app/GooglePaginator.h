//
//  GooglePaginator.h
//  app
//
//  Created by Paul de Lange on 29/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import "Paginator.h"

@interface GooglePaginator : NSObject <Paginator>

+ (id) paginatorWithSearchTerm: (NSString*) searchTerm;

@property (nonatomic, readonly) NSUInteger perPage;
@property (nonatomic, readonly) NSUInteger objectCount;

@end

//
//  BingPaginator.h
//  app
//
//  Created by MacBook Pro on 17/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKURL;
@class RKObjectLoader;
@class RKObjectMappingProvider;

typedef void(^BingPaginatorDidLoadObjectsAtOffsetBlock)(NSArray* objects, NSUInteger offset);
typedef void(^BingPaginatorDidFailWithErrorBlock)(NSError* error, RKObjectLoader* loader);

@protocol BingPaginatorDelegate;

@interface BingPaginator : NSObject

+ (id) paginatorWithSearchTerm: (NSString*) searchTerm;

@property (nonatomic, weak) id<BingPaginatorDelegate> delegate;
@property (nonatomic, copy) BingPaginatorDidLoadObjectsAtOffsetBlock onDidLoadObjectsAtOffset;
@property (nonatomic, copy) BingPaginatorDidFailWithErrorBlock onDidFailWithError;

@property (nonatomic, readonly) NSUInteger perPage;
@property (nonatomic, readonly) NSUInteger objectCount;

- (void) loadNextPage;
- (void) loadPreviousPage;
- (void) loadPageAtOffset: (NSUInteger) offset;

@end

@protocol BingPaginatorDelegate <NSObject>
@optional
- (void) configureObjectLoader: (RKObjectLoader*) objectLoader;
@end
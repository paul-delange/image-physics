//
//  Paginator.h
//  app
//
//  Created by MacBook Pro on 25/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectLoader;
@protocol PaginatorDelegate;

typedef void(^PaginatorDidLoadObjectsAtOffsetBlock)(NSArray* objects, NSUInteger offset);
typedef void(^PaginatorDidFailWithErrorBlock)(NSError* error, RKObjectLoader* loader);

@protocol Paginator <NSObject>

@property (nonatomic, weak) id<PaginatorDelegate> delegate;
@property (nonatomic, copy) PaginatorDidLoadObjectsAtOffsetBlock onDidLoadObjectsAtOffset;
@property (nonatomic, copy) PaginatorDidFailWithErrorBlock onDidFailWithError;

- (void) loadNextPage;
- (void) loadPreviousPage;
- (void) loadPageAtOffset: (NSUInteger) offset;

- (BOOL) hasNextPage;
- (BOOL) hasPreviousPage;

@end

@protocol PaginatorDelegate <NSObject>
@optional
- (void) configureObjectLoader: (RKObjectLoader*) objectLoader;
@end

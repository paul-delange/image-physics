//
//  BingPaginator.m
//  app
//
//  Created by MacBook Pro on 17/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import "BingPaginator.h"

#import <RestKit/RestKit.h>
#import <RestKit/RKManagedObjectLoader.h>

static NSUInteger BingPaginatorDefaultPerPage = 25;

@interface BingPaginator () <RKObjectLoaderDelegate>

+ (id) paginatorWithPattern: (NSString*) pattern;
- (id)initWithPattern:(NSString*) pattern;

@property (nonatomic, readonly) NSUInteger currentOffset;
@property (nonatomic, strong) NSString* pattern;

@end

@implementation BingPaginator
@synthesize delegate;
@synthesize onDidLoadObjectsAtOffset, onDidFailWithError;
@synthesize perPage;
@synthesize pattern;
@synthesize currentOffset;
@synthesize objectCount;

+ (id) paginatorWithSearchTerm: (NSString*) searchTerm {
    
    NSString* urlEncoded = [searchTerm stringByAddingURLEncoding];
    NSString* pattern = [NSString stringWithFormat: @"/json.aspx?AppId=EADA47E8862F8D8EE67D68882289189A2115F6AA&Sources=Image&Query=%@&Image.Count=:perPage&Image.Offset=:currentOffset", urlEncoded];
    
    return [self paginatorWithPattern: pattern];
}

+ (id) paginatorWithPattern:(NSString *)pattern {
    return [[self alloc] initWithPattern: pattern];
}

- (id)initWithPattern:(NSString *)p {
    self = [super init];
    if( self ) {
        pattern = [p copy];
        currentOffset = 0;
        objectCount = NSUIntegerMax;
        perPage = BingPaginatorDefaultPerPage;
    }
    return self;
}

- (BOOL) hasNextPage {
    if( self.perPage ) {
        BOOL lessThan5Pages = ( self.currentOffset / self.perPage ) < 3;
        BOOL hasMore = self.currentOffset + self.perPage < self.objectCount;
        return lessThan5Pages && hasMore;
    }
    else {
        return NO;
    }
    //return ;
}

- (BOOL) hasPreviousPage {
    return self.currentOffset > 0;
}
 
- (void) loadNextPage {
    [self loadPageAtOffset: self.currentOffset + self.perPage];
}

- (void) loadPreviousPage {
    [self loadPageAtOffset: self.currentOffset - self.perPage];
}

- (void) loadPageAtOffset: (NSUInteger) offset {
    currentOffset = offset;

    NSString* resPath = [self.pattern interpolateWithObject: self];
    
    RKObjectLoader* objectLoader = [[RKObjectManager sharedManager] loaderWithResourcePath: resPath];
    
    if( [self.delegate respondsToSelector: @selector(configureObjectLoader:)])
        [self.delegate configureObjectLoader: objectLoader];

    objectLoader.method = RKRequestMethodGET;
    objectLoader.delegate = self;
    
    [objectLoader send];
}

#pragma mark - RKObjectLoaderDelegate
- (void) objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    if( self.onDidLoadObjectsAtOffset ) {
        self.onDidLoadObjectsAtOffset(objects, self.currentOffset);
    }
}

- (void) objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    if(self.onDidFailWithError) {
        self.onDidFailWithError(error, objectLoader);
    }
}

- (void) objectLoader:(RKObjectLoader *)loader willMapData:(inout __autoreleasing id *)mappableData {
    NSError* error = nil;
    RKObjectMappingProvider* provider = [RKObjectManager sharedManager].mappingProvider;
    RKObjectMapping* mapping = provider.paginationMapping;
    
    RKObjectMappingOperation* operation = [RKObjectMappingOperation mappingOperationFromObject: *mappableData
                                                                                      toObject: self
                                                                                   withMapping: mapping];
    BOOL success = [operation performMapping: &error];
    if(!success) {
        currentOffset = 0;
    }
}

@end

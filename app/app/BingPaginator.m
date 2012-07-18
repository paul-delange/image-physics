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

+ (id) paginatorWithPatternURL: (RKURL*) patternURL;
- (id)initWithPatternURL:(RKURL *)aPatternURL;
- (BOOL) hasNextPage;
- (BOOL) hasPreviousPage;

@property (nonatomic, readonly) NSUInteger currentOffset;
@property (nonatomic, readonly) RKURL* URL;
@property (nonatomic, copy) RKURL* patternURL;

@end

@implementation BingPaginator
@synthesize delegate;
@synthesize onDidLoadObjectsAtOffset, onDidFailWithError;
@synthesize perPage;
@synthesize patternURL, URL;
@synthesize currentOffset;
@synthesize objectCount;

+ (id) paginatorWithSearchTerm: (NSString*) searchTerm {
    RKURL* baseURL = [RKObjectManager sharedManager].client.baseURL;
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @":perPage", @"Image.Count",
                            @":currentOffset", @"Image.Offset",
                            @"EADA47E8862F8D8EE67D68882289189A2115F6AA", @"AppId",
                            @"Image", @"Sources",
                            searchTerm, @"Query",
                            nil];
    return [self paginatorWithPatternURL: [baseURL URLByAppendingQueryParameters: params]];
}

+ (id) paginatorWithPatternURL: (RKURL*) patternURL {
    return [[self alloc] initWithPatternURL: patternURL ];
}

- (id)initWithPatternURL:(RKURL *)aPatternURL {
    self = [super init];
    if( self ) {
        patternURL = [aPatternURL copy];
        currentOffset = 0;
        objectCount = NSUIntegerMax;
        perPage = BingPaginatorDefaultPerPage;
    }
    return self;
}

- (BOOL) hasNextPage {
    return self.currentOffset + self.perPage < self.objectCount;
}

- (BOOL) hasPreviousPage {
    return self.currentOffset > 0;
}

- (RKURL*) URL {
    return [patternURL URLByInterpolatingResourcePathWithObject: self];
}
 
- (void) loadNextPage {
    [self loadPageAtOffset: self.currentOffset + self.perPage];
}

- (void) loadPreviousPage {
    [self loadPageAtOffset: self.currentOffset - self.perPage];
}

- (void) loadPageAtOffset: (NSUInteger) offset {
    currentOffset = offset;
    
    RKManagedObjectStore* store = [RKObjectManager sharedManager].objectStore;
    RKObjectMappingProvider* provider = [RKObjectManager sharedManager].mappingProvider;
    
    RKObjectLoader* objectLoader = [[RKManagedObjectLoader alloc] initWithURL: self.URL
                                                              mappingProvider: provider
                                                                  objectStore: store];
    
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

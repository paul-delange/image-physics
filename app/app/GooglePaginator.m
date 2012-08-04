//
//  GooglePaginator.m
//  app
//
//  Created by Paul de Lange on 29/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import "GooglePaginator.h"

#import <RestKit/RestKit.h>

static NSUInteger GooglePaginatorDefaultPerPage = 10;   //maximum

@interface GooglePaginator () <RKObjectLoaderDelegate>

+ (id) paginatorWithPattern: (NSString*) pattern;
- (id)initWithPattern:(NSString*) pattern;

@property (nonatomic, readonly) NSUInteger currentOffset;
@property (nonatomic, strong) NSString* pattern;

@end

@implementation GooglePaginator
@synthesize delegate;
@synthesize onDidLoadObjectsAtOffset, onDidFailWithError;
@synthesize perPage;
@synthesize pattern;
@synthesize currentOffset;
@synthesize objectCount;

+ (id) paginatorWithSearchTerm: (NSString*) searchTerm {
    
    NSString* urlEncoded = [searchTerm stringByAddingURLEncoding];
    NSString* pattern = [NSString stringWithFormat: @"https://www.googleapis.com/customsearch/v1?q=%@&cx=012688650386050678524:1n2t8uihlam&key=AIzaSyCpXbdM5G63KxpTJhwogammwJcmwStXw3M&searchType=image", urlEncoded];
    
    return [self paginatorWithPattern:  [pattern stringByAppendingString: @"&start=%d&num=%d"]];
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
        perPage = GooglePaginatorDefaultPerPage;
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
    
    NSString* fullPath = [NSString stringWithFormat: self.pattern, self.currentOffset, self.perPage];
    
    RKObjectManager* manager = [RKObjectManager sharedManager];
    
    [manager loadObjectsAtResourcePath: fullPath usingBlock: ^(RKObjectLoader *loader) {
        
        RKObjectMappingProvider* provider = [RKObjectMappingProvider mappingProviderUsingBlock: ^(RKObjectMappingProvider * mappingProvider) {
            RKManagedObjectStore* store = [RKObjectManager sharedManager].objectStore;
            
            RKManagedObjectMapping* resultMapping = [RKManagedObjectMapping mappingForClass: NSClassFromString(@"SearchResult")
                                                                       inManagedObjectStore: store];
            
            resultMapping.rootKeyPath = @"items";
            [resultMapping mapKeyPathsToAttributes:
             @"title", @"title",
             @"link", @"mediaURL",
             @"image.thumbnailLink", @"thumbURL",
             @"mime", @"contentType",
             @"image.width", @"width",
             @"image.height", @"height",
             @"image.contextLink", @"SourceUrl",
             nil];
            
            [mappingProvider setMapping: resultMapping forKeyPath: @"items"];
        }];
        loader.mappingProvider = provider;
        loader.additionalHTTPHeaders = [NSDictionary dictionaryWithObject: @"gzip" forKey: @"Accept-Encoding"];
        loader.delegate = self;
    }];
    
    NSDictionary* queryParams = [fullPath queryParameters];
    NSDictionary* params =@{ @"start" : [queryParams objectForKey: @"start"], @"term" : [queryParams objectForKey: @"q"] };
    [FlurryAnalytics logEvent: @"Google search" withParameters: params];
}

#pragma mark - RKObjectLoaderDelegate
- (void) objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    if( self.onDidLoadObjectsAtOffset ) {
        self.onDidLoadObjectsAtOffset(objects, self.currentOffset);
    }
}

- (void) objectLoader:(RKObjectLoader *)loader didFailWithError:(NSError *)error {
    if(self.onDidFailWithError) {
        self.onDidFailWithError(error, loader);
    }
}

- (void) objectLoader:(RKObjectLoader *)loader willMapData:(inout __autoreleasing id *)mappableData {
    NSDictionary* next = [*mappableData objectForKey: @"queries.nextPage"];
    
    if(!next) {
        currentOffset = 0;
    }
    else {
        perPage = [[next objectForKey: @"count"] intValue];
        currentOffset = [[next objectForKey: @"startIndex"] intValue];
    }
}

@end

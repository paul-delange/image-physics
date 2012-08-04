//
//  FlikrPaginator.m
//  app
//
//  Created by MacBook Pro on 03/08/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import "FlikrPaginator.h"

#import <RestKit/RestKit.h>

//Key: 7266e0d59a175a02e84b132ff7df7ff8
//Secret: 930e3fd44c858d89

static NSUInteger BingPaginatorDefaultPerPage = 25;
NSString* kFlikrSearchEngine = @"http://api.flickr.com/services";

@interface FlikrPaginator () <RKObjectLoaderDelegate>

+ (id) paginatorWithPattern: (NSString*) pattern;
- (id)initWithPattern:(NSString*) pattern;

@property (nonatomic, readonly) NSUInteger currentOffset;
@property (nonatomic, strong) NSString* pattern;

@end

@implementation FlikrPaginator
@synthesize objectCount;
@synthesize perPage;
@synthesize pattern;
@synthesize currentOffset;
@synthesize onDidFailWithError, onDidLoadObjectsAtOffset;
@synthesize delegate;

+ (id) paginatorWithSearchTerm: (NSString*) searchTerm {
    
    NSString* urlEncoded = [searchTerm stringByAddingURLEncoding];
    NSString* pattern = [NSString stringWithFormat: @"http://api.flickr.com/services/rest?method=flickr.photos.search&&nojsoncallback=1&api_key=7266e0d59a175a02e84b132ff7df7ff8&format=json&text=%@&sort=relevance&media=photos&per_page=:perPage&page=:currentOffset", urlEncoded];
    
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
        BOOL lessThan5Pages = self.currentOffset < 3;
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
    NSString* resPath = [self.pattern interpolateWithObject: self];
    
    RKObjectManager* manager = [RKObjectManager sharedManager];
    
    [manager loadObjectsAtResourcePath: resPath usingBlock: ^(RKObjectLoader *loader) {
        RKObjectMappingProvider* provider =[RKObjectMappingProvider mappingProvider];
        RKManagedObjectStore* store = manager.objectStore;
        
        RKManagedObjectMapping* resultMapping = [RKManagedObjectMapping mappingForClass: NSClassFromString(@"SearchResult")
                                                                   inManagedObjectStore: store];
        
        //Configure result mapping
        resultMapping.primaryKeyAttribute = @"mediaURL";
        
        [resultMapping mapKeyPathsToAttributes:
         @"MediaUrl", @"mediaURL",
         @"title", @"title",
         @"Thumbnail", @"thumbURL",
         nil];
        
        [provider setMapping: resultMapping forKeyPath: @"photos.photo"];
        
        loader.mappingProvider = provider;
        loader.additionalHTTPHeaders = [NSDictionary dictionaryWithObject: @"gzip" forKey: @"Accept-Encoding"];
        loader.username = @"";
        loader.password = @"yzGk1Quap+96/41Zjof9TOaAqzdDTRzBieJy8E+04Ms=";
        loader.delegate = self;
    }];
    
    NSDictionary* queryParams = [resPath queryParameters];
    
    NSDictionary* params =@{ @"start" : [queryParams objectForKey: @"page"], @"term" : [queryParams objectForKey: @"text"] };
    [FlurryAnalytics logEvent: @"Google search" withParameters: params];
    
    currentOffset = offset;
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
    
    NSMutableDictionary* d = [[*mappableData objectForKey: @"photos"] mutableCopy];
    NSArray* results = [d objectForKey: @"photo"];
    NSMutableArray* outResults = [NSMutableArray array];
    
    for(NSDictionary* result in results) {
        NSMutableDictionary* mutable = [result mutableCopy];
        
        NSString* uriFormat = @"http://farm%@.staticflickr.com/%@/%@_%@.jpg";
        NSString* thumbFormat = @"http://farm%@.staticflickr.com/%@/%@_%@_s.jpg";
        
        id farmID = [result objectForKey: @"farm"];
        id serverID = [result objectForKey: @"server"];
        id photoID = [result objectForKey: @"id"];
        id secret = [result objectForKey: @"secret"];
        
        NSString* MediaURL = [NSString stringWithFormat: uriFormat, farmID, serverID, photoID, secret];
        NSString* Thumbnail = [NSString stringWithFormat: thumbFormat, farmID, serverID, photoID, secret];
        
        [mutable setObject: MediaURL forKey: @"MediaURL"];
        [mutable setObject: Thumbnail forKey: @"Thumbnail"];
        
        [outResults addObject: mutable];
    }
    
    [d setObject: outResults forKey: @"photo"];
    [*mappableData setObject: d forKey: @"photos"];
    

    if(!d) {
        currentOffset = 0;
    }
    else {
        perPage = [[d objectForKey: @"perPage"] intValue];
        currentOffset = [[d objectForKey: @"page"] intValue];
        objectCount = [[d objectForKey: @"pages"] intValue];
    }
}

@end

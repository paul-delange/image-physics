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
NSString* kBingSearchEngine = @"api.datamarket.azure.com";

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

    //Comply with new standard
    searchTerm = [NSString stringWithFormat: @"'%@'", searchTerm];
    
    NSString* urlEncoded = [searchTerm stringByAddingURLEncoding];
    NSString* pattern = [NSString stringWithFormat: @"https://api.datamarket.azure.com/Bing/Search/v1/Image?$format=JSON&Query=%@&$top=:perPage&$skip=:currentOffset", urlEncoded];
    
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
         @"Title", @"title",
         @"MediaUrl", @"mediaURL",
         @"Thumbnail.MediaUrl", @"thumbURL",
         @"ContentType", @"contentType",
         @"Width", @"width",
         @"Height", @"height",
         @"SourceUrl", @"SourceUrl",
         @"Index", @"index",
         @"Term", @"term",
         nil];
        
        [provider setMapping: resultMapping forKeyPath: @"d.results"];
        
        loader.mappingProvider = provider;
        loader.additionalHTTPHeaders = [NSDictionary dictionaryWithObject: @"gzip" forKey: @"Accept-Encoding"];
        loader.username = @"";
        loader.password = @"yzGk1Quap+96/41Zjof9TOaAqzdDTRzBieJy8E+04Ms=";
        loader.delegate = self;
    }];
    
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
    
    NSMutableDictionary* d = [[*mappableData objectForKey: @"d"] mutableCopy];
    NSArray* results = [d objectForKey: @"results"];
    NSMutableArray* outResults = [NSMutableArray array];
    
    for(NSDictionary* result in results) {
        NSMutableDictionary* mutable = [result mutableCopy];
        
        NSString* uri = [result valueForKeyPath: @"__metadata.uri"];
        NSDictionary* params = [uri queryParameters];
        NSNumber* index = [params objectForKey: @"$skip"];
        NSString* term = [params objectForKey: @"Query"];
        
        //Get the term back
        term = [term stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @"'"]];
        
        [mutable setObject: index forKey: @"Index"];
        [mutable setObject: term forKey: @"Term"];
        
        [outResults addObject: mutable];
    }
    
    [d setObject: outResults forKey: @"results"];
    [*mappableData setObject: d forKey: @"d"];
    
    NSString* next = [d objectForKey: @"__next"];
    
    if(!next) {
        currentOffset = 0;
    }
    else {
        NSDictionary* params = [next queryParameters];
        perPage = [[params objectForKey: @"$top"] intValue];
        currentOffset = [[params objectForKey: @"$skip"] intValue];
    }
}

@end

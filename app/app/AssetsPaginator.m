//
//  AssetsPaginator.m
//  app
//
//  Created by MacBook Pro on 25/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import "AssetsPaginator.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import "SearchResult.h"
#import <RestKit/RestKit.h>

//http://stackoverflow.com/questions/7570903/iphone-alassetslibrary-get-all-images-and-edit
//http://developer.apple.com/library/ios/#DOCUMENTATION/AssetsLibrary/Reference/ALAssetsLibrary_Class/Reference/Reference.html

static NSUInteger AssetPaginatorDefaultPerPage = 25;
NSString* kLocalAlbumSearchEngine = @"ALAssetsLibrary";

@interface AssetsPaginator () 

@property (nonatomic, strong) ALAssetsLibrary* library;
@property (nonatomic, strong) NSArray* assets;
@property (nonatomic, assign) NSUInteger currentOffset;
@property (nonatomic, strong) NSMutableArray* photoAssets;
@property (nonatomic, assign) BOOL automaticallyLoadNext;

@end


@implementation AssetsPaginator
@synthesize delegate;
@synthesize onDidLoadObjectsAtOffset, onDidFailWithError;
@synthesize library;
@synthesize perPage;
@synthesize currentOffset;
@synthesize objectCount;
@synthesize photoAssets;
@synthesize automaticallyLoadNext;

- (NSUInteger) objectCount {
    return [self.photoAssets count];
}

- (id) init {
    self = [super init];
    
    if( self ) {
        self.library = [ALAssetsLibrary new];
        self.photoAssets = [NSMutableArray array];
        
        [self.library enumerateGroupsWithTypes: ALAssetsGroupAll
                                    usingBlock: ^(ALAssetsGroup *group, BOOL *stop) {
                                        [group setAssetsFilter: [ALAssetsFilter allPhotos]];
                                        
                                        [group enumerateAssetsUsingBlock: ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                            if( result ) {
                                                [self.photoAssets addObject: result];
                                            }
                                            
                                            if( index >= [group numberOfAssets] ) {
                                                if( self.automaticallyLoadNext ) {
                                                    self.automaticallyLoadNext = NO;
                                                    [self performSelectorOnMainThread: @selector(loadNextPage)
                                                                           withObject: nil
                                                                        waitUntilDone: NO];
                                                }
                                            }
                                        }];
                                    } failureBlock: ^(NSError *error) {
                                        //User cancelled access;
                                    }];
        currentOffset = 0;
        perPage = AssetPaginatorDefaultPerPage;
    }
    
    return self;
}

- (void) loadNextPage {
    [self loadPageAtOffset: self.currentOffset];
}

- (void) loadPreviousPage {
    [self loadPageAtOffset: self.currentOffset - self.perPage];
}

- (void) loadPageAtOffset: (NSUInteger) offset {
    if( self.objectCount <= 0 ) {
        NSLog(@"Waiting till later");
        self.automaticallyLoadNext = YES;
        return;
    }
    
    NSLog(@"Continuing with load");
    
    NSUInteger startOffset = self.currentOffset;
    NSUInteger finishOffset = startOffset + self.perPage;
    finishOffset = MIN(finishOffset, [self.photoAssets count]);
    
    NSMutableArray* objs = [NSMutableArray array];
    
    for(NSUInteger idx = startOffset; idx<finishOffset;idx++) {
        ALAsset* asset = [self.photoAssets objectAtIndex: idx];
        ALAssetRepresentation* representation = [asset defaultRepresentation];
        NSString* url = [[representation url] absoluteString];
        CGImageRef fullImg = [representation fullResolutionImage];
        
        SearchResult* entity = [SearchResult findFirstByAttribute: @"mediaURL" withValue: url];
        if( !entity )
            entity = [SearchResult createEntity];
        
        entity.height = [NSNumber numberWithFloat: CGImageGetHeight(fullImg)];
        entity.width = [NSNumber numberWithFloat: CGImageGetWidth(fullImg)];
        entity.mediaURL = url;
        entity.thumbURL = url;
        
        NSString* ext = [[url pathExtension] lowercaseString];
        if( [ext isEqualToString: @"png"] )
            entity.contentType = @"image/png";
        else if( [ext isEqualToString: @"jpg"] || [ext isEqualToString: @"jpeg"] )
            entity.contentType = @"image/jpeg";
        else if( [ext isEqualToString: @"bmp"] )
            entity.contentType = @"image/bmp";
        else if( [ext isEqualToString: @"tiff"] )
            entity.contentType = @"image/tiff";
        else if( [ext isEqualToString: @"gif"] )
            entity.contentType = @"image/gif";
        else
            entity.contentType = @"image/png";
        
        [objs addObject:entity];
    }
    
    [[RKObjectManager sharedManager].objectStore save: nil];
    
    if( self.onDidLoadObjectsAtOffset ) {
        self.onDidLoadObjectsAtOffset(objs, self.currentOffset);
    }
    
    NSDictionary* params =@{ @"start" : [NSNumber numberWithInt: offset] };
    [FlurryAnalytics logEvent: @"Assets search" withParameters: params];
    
    self.currentOffset += (finishOffset-startOffset);
}

- (BOOL) hasNextPage {
    return self.currentOffset < self.objectCount;
}

- (BOOL) hasPreviousPage {
    return self.currentOffset > 0;
}

@end

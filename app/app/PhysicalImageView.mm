//
//  PhysicalImageView.m
//  app
//
//  Created by MacBook Pro on 18/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import "PhysicalImageView.h"

#import "SearchResult.h"
#import "GPUImageBubbleFilter.h"

#import <ImageIO/ImageIO.h>
#import <QuartzCore/QuartzCore.h>
#import <AsyncImageView/AsyncImageView.h>

@interface PhysicalImageView ()

@property (nonatomic, weak) AsyncImageView* imageView;

@end

@implementation PhysicalImageView
@synthesize imageModel = _imageModel;
@synthesize imageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        AsyncImageView* imgView = [[AsyncImageView alloc] initWithFrame: CGRectMake(0, 0, frame.size.width, frame.size.height)];
        imgView.showActivityIndicator = YES;
        
        imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview: imgView];
        imageView = imgView;
        imgView.userInteractionEnabled = YES;
    }
    return self;
}

- (void) dealloc {
    [[AsyncImageLoader sharedLoader] cancelLoadingURL: [NSURL URLWithString: self.imageModel.thumbURL]
                                               target: self
                                               action: @selector(imageLoaded:)];
}

- (void) setImageModel:(SearchResult *)imageModel {
    if( _imageModel ) {
        [[AsyncImageLoader sharedLoader] cancelLoadingURL: [NSURL URLWithString: self.imageModel.thumbURL]
                                                   target: self
                                                   action: @selector(imageLoaded:)];
    }
    
    _imageModel = imageModel;
    
    if( imageModel ) {
        [[AsyncImageLoader sharedLoader] loadImageWithURL: [NSURL URLWithString: imageModel.thumbURL]
                                                   target: self
                                                   action: @selector(imageLoaded:)];
    }
}

- (void) imageLoaded: (UIImage*) img {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        GPUImageBubbleFilter* filter = [GPUImageBubbleFilter new];
        
        UIImage* overlay = [UIImage imageNamed: @"bubble"];
        
        GPUImagePicture* contentPicture = [[GPUImagePicture alloc] initWithImage: img];
        GPUImagePicture* overlayPicture = [[GPUImagePicture alloc] initWithImage: overlay];
        
        [contentPicture addTarget: filter];
        [contentPicture processImage];
        [overlayPicture addTarget: filter];
        [overlayPicture processImage];
        
        self.imageView.image = [filter imageFromCurrentlyProcessedOutput];
 
    });
}

@end

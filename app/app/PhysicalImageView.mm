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
#import <SDWebImage/UIImageView+WebCache.h>

@interface PhysicalImageView ()

@property (nonatomic, weak) UIImageView* imageView;

@end

@implementation PhysicalImageView
@synthesize imageModel = _imageModel;
@synthesize imageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImageView* imgView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, frame.size.width, frame.size.height)];
        
        imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview: imgView];
        imageView = imgView;
        imgView.userInteractionEnabled = YES;
    }
    return self;
}

- (void) dealloc {
    [self.imageView cancelCurrentImageLoad];
}

- (void) setImageModel:(SearchResult *)imageModel {
    if( _imageModel ) {
        [self.imageView cancelCurrentImageLoad];
    }
    
    _imageModel = imageModel;
    
    if( imageModel ) {
        
        [self.imageView setImageWithURL: [NSURL URLWithString: imageModel.thumbURL]
                       placeholderImage: [UIImage imageNamed: @"bubble"]
                                success: ^(UIImage *image) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        
                                        
                                        GPUImageBubbleFilter* filter = [GPUImageBubbleFilter new];
                                        
                                        //UIImage* overlay = [UIImage imageNamed: @"bubble"];
                                        
                                        GPUImagePicture* contentPicture = [[GPUImagePicture alloc] initWithImage: image];
                                        //GPUImagePicture* overlayPicture = [[GPUImagePicture alloc] initWithImage: overlay];
                                        
                                        [contentPicture addTarget: filter];
                                        [contentPicture processImage];
                                        //[overlayPicture addTarget: filter];
                                        //[overlayPicture processImage];
                                        
                                        self.imageView.image = [filter imageFromCurrentlyProcessedOutput];
                                        
                                    });
                                } failure:^(NSError *error) {
                                    
                                }];
    }
}


@end

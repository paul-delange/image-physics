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

#import <AssetsLibrary/AssetsLibrary.h>
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
        
        NSURL* thumb = [NSURL URLWithString: imageModel.thumbURL];
        
        if( [[thumb scheme] isEqualToString: @"assets-library"] ) {
            
            ALAssetsLibrary* library = [ALAssetsLibrary new];
            self.imageView.image = [UIImage imageNamed: @"bubble"];
            
            [library assetForURL: thumb
                          resultBlock: ^(ALAsset *asset) {
                              CGImageRef thumbnail = [asset thumbnail];
                              UIImage* image = [UIImage imageWithCGImage: thumbnail];
                              
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  
                                  GPUImageBubbleFilter* filter = [GPUImageBubbleFilter new];
                                  GPUImagePicture* contentPicture = [[GPUImagePicture alloc] initWithImage: image];
                                  
                                  [contentPicture addTarget: filter];
                                  [contentPicture processImage];
                                  
                                  self.imageView.image = [filter imageFromCurrentlyProcessedOutput];
                                  
                              });
                              
                          } failureBlock: ^(NSError *error) {
                              
                          }];
        }
        else {
        
        [self.imageView setImageWithURL: thumb
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
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan: touches withEvent: event];
    self.layer.shadowRadius = 50.f;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowOpacity = 1.f;
    self.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.layer.shadowPath = [UIBezierPath bezierPathWithArcCenter: CGPointMake(self.bounds.size.width/2.f, self.bounds.size.height/2.f)
                                                           radius: self.bounds.size.width/2.f
                                                       startAngle: 0
                                                         endAngle: 2*M_PI
                                                        clockwise: YES].CGPath;
    
    [self.superview bringSubviewToFront: self];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded: touches withEvent: event];
    
    self.layer.shadowRadius = 0.f;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled: touches withEvent: event];
    
    self.layer.shadowRadius = 0.f;
}

@end

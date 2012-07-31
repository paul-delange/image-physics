//
//  ImageDetailView.m
//  app
//
//  Created by MacBook Pro on 23/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import "ImageDetailView.h"

#import "SearchResult.h"

#import <iCarousel/iCarousel.h>
#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/UIImageView+WebCache.h>

@implementation ImageDetailView
@synthesize carousel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if( self ) {
        self.carousel.type = iCarouselTypeTimeMachine;
    }
    return self;
}

/*
- (void) setImageModel:(SearchResult *)imageModel {
    _imageModel = imageModel;
    
    if( imageModel ) {
        NSURL* url = [NSURL URLWithString: imageModel.mediaURL];
        
        if( !url ) {
            NSLog(@"Error creating url: %@", imageModel.mediaURL);
        }
        
        UIImage* cachedThumb = [[SDImageCache sharedImageCache] imageFromKey: imageModel.thumbURL];
        
        UIActivityIndicatorView* activityIndicator = nil;
        
        if( !cachedThumb ) {
            activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
            [activityIndicator startAnimating];
            activityIndicator.center = CGPointMake(self.bounds.size.width/2.f, self.bounds.size.height/2.f);
            [self addSubview: activityIndicator];
        }
        
        [self.imageView setImageWithURL: [NSURL URLWithString: imageModel.mediaURL]
                       placeholderImage: cachedThumb 
                                success: ^(UIImage *image) {
                                    [activityIndicator removeFromSuperview];
                                } failure: ^(NSError *error) {
                                    [activityIndicator removeFromSuperview];
                                }];
    }
}*/

- (void) showFromPoint: (CGPoint) point {
    CGRect finalBounds = self.bounds;
    self.frame = CGRectMake(0, 0, 50, 50);
    self.center = point;
    self.alpha = 0.0f;
    
    [UIView animateWithDuration: 1.0
                          delay: 0.0
                        options: UIViewAnimationCurveEaseOut
                     animations: ^{
                         self.frame = finalBounds;
                         self.alpha = 1.0f;
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void) dismissToPoint: (CGPoint) point {
    
    [UIView animateWithDuration: 1.0
                          delay: 0.0
                        options: UIViewAnimationCurveEaseIn
                     animations: ^{
                         self.frame = CGRectMake(0, 0, 50, 50);
                         self.center = point;
                         self.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

@end

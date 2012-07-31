//
//  ImageDetailView.h
//  app
//
//  Created by MacBook Pro on 23/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchResult;
@class iCarousel;

@interface ImageDetailView : UIView

@property (weak, nonatomic) IBOutlet iCarousel *carousel;

- (void) showFromPoint: (CGPoint) point;
- (void) dismissToPoint: (CGPoint) point;

@end

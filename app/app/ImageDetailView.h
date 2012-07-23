//
//  ImageDetailView.h
//  app
//
//  Created by MacBook Pro on 23/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchResult;

@interface ImageDetailView : UIView

@property (nonatomic, strong) SearchResult* imageModel;

- (void) showFromPoint: (CGPoint) point;
- (void) dismissToPoint: (CGPoint) point;

@end

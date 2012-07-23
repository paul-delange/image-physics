//
//  ImageDetailView.m
//  app
//
//  Created by MacBook Pro on 23/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import "ImageDetailView.h"

#import "SearchResult.h"

@implementation ImageDetailView
@synthesize imageModel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) showFromPoint: (CGPoint) point {
    
}

- (void) dismissToPoint: (CGPoint) point {

}

@end

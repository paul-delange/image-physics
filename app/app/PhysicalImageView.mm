//
//  PhysicalImageView.m
//  app
//
//  Created by MacBook Pro on 18/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import "PhysicalImageView.h"

#import "SearchResult.h"

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
    }
    return self;
}

- (void) setImageModel:(SearchResult *)imageModel {
    _imageModel = imageModel;
    
    if( imageModel ) {
        self.imageView.imageURL = [NSURL URLWithString: imageModel.thumbURL];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

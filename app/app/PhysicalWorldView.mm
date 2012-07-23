//
//  PhysicalWorldView.m
//  app
//
//  Created by MacBook Pro on 23/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import "PhysicalWorldView.h"

#import <Box2d/Box2d.h>
#import <QuartzCore/QuartzCore.h>

@interface PhysicalWorldView () {
}

@end

@implementation PhysicalWorldView
@synthesize paused;

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
        
    }
    return self;
}

- (void) update: (id) sender {
    
    if( [sender isKindOfClass: [CADisplayLink class]] ) {
        CADisplayLink* link = (CADisplayLink*) sender;
        
        static CFTimeInterval lastUpdateTime = 0;
        CGFloat dt = link.timestamp - lastUpdateTime;
        
        //update
        
        lastUpdateTime = link.timestamp;
        
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

//
//  PhysicalView.m
//  app
//
//  Created by MacBook Pro on 18/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import "PhysicalView.h"
#import <QuartzCore/QuartzCore.h>

@interface PhysicalView ()

@end

@implementation PhysicalView
@synthesize body;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self.layer addObserver: self
                     forKeyPath: @"position"
                        options: NSKeyValueObservingOptionNew
                        context: nil];
    }
    return self;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSValue* value = [change objectForKey: NSKeyValueChangeNewKey];
    CGPoint point = [value CGPointValue];
    
    b2Vec2 position = b2Vec2(point.x, self.superview.frame.size.height-point.y);
    if( self.body )
        self.body->SetTransform(position, 0);
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* aTouch = [touches anyObject];
    CGPoint location = [aTouch locationInView: self.superview];
    [UIView beginAnimations: nil context: nil];
    self.center = location;
    [UIView commitAnimations];
}

@end

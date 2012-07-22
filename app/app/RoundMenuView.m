//
//  RoundMenuView.m
//  app
//
//  Created by Paul de Lange on 22/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import "RoundMenuView.h"

#import <QuartzCore/QuartzCore.h>

@interface RoundMenuView ()

@end

@implementation RoundMenuView
@synthesize circleCenter;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
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

- (void) addSubview:(UIView *)view {
    view.center = CGPointMake(self.frame.size.width/2.f, self.frame.size.height/2.f);
    [super addSubview: view];
}

- (void) show {
    NSInteger n = [self.subviews count];
    CGFloat angle = M_PI*2 / n;
    CGFloat radius = 80.f;
    
    
    for(UIView* view in self.subviews)
        view.center = self.circleCenter;
    
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration: 0.3];
    
    for(NSUInteger i=0;i<n;i++) {
        UIView* view = [self.subviews objectAtIndex: i];
        CGFloat x = radius * sin( i * angle ) + self.circleCenter.x;
        CGFloat y = radius * cos( i * angle ) + self.circleCenter.y;
        
        view.center = CGPointMake(x, y);
    }
    
    
    self.layer.backgroundColor = [UIColor colorWithWhite: 0.0 alpha: 0.8].CGColor;
    
    [UIView commitAnimations];
}

- (void) hide {
    
    [UIView animateWithDuration: 0.3
                          delay: 0.0
                        options: 0
                     animations:^{
                         for(UIView* view in self.subviews)
                             view.center = self.circleCenter;
                         
                         self.layer.backgroundColor = [UIColor clearColor].CGColor;
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
    
}

@end

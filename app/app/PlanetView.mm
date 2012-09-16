//
//  PlanetView.m
//  app
//
//  Created by MacBook Pro on 18/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import "PlanetView.h"

@implementation PlanetView

- (void) startAnimating {
    [UIView animateWithDuration: 0.3
                     animations: ^{
                         self.alpha = 1.0f;
                     }];
    
    [UIView animateWithDuration: 3.0
                          delay: 0.0
                        options:UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGAffineTransform transform = CGAffineTransformMakeRotation(-M_PI);
                         self.transform = transform;
                     } completion: NULL];
}

- (void) stopAnimating {
    [UIView animateWithDuration: 0.3
                     animations: ^{
                         //self.alpha = 0.0f;
                     }];
    
    [UIView animateWithDuration:0.01 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear animations:^{
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI * 0.05);
        self.transform = transform;
    } completion:NULL];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self startAnimating];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if( self ) {
        [self startAnimating];
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

@end

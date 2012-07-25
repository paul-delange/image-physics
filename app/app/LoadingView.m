//
//  LoadingView.m
//  app
//
//  Created by MacBook Pro on 25/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView

- (void) startAnimating {
    [UIView animateWithDuration: 0.3
                     animations: ^{
                         self.alpha = 1.0f;
                     }];
    
    [UIView animateWithDuration: 1.0
                          delay: 0.0 
                        options:UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveLinear 
                     animations:^{
                         CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
                         self.transform = transform;
                     } completion: NULL];
}

- (void) stopAnimating {
    [UIView animateWithDuration: 0.3
                     animations: ^{
                         self.alpha = 0.0f;
                     }];
    
    [UIView animateWithDuration:0.01 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear animations:^{
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI * 0.05);
        self.transform = transform;
    } completion:NULL];
}

@end

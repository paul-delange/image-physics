//
//  PhysicalWorldView.h
//  app
//
//  Created by MacBook Pro on 23/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PhysicalWorldSubviewsChanged)(NSArray* subviews);

@interface PhysicalWorldView : UIView

@property (nonatomic, assign) BOOL paused;
@property (nonatomic, copy) PhysicalWorldSubviewsChanged onSubviewsChanged;

- (void) update: (id) sender;

@end

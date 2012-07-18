//
//  PhysicalView.h
//  app
//
//  Created by MacBook Pro on 18/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Box2D/Box2D.h>

@interface PhysicalView : UIView

@property (nonatomic, assign) b2Body* body;

@end

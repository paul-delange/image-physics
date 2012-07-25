//
//  PhysicalView.m
//  app
//
//  Created by MacBook Pro on 18/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import "PhysicalView.h"
#import <QuartzCore/QuartzCore.h>

@interface PhysicalView () {
    b2Vec2 m_mouseWorld;
    b2MouseJoint* m_mouseJoint;
}

@end

@implementation PhysicalView
@synthesize body;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        m_mouseJoint = NULL;
    }
    return self;
}

- (void) dealloc {
    b2World* world = self->body->GetWorld();
    world->DestroyBody(self->body);
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan: touches withEvent: event];
    
    UITouch* aTouch = [touches anyObject];
    CGPoint location = [aTouch locationInView: self.superview];
    
    m_mouseWorld.Set(location.x, self.superview.bounds.size.height - location.y);
    if( m_mouseJoint != NULL )
        return;
    
    b2World* world = self->body->GetWorld();
    
    b2Body* bodyz = self->body;
    if( bodyz ) {
        b2BodyDef bodyDef;
        b2Body* groundBody = world->CreateBody(&bodyDef);
        
        bodyz->SetAwake(true);
        
        b2MouseJointDef md;
        md.bodyA = groundBody;
        md.bodyB = bodyz;
        md.target = m_mouseWorld;
        md.maxForce = MAXFLOAT;
        
        m_mouseJoint = (b2MouseJoint*)world->CreateJoint(&md);
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved: touches withEvent: event];
    
    UITouch* aTouch = [touches anyObject];
    CGPoint location = [aTouch locationInView: self.superview];
    
    m_mouseWorld.Set(location.x, self.superview.bounds.size.height - location.y);
    
    if(m_mouseJoint) {
        m_mouseJoint->SetTarget(m_mouseWorld);
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded: touches withEvent: event];
    if( m_mouseJoint ) {
        b2World* world = self->body->GetWorld();
        world->DestroyJoint(m_mouseJoint);
        m_mouseJoint = NULL;
    }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled: touches withEvent: event];
    if( m_mouseJoint ) {
        b2World* world = self->body->GetWorld();
        world->DestroyJoint(m_mouseJoint);
        m_mouseJoint = NULL;
    }
}

@end

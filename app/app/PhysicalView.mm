//
//  PhysicalView.m
//  app
//
//  Created by MacBook Pro on 18/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import "PhysicalView.h"
#import <QuartzCore/QuartzCore.h>


class QueryCallback : public b2QueryCallback {
public:
    b2Vec2 m_point;
    b2Body* m_object;
    
    QueryCallback(const b2Vec2& point) {
        m_point = point;
        m_object = NULL;
    }
    
    bool ReportFixture(b2Fixture* fixture)
    {
        if (fixture->IsSensor()) return true; //ignore sensors
        
        bool inside = fixture->TestPoint(m_point);
        if (inside)
        {
            // We are done, terminate the query.
            m_object = fixture->GetBody();
            return false;
        }
        
        // Continue the query.
        return true;
    }
};

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
        /*// Initialization code
        [self.layer addObserver: self
                     forKeyPath: @"position"
                        options: NSKeyValueObservingOptionNew
                        context: nil];
         */
    }
    return self;
}

- (void) dealloc {
    b2World* world = self->body->GetWorld();
    world->DestroyBody(self->body);
}
/*
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSValue* value = [change objectForKey: NSKeyValueChangeNewKey];
    CGPoint point = [value CGPointValue];
    
    b2Vec2 position = b2Vec2(point.x, self.superview.frame.size.height-point.y);
    if( self.body )
        self.body->SetTransform(position, 0);
}
*/

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* aTouch = [touches anyObject];
    CGPoint location = [aTouch locationInView: self.superview];
    
    m_mouseWorld.Set(location.x, self.superview.bounds.size.height - location.y);
    if( m_mouseJoint != NULL )
        return;
    
    //b2AABB aabb;
    //b2Vec2 d = b2Vec2(10, 10);
    //aabb.lowerBound = m_mouseWorld - d;
    //aabb.upperBound = m_mouseWorld + d;
    
    //QueryCallback callback(m_mouseWorld);
    b2World* world = self->body->GetWorld();
    //world->QueryAABB(&callback, aabb);
    
    b2Body* bodyz = self->body;
    if( bodyz ) {
        b2BodyDef bodyDef;
        b2Body* groundBody = world->CreateBody(&bodyDef);
        
        bodyz->SetAwake(true);
        
        b2MouseJointDef md;
        md.bodyA = groundBody;
        md.bodyB = bodyz;
        md.target = m_mouseWorld;
        md.maxForce = 100000000 * bodyz->GetMass();
        
        m_mouseJoint = (b2MouseJoint*)world->CreateJoint(&md);
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* aTouch = [touches anyObject];
    CGPoint location = [aTouch locationInView: self.superview];
    
    m_mouseWorld.Set(location.x, self.superview.bounds.size.height - location.y);
    
    if(m_mouseJoint) {
        m_mouseJoint->SetTarget(m_mouseWorld);
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesCancelled: touches withEvent: event];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if( m_mouseJoint ) {
        b2World* world = self->body->GetWorld();
        world->DestroyJoint(m_mouseJoint);
        m_mouseJoint = NULL;
    }
}

@end

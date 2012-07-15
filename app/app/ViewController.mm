//
//  ViewController.m
//  app
//
//  Created by Paul de Lange on 15/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import "ViewController.h"

#import <Box2D/Box2D.h>

#define kRADIAL_GRAVITY_FORCE 250000000.f

@interface ViewController () {
    b2World* world;
    b2Fixture* magnetFixture;
    NSTimer* tickTimer;
}

- (void) setupPhysics;
- (void) addPhysicalBodyForView: (UIView*) physicalView;
- (void) addPhysicalBodyForView:(UIView *)physicalView moveable: (BOOL) canMove;

@end

@implementation ViewController
@synthesize planetView;

- (void) dealloc {
    [tickTimer invalidate];
    delete world;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self setupPhysics];
    
    for(UIView* view in self.view.subviews) {
        [self addPhysicalBodyForView: view];
    }
    
    tickTimer = [NSTimer scheduledTimerWithTimeInterval: 1./60.f
                                                 target: self
                                               selector: @selector(tick:)
                                               userInfo: nil
                                                repeats: YES];
}

- (void)viewDidUnload
{
    [self setPlanetView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [tickTimer invalidate];
    delete world;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Physics
- (void) tick: (NSTimer*) timer {
    //It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
    
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
    
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(1.0f/60.0f, velocityIterations, positionIterations);
    
    b2CircleShape* circle = (b2CircleShape*)magnetFixture->GetShape();
    b2Body* body = magnetFixture->GetBody();
    
    b2Vec2 center = body->GetWorldPoint(circle->m_p);
      
	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
        if( b->GetType() == b2_dynamicBody ) {
            b2Vec2 position = b->GetPosition();
            b2Vec2 d = center - position;
            
            float force = kRADIAL_GRAVITY_FORCE / d.Length(); 
            
            d.Normalize();
            b2Vec2 F = force * d;
            
            b->ApplyForce(F, position);
            
            if (b->GetUserData() != NULL) {
                UIView *oneView = (__bridge UIView *)b->GetUserData();
                
                NSLog(@"Was at: %@", NSStringFromCGPoint(oneView.center));
                
                // y Position subtracted because of flipped coordinate system
                CGPoint newCenter = CGPointMake( b->GetPosition().x, self.view.bounds.size.height - b->GetPosition().y );
                
                NSLog(@"Move to: %@", NSStringFromCGPoint(newCenter));
                
                oneView.center = newCenter;
            }
        }
	}
}

#pragma mark - Private
- (void) setupPhysics {
    //CGSize screenSize = self.view.bounds.size;
    b2Vec2 gravity;
    bool doSleep = true;
    
    world = new b2World(gravity, doSleep);
    world->SetContinuousPhysics(true);
    
    // Define the ground body.
    b2BodyDef groundBodyDef;
    groundBodyDef.type = b2_staticBody;
    groundBodyDef.position.Set(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f);
    
    b2Body* magnetBody = world->CreateBody(&groundBodyDef);
    
    b2CircleShape circle;
    circle.m_radius = 1.f;
    
    b2FixtureDef fd;
    fd.shape = &circle;
    
    magnetFixture = magnetBody->CreateFixture(&fd);
    
    b2Vec2 center = magnetBody->GetWorldPoint(circle.m_p);
    
    self.planetView.center = CGPointMake(center.x , center.y );
    
    NSLog(@"Planet: %@", NSStringFromCGPoint(self.planetView.center));
}

- (void) addPhysicalBodyForView:(UIView *)physicalView {
    [self addPhysicalBodyForView: physicalView moveable: YES];
}

- (void) addPhysicalBodyForView:(UIView *)physicalView moveable: (BOOL) canMove {
    if( physicalView == self.planetView ) 
        return;
    
    CGPoint p = physicalView.center;
    CGPoint boxDimenstions = CGPointMake(physicalView.bounds.size.width, 
                                         physicalView.bounds.size.height);
    
    if( canMove ) {
        b2BodyDef bodyDef;
        bodyDef.type = b2_dynamicBody;
        
        bodyDef.position.Set(p.x, self.view.bounds.size.height-p.y);
        bodyDef.userData = (__bridge void*)physicalView;
        bodyDef.fixedRotation = true;
        
        b2Body* body = world->CreateBody(&bodyDef);
        
        b2PolygonShape dynamicBox;
        dynamicBox.SetAsBox(boxDimenstions.x, boxDimenstions.y);
        
        b2FixtureDef fixtureDef;
        fixtureDef.shape = &dynamicBox;
        fixtureDef.density = 1.0f;
        fixtureDef.friction = 0.3f;
        //fixtureDef.restitution = 0.5f;
        body->CreateFixture(&fixtureDef);
        
        physicalView.tag = (int)body;
    }
}

@end

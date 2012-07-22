//
//  ViewController.m
//  app
//
//  Created by Paul de Lange on 15/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import "ViewController.h"

#import "SearchResult.h"
#import "BingPaginator.h"

#import "RoundMenuView.h"
#import "PhysicalImageView.h"
#import "PlanetView.h"

#import <Box2D/Box2D.h>
#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>

#define kRADIAL_GRAVITY_FORCE 250000000.f
#define kRoundMenuPlanetViewTag 4321

@interface ViewController () <NSFetchedResultsControllerDelegate, UITextFieldDelegate> {
    b2World* world;
    b2Fixture* magnetFixture;
    NSTimer* tickTimer;
    
    BOOL physicsPaused;
}

@property (nonatomic, readonly) NSFetchedResultsController* resultsController;
@property (nonatomic, readonly) NSArray* displayedImagePaths;

- (void) setupPhysics;
- (void) addPhysicalBodyForView: (UIView*) physicalView;
- (void) addPhysicalBodyForView:(UIView *)physicalView moveable: (BOOL) canMove;

@end

@implementation ViewController
@synthesize infoButton;
@synthesize searchbutton;
@synthesize searchField;
@synthesize fadeWorldView;
@synthesize worldCanvas;
@synthesize planetView;
@synthesize resultsController;

- (NSArray*) displayedImagePaths {
    NSPredicate* mustBeImageViewPredicate = [NSPredicate predicateWithFormat: @"self isKindOfClass: %@", [PhysicalImageView class]];
    NSArray* allPhysicalImageViews = [self.worldCanvas.subviews filteredArrayUsingPredicate: mustBeImageViewPredicate];
    return [allPhysicalImageViews valueForKeyPath: @"@unionOfObjects.imageModel.mediaURL"];
}

- (void) dealloc {
    [tickTimer invalidate];
    delete world;
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    CGRect searchFieldFrame = self.searchField.frame;
    searchFieldFrame.origin.y = self.searchbutton.frame.origin.y;
    searchFieldFrame.size.height = self.searchbutton.frame.size.height;
    self.searchField.frame = searchFieldFrame;
    
    [self setupPhysics];
    
    tickTimer = [NSTimer scheduledTimerWithTimeInterval: 1./60.f
                                                 target: self
                                               selector: @selector(tick:)
                                               userInfo: nil
                                                repeats: YES];
    
    UIGestureRecognizer* rc = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                      action: @selector(tapped:)];
    [self.worldCanvas addGestureRecognizer: rc];
    
    
    
    UIGestureRecognizer* planetTap = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                             action: @selector(planetTapped:)];
    
    UIGestureRecognizer* planetHeld = [[UILongPressGestureRecognizer alloc] initWithTarget: self
                                                                                    action: @selector(planetHeld:)];
    
    [self.planetView addGestureRecognizer: planetTap];
    [self.planetView addGestureRecognizer: planetHeld];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillAppear:)
                                                 name: UIKeyboardWillShowNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillDisappear:)
                                                 name: UIKeyboardWillHideNotification
                                               object: nil];
}

- (void) tapped: (UIGestureRecognizer*) recognizer {
    CGPoint p = [recognizer locationInView: self.worldCanvas];
    
    UIView* v = [[PhysicalView alloc] initWithFrame: CGRectMake(0, 0, 50, 50)];
    v.center = p;
    v.backgroundColor = [UIColor colorWithRed: (arc4random() % 100)/100.f green: 0.5 blue: 0.5 alpha: 1.0];
    
    [self addPhysicalBodyForView: v];
}

- (void)viewDidUnload
{
    [self setPlanetView:nil];
    [self setInfoButton:nil];
    [self setSearchbutton:nil];
    [self setSearchField:nil];
    [self setFadeWorldView:nil];
    [self setWorldCanvas:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [tickTimer invalidate];
    delete world;
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillShowNotification
                                                  object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillHideNotification
                                                  object: nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    b2Vec2 p = b2Vec2(self.planetView.center.x, self.worldCanvas.bounds.size.height - self.planetView.center.y);
    self.planetView.body->SetTransform(p, 0);
}

#pragma mark - Physics
- (void) tick: (NSTimer*) timer {
    
    if( physicsPaused )
        return;
    
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
      
    //UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    //BOOL isLandscape = UIInterfaceOrientationIsLandscape(orientation);
    
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
                
                // y Position subtracted because of flipped coordinate system
                CGPoint newCenter = oneView.center;
                
                //NSLog(@"Was: %@", NSStringFromCGPoint(newCenter));
                
                newCenter = CGPointMake( b->GetPosition().x, self.worldCanvas.bounds.size.height - b->GetPosition().y );
                
               // NSLog(@"Now: %@", NSStringFromCGPoint(newCenter));
                
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
    groundBodyDef.position.Set(self.planetView.center.x, self.worldCanvas.bounds.size.height - self.planetView.center.y);
    
    b2Body* magnetBody = world->CreateBody(&groundBodyDef);
    self.planetView.body = magnetBody;
    
    b2CircleShape circle;
    circle.m_radius = self.planetView.bounds.size.width/2.f;
    
    b2FixtureDef fd;
    fd.shape = &circle;
    
    magnetFixture = magnetBody->CreateFixture(&fd);
    
    //b2Vec2 center = magnetBody->GetWorldPoint(circle.m_p);
    
}

- (void) addPhysicalBodyForView:(UIView *)physicalView {
    [self addPhysicalBodyForView: physicalView moveable: YES];
}

- (void) addPhysicalBodyForView:(UIView *)physicalView moveable: (BOOL) canMove {
    if( physicalView == self.planetView ) 
        return;
    
    CGPoint p = physicalView.center;
    CGPoint boxDimenstions = CGPointMake(physicalView.bounds.size.width/2.f, 
                                         physicalView.bounds.size.height/2.f);
    
    if( canMove ) {
        b2BodyDef bodyDef;
        bodyDef.type = b2_dynamicBody;
        
        bodyDef.position.Set(p.x, self.worldCanvas.bounds.size.height-p.y);
        bodyDef.userData = (__bridge void*)physicalView;
        bodyDef.fixedRotation = true;
        
        b2Body* body = world->CreateBody(&bodyDef);
        
        b2PolygonShape dynamicBox;
        dynamicBox.SetAsBox(boxDimenstions.x, boxDimenstions.y);
        
        b2FixtureDef fixtureDef;
        fixtureDef.shape = &dynamicBox;
        fixtureDef.density = 1.0f;
        fixtureDef.friction = 0.3f;
        body->CreateFixture(&fixtureDef);
        
        ((PhysicalView*)physicalView).body = body;
    }
    
    [self.worldCanvas addSubview: physicalView];
}

- (NSFetchedResultsController*) resultsController {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        resultsController = [SearchResult fetchAllSortedBy: @"url"
                                                 ascending: YES
                                             withPredicate: nil
                                                   groupBy: nil];
    });
    
    return resultsController;
}

#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate
- (void)controller:(NSFetchedResultsController *)controller 
   didChangeObject:(id)anObject 
       atIndexPath:(NSIndexPath *)indexPath 
     forChangeType:(NSFetchedResultsChangeType)type 
      newIndexPath:(NSIndexPath *)newIndexPath {
    
}

- (void)controller:(NSFetchedResultsController *)controller 
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo 
           atIndex:(NSUInteger)sectionIndex 
     forChangeType:(NSFetchedResultsChangeType)type {
    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSArray* fetched = [controller fetchedObjects];
    NSPredicate* alreadyDisplayed = [NSPredicate predicateWithFormat: @"NOT (self.mediaURL IN %@)", self.displayedImagePaths];
    NSArray* newObjects = [fetched filteredArrayUsingPredicate: alreadyDisplayed];
    
    for(SearchResult* result in newObjects) {
        UIView* v = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 50, 50)];
        v.center = CGPointMake(arc4random() % (int)self.worldCanvas.bounds.size.width, arc4random() % (int)self.worldCanvas.bounds.size.height);
        v.backgroundColor = [UIColor colorWithRed: (arc4random() % 100)/100.f green: 0.5 blue: 0.5 alpha: 1.0];
        [self addPhysicalBodyForView: v];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    NSString* searchTerm = textField.text;
    
    BingPaginator* paginator = [BingPaginator paginatorWithSearchTerm: searchTerm];
    paginator.onDidLoadObjectsAtOffset = ^(NSArray* objs, NSUInteger offset) {
        
    };
    paginator.onDidFailWithError = ^(NSError* error, RKObjectLoader* loader) {
        
    };
    [paginator loadNextPage];
    
    return YES;
}

#pragma mark - Actions

- (IBAction) planetTapped:(UITapGestureRecognizer*)sender {
    [self searchPushed: sender];
}

- (IBAction) planetHeld:(UILongPressGestureRecognizer*)sender {
    
    //Called twice for some reason :(
    if( [self.view viewWithTag: kRoundMenuPlanetViewTag] )
        return;
    
    CGRect frame = CGRectMake(0, 0,self.view.bounds.size.width, self.view.bounds.size.height);
    RoundMenuView* menu = [[RoundMenuView alloc] initWithFrame: frame];
    menu.tag = kRoundMenuPlanetViewTag;
    menu.circleCenter = self.planetView.center;
    
    UIButton* playButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [playButton addTarget: self action: @selector(playPushed:) forControlEvents: UIControlEventTouchUpInside];
     
    if( physicsPaused ) {
        [playButton setImage: [UIImage imageNamed: @"play"] forState: UIControlStateNormal];
    }
    else {
        [playButton setImage: [UIImage imageNamed: @"pause"] forState: UIControlStateNormal];
    }
    
    playButton.frame = self.searchbutton.frame;
    
    UIButton* closeButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [closeButton addTarget: self action: @selector(closeMenuPushed:) forControlEvents: UIControlEventTouchUpInside];
    [closeButton setImage: [UIImage imageNamed: @"shut"] forState: UIControlStateNormal];
    closeButton.frame = playButton.frame;
    
    UIButton* refreshButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [refreshButton addTarget: self action: @selector(refreshPushed:) forControlEvents: UIControlEventTouchUpInside];
    [refreshButton setImage: [UIImage imageNamed: @"refresh"] forState: UIControlStateNormal];
    refreshButton.frame = playButton.frame;
    
    [refreshButton addTarget: self action: @selector(closeMenuPushed:) forControlEvents:UIControlEventTouchUpInside];
    [playButton addTarget: self action: @selector(closeMenuPushed:) forControlEvents: UIControlEventTouchUpInside];
    
    [menu addSubview: closeButton];
    [menu addSubview: playButton];
    [menu addSubview: refreshButton];
    
    [self.view addSubview: menu];
    
    [menu show];
}

- (IBAction) closeMenuPushed:(id)sender {
    RoundMenuView* menu = (RoundMenuView*)[self.view viewWithTag: kRoundMenuPlanetViewTag];
    [menu hide];
}

- (IBAction) playPushed:(id)sender {
    physicsPaused = !physicsPaused;
}

- (IBAction) refreshPushed:(id)sender {
    
}

- (IBAction)searchPushed:(id)sender {
    if( [self.searchField isFirstResponder] ) {
        //Keyboard is active
        
        //Run a search
        
        //Hide keyboard
        [self.searchField resignFirstResponder];
    }
    else {
        //Start search mode
        
        //Show keyboard
        [self.searchField becomeFirstResponder];  
    }
}

- (IBAction)infoPushed:(UIButton *)sender {
}

#pragma mark - Keyboard Management
- (void) keyboardWillAppear: (NSNotification*) notif {
    NSTimeInterval interval = [[notif.userInfo objectForKey: UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = (UIViewAnimationCurve)[[notif.userInfo objectForKey: UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    [UIView animateWithDuration: interval
                          delay: 0.0
                        options: curve
                     animations: ^{
                         self.fadeWorldView.alpha = 0.8;
                         
                         CGFloat xOffset = self.searchField.frame.origin.x;
                         
                         CGRect searchBarFrame = self.searchField.frame;
                         searchBarFrame.size.width = self.view.bounds.size.width - xOffset;
                         
                         self.searchField.frame = searchBarFrame;
                         self.searchField.alpha = 1.f;
                     } completion: ^(BOOL finished) {
                         
                     }];
}

- (void) keyboardWillDisappear: (NSNotification*) notif {
    NSTimeInterval interval = [[notif.userInfo objectForKey: UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = (UIViewAnimationCurve)[[notif.userInfo objectForKey: UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    [UIView animateWithDuration: interval
                          delay: 0.0
                        options: curve
                     animations: ^{
                         self.fadeWorldView.alpha = 0.f;
                         
                         CGRect searchBarFrame = self.searchField.frame;
                         searchBarFrame.size.width = 50;
                         
                         self.searchField.frame = searchBarFrame;
                         self.searchField.alpha = 0.f;
                     } completion: ^(BOOL finished) {
                         
                     }];
}

@end

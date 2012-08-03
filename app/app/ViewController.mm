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
#import "AssetsPaginator.h"
#import "FlikrPaginator.h"

#import "InAppPurchaseProvider.h"

#import "PhysicalImageView.h"
#import "PhysicalWorldView.h"
#import "PlanetView.h"

#import "LoadingView.h"
#import "RoundMenuView.h"
#import "ImageDetailView.h"

#import <Box2D/Box2D.h>
#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <RestKit/RestKit.h>

#define kRADIAL_GRAVITY_FORCE 250000000.f
#define kRoundMenuPlanetViewTag 4321

#define kAlertViewPaginatedDownload 1298

@interface ViewController () <NSFetchedResultsControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate> {
    b2World* world;
    b2Fixture* magnetFixture;
    NSTimer* tickTimer;
    
    BOOL physicsPaused;
    CADisplayLink* displayLink;
    CFTimeInterval lastDrawTime;
    
    UIButton* currentEngineButton;
}

@property (nonatomic, readonly) NSFetchedResultsController* resultsController;
@property (nonatomic, readonly) NSArray* displayedImagePaths;
@property (nonatomic, strong) NSObject<Paginator>* paginator;

- (void) setupPhysics;
- (void) addPhysicalBodyForView: (UIView*) physicalView;
- (void) addPhysicalBodyForView:(UIView *)physicalView moveable: (BOOL) canMove;

@end

@implementation ViewController
@synthesize resultsController;
@synthesize paginator = _paginator;

- (void) setPaginator:(NSObject<Paginator> *)paginator {
    _paginator = paginator;
    
    if( !paginator ) {
        [UIView animateWithDuration: 0.3
                         animations: ^{
                             self.moreButton.alpha = 0.f;
                         }];
    }
}

- (NSArray*) displayedImagePaths {
    NSPredicate* mustBeImageViewPredicate = [NSPredicate predicateWithFormat: @"self isKindOfClass: %@", [PhysicalImageView class]];
    NSArray* allPhysicalImageViews = [self.worldCanvas.subviews filteredArrayUsingPredicate: mustBeImageViewPredicate];
    return [allPhysicalImageViews valueForKeyPath: @"@unionOfObjects.imageModel.mediaURL"];
}

- (void) dealloc {
    [tickTimer invalidate];
    delete world;
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [displayLink invalidate];
    displayLink = nil;
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
    
    self.worldCanvas.onSubviewsChanged = ^(NSArray* subviews) {
        NSPredicate* mustBeImageViewPredicate = [NSPredicate predicateWithFormat: @"self isKindOfClass: %@", [PhysicalImageView class]];
        NSArray* allPhysicalImageViews = [subviews filteredArrayUsingPredicate: mustBeImageViewPredicate];
        if( [allPhysicalImageViews count]) {
            [UIView animateWithDuration: 0.3 delay: 0 options: UIViewAnimationOptionCurveEaseOut animations: ^{
                self.refreshButton.alpha = 1.f;
                self.screenshotButton.alpha = 1.f;
                self.pauseButton.alpha = 1.f;
            } completion:^(BOOL finished) {
                
            }];
        }
        else {
            [UIView animateWithDuration: 0.3 delay: 0 options: UIViewAnimationOptionCurveEaseOut animations: ^{
                self.refreshButton.alpha = 0.f;
                self.screenshotButton.alpha = 0.f;
                self.pauseButton.alpha = 0.f;
            } completion:^(BOOL finished) {
                
            }];
        }
    };
    
    /*
     displayLink = [CADisplayLink displayLinkWithTarget: self.worldCanvas
     selector: @selector(update:)];
     [displayLink setFrameInterval: 2];
     [displayLink addToRunLoop: [NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
     */
    
    tickTimer = [NSTimer scheduledTimerWithTimeInterval: 1./60.f
                                                 target: self
                                               selector: @selector(tick:)
                                               userInfo: nil
                                                repeats: YES];
    
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
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(itemPurchased:)
                                                 name: kProductPurchasedNotification
                                               object: nil];
    
    self.loadingView.alpha = 0.f;
    self.moreButton.alpha = 0.f;
    
    NSString* searchEngine = [[NSUserDefaults standardUserDefaults] stringForKey: kUserDefaultSearchEngineKey];
    
    if( [searchEngine isEqualToString: kBingSearchEngine] ) {
        currentEngineButton = self.bingButton;
    }
    else if( [searchEngine isEqualToString: kGoogleSearchEngine] ) {
        currentEngineButton = self.googleButton;
    }
    else if( [searchEngine isEqualToString: kFlikrSearchEngine] ) {
        currentEngineButton = self.flikrButton;
    }
    else {
        currentEngineButton = self.albumButton;
    }
    
    CGPoint currentPoint = currentEngineButton.center;
    
    currentEngineButton.center = self.albumButton.center;
    self.albumButton.center = currentPoint;
    
    
    [[self resultsController] performFetch: nil];
}

- (void)viewDidUnload
{
    [self setPlanetView:nil];
    [self setInfoButton:nil];
    [self setSearchbutton:nil];
    [self setSearchField:nil];
    [self setFadeWorldView:nil];
    [self setWorldCanvas:nil];
    [self setLoadingView:nil];
    [self setMoreButton:nil];
    [self setAlbumButton:nil];
    [self setGoogleButton:nil];
    [self setBingButton:nil];
    [self setFlikrButton:nil];
    [self setScreenshotButton:nil];
    [self setPauseButton:nil];
    [self setRefreshButton:nil];
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
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kProductPurchasedNotification
                                                  object: nil];
    
    [displayLink invalidate];
    displayLink = nil;
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
}

- (void) addPhysicalBodyForView:(UIView *)physicalView {
    [self addPhysicalBodyForView: physicalView moveable: YES];
}

- (void) addPhysicalBodyForView:(UIView *)physicalView moveable: (BOOL) canMove {
    if( physicalView == self.planetView )
        return;
    
    
    CGFloat x = arc4random() % (int)self.worldCanvas.bounds.size.width;
    CGFloat y = arc4random() % (int)self.worldCanvas.bounds.size.height;
    
    CGFloat halfWidth = self.worldCanvas.bounds.size.width/2.f;
    CGFloat halfHeight = self.worldCanvas.bounds.size.height/2.f;
    
    if( x < halfWidth )
        x -= halfWidth;
    else
        x += halfWidth;
    
    
    if( y < halfHeight )
        y -= halfHeight;
    else
        y += halfHeight;
    
    physicalView.center = CGPointMake(x, y);
    
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
        
        b2CircleShape dynamicBox;
        dynamicBox.m_radius = boxDimenstions.x;
        dynamicBox.m_p = b2Vec2();
        
        b2FixtureDef fixtureDef;
        fixtureDef.shape = &dynamicBox;
        fixtureDef.density = 1.0f;
        fixtureDef.friction = 0.3f;
        body->CreateFixture(&fixtureDef);
        
        ((PhysicalView*)physicalView).body = body;
    }
    
    [self.worldCanvas addSubview: physicalView];
    
    UIGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                       action: @selector(imageTapped:)];
    [physicalView addGestureRecognizer: tap];
    
}

- (NSFetchedResultsController*) resultsController {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        resultsController = [SearchResult fetchAllSortedBy: @"mediaURL"
                                                 ascending: YES
                                             withPredicate: nil
                                                   groupBy: nil];
        resultsController.delegate = self;
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
    
    NSString* mediaURL = [anObject valueForKeyPath: @"mediaURL"];
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
        case NSFetchedResultsChangeUpdate:
        case NSFetchedResultsChangeMove:
        {
            if( ![self.displayedImagePaths containsObject: mediaURL] ) {
                PhysicalImageView* v = [[PhysicalImageView alloc] initWithFrame: CGRectMake(0, 0, 75, 75)];
                v.imageModel = anObject;
                [self addPhysicalBodyForView: v];
            }
            
            break;
        }
        case NSFetchedResultsChangeDelete:
        {
            NSPredicate* imageViewPredicate = [NSPredicate predicateWithFormat: @"self isKindOfClass: %@", [PhysicalImageView class]];
            NSPredicate* imageModelPredicate = [NSPredicate predicateWithFormat: @"self.imageModel.mediaURL = %@", mediaURL];
            NSArray* allImageResults = [self.worldCanvas.subviews filteredArrayUsingPredicate: imageViewPredicate];
            NSArray* allImagesForThisModel = [allImageResults filteredArrayUsingPredicate: imageModelPredicate];
            
            for(UIView* view in allImagesForThisModel) {
                [UIView animateWithDuration: 0.3
                                      delay: 0.0
                                    options: UIViewAnimationOptionCurveEaseIn
                                 animations: ^{
                                     view.alpha = 0.0f;
                                     view.transform = CGAffineTransformMakeScale(0.1, 0.1);
                                 } completion: ^(BOOL finished) {
                                     [view removeFromSuperview];
                                 }];
            }
            break;
        }
        default:
            break;
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if( currentEngineButton == self.albumButton ) {
        textField.text = @"";
        textField.placeholder = NSLocalizedString(@"To search your photo album, push Search on the keyboard below", @"");
    }
    else {
        textField.placeholder = NSLocalizedString(@"Enter your search here", @"");
    }
    
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    NSString* searchTerm = textField.text;
    
    [self.loadingView startAnimating];
    
    BOOL zeroResultsIsError = NO;
    if( currentEngineButton == self.albumButton ) {
        self.paginator = [AssetsPaginator new];
        zeroResultsIsError = YES;
    }
    else if( currentEngineButton == self.bingButton )
        self.paginator = [BingPaginator paginatorWithSearchTerm: searchTerm];
    else if( currentEngineButton == self.flikrButton )
        self.paginator = [FlikrPaginator paginatorWithSearchTerm: searchTerm];
    
    self.paginator.onDidLoadObjectsAtOffset = ^(NSArray* objs, NSUInteger offset) {
        [self.loadingView stopAnimating];
        
        if( zeroResultsIsError && ![objs count]) {
            NSString* title = NSLocalizedString(@"No Photos Found", @"");
            NSString* msg = NSLocalizedString(@"This device appears to have no photos available. You must take some to use the album search engine. Alternatively, try one of our web search engines", @"");
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                            message: msg
                                                           delegate: nil
                                                  cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                                  otherButtonTitles: nil];
            [alert show];
        }
        
        NSLog(@"Loaded %d results", [objs count]);
        
        if( [self.paginator hasNextPage] ) {
            [UIView animateWithDuration: 0.3
                             animations: ^{
                                 self.moreButton.alpha = 1.f;
                             }];
        }
        else {
            [UIView animateWithDuration: 0.3
                             animations: ^{
                                 self.moreButton.alpha = 0.f;
                             }];
        }
    };
    self.paginator.onDidFailWithError = ^(NSError* error, RKObjectLoader* loader) {
        [self.loadingView stopAnimating];
    };
    [self.paginator loadNextPage];
    
    //Remove keyboard
    [self.searchField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return currentEngineButton != self.albumButton;
}

#pragma mark - Actions

- (IBAction) planetTapped:(UITapGestureRecognizer*)sender {
    [self searchPushed: sender];
}

- (IBAction) planetHeld:(UILongPressGestureRecognizer*)sender {
    /*
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
     */
}

- (IBAction) closeMenuPushed:(id)sender {
    RoundMenuView* menu = (RoundMenuView*)[self.view viewWithTag: kRoundMenuPlanetViewTag];
    [menu hide];
}

- (IBAction)closeDetailsPushed:(id)sender {
    ImageDetailView* detailView = nil;
    
    if( [sender isKindOfClass: [UIGestureRecognizer class]] ) {
        detailView = (ImageDetailView*)((UIGestureRecognizer*)sender).view;
    }
    else if( [sender isKindOfClass: [UIButton class]] ) {
        detailView = (ImageDetailView*)((UIButton*)sender).superview;
    }
    
    if( detailView ) {
        [detailView dismissToPoint: CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
    }
}

- (IBAction)morePushed:(UIButton *)sender {
    
#if TARGET_IPHONE_SIMULATOR
    [self.paginator loadNextPage];
#else
    if( [[NSUserDefaults standardUserDefaults] boolForKey: kProductIdentifierPaginatedSearches] ) {
        [self.paginator loadNextPage];
    }
    else {
        [InAppPurchaseProvider purchase: kProductIdentifierPaginatedSearches];
    }
    
#endif
}

- (IBAction)enginePushed:(UIButton *)sender {
    static bool showingEngines = false;
    
    NSSortDescriptor* position = [NSSortDescriptor sortDescriptorWithKey: @"layer.position.y" ascending: YES];
    
    NSArray* buttons = @[self.albumButton, self.googleButton, self.bingButton, self.flikrButton];
    NSArray* ascending = [buttons sortedArrayUsingDescriptors: [NSArray arrayWithObject: position]];
    
    if( showingEngines ) {
        
        if( sender == self.albumButton )
            [[NSUserDefaults standardUserDefaults] setObject: kLocalAlbumSearchEngine forKey: kUserDefaultSearchEngineKey];
        else if( sender == self.googleButton )
            [[NSUserDefaults standardUserDefaults] setObject: kGoogleSearchEngine forKey: kUserDefaultSearchEngineKey];
        else if( sender == self.bingButton )
            [[NSUserDefaults standardUserDefaults] setObject: kBingSearchEngine forKey: kUserDefaultSearchEngineKey];
        else if( sender == self.flikrButton )
            [[NSUserDefaults standardUserDefaults] setObject: kFlikrSearchEngine forKey: kUserDefaultSearchEngineKey];
        
        NSInteger minCount = (sender == currentEngineButton) ? 1 : 0;
        
        //Animate engine buttons away
        for(NSInteger i=0;i<[ascending count]-minCount;i++) {
            UIButton* button = [ascending objectAtIndex: [ascending count]-i-1];
            
            [UIView animateWithDuration: 0.3 delay: i*0.15 options: UIViewAnimationOptionCurveEaseOut animations: ^{
                button.alpha = 0.f;
                button.transform = CGAffineTransformMakeScale(0.1, 0.1);
            } completion: ^(BOOL finished) {
                //Show current engine button again
                if( sender != currentEngineButton && i >= [ascending count] -1 ) {
                    CGPoint currentCenter = currentEngineButton.center;
                    CGPoint gotoCenter = sender.center;
                    
                    sender.center = currentCenter;
                    currentEngineButton.center = gotoCenter;
                    currentEngineButton.transform = CGAffineTransformIdentity;
                    [UIView animateWithDuration: 0.15 delay: 0 options: 0 animations: ^{
                        NSArray* now = [buttons sortedArrayUsingDescriptors: [NSArray arrayWithObject: position]];
                        UIView* top = [now objectAtIndex: 0];
                        top.alpha = 1.f;
                        top.transform = CGAffineTransformIdentity;
                    } completion: ^(BOOL finished) {
                        
                    }];
                    currentEngineButton = sender;
                }
                showingEngines = false;
            }];
        }
        
        if( sender == self.albumButton ) {
            self.searchField.text = @"";
            self.searchField.placeholder = NSLocalizedString(@"To search your photo album, push Search on the keyboard below", @"");
        }
        else {
            self.searchField.placeholder = NSLocalizedString(@"Enter your search here", @"");
        }
        
    }
    else {
        //Animate engine buttons in
        for(NSUInteger i=1;i<[ascending count];i++) {
            UIButton* button = [ascending objectAtIndex: i];
            button.transform = CGAffineTransformMakeScale(0.1, 0.1);
            
            [UIView animateWithDuration: 0.3 delay: (i-1)*0.15 options: UIViewAnimationOptionCurveEaseIn animations: ^{
                button.alpha = 1.f;
                button.transform = CGAffineTransformIdentity;
            } completion: ^(BOOL finished) {
                showingEngines = true;
            }];
        }
    }
}

- (IBAction)screenshotPushed:(UIButton *)sender {
    
    NSString* msg = NSLocalizedString(@"Saving screenshot", @"");
    [SVProgressHUD showWithStatus: msg maskType: SVProgressHUDMaskTypeGradient];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGSize imageSize = self.worldCanvas.bounds.size;
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self.worldCanvas.layer renderInContext:context];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    });
}


- (IBAction) playPushed:(id)sender {
    physicsPaused = !physicsPaused;
}

- (IBAction)resetPushed:(UIButton *)sender {
}

- (IBAction) refreshPushed:(id)sender {
    
    for(SearchResult* result in [SearchResult findAll])
        [result deleteEntity];
    
    [[RKObjectManager sharedManager].objectStore save: nil];
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
    [InAppPurchaseProvider purchase: kProductIdentifierAlternativeSearches];
}

- (IBAction) imageTapped:(UITapGestureRecognizer*)sender {
    UIView* v = sender.view;
    if( [v isKindOfClass: [PhysicalImageView class]] ) {
        PhysicalImageView* view = (PhysicalImageView*)v;
        
        ImageDetailView* detailView = [[[NSBundle mainBundle] loadNibNamed: @"ImageDetailView"
                                                                     owner: self
                                                                   options: nil] lastObject];
        detailView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        
        [self.view addSubview: detailView];
        [detailView showFromPoint: [self.view convertPoint: view.center fromView: self.worldCanvas]];
    }
}


#pragma mark - Notifications
- (void) itemPurchased: (NSNotification*) notif {
    NSString* identifier = [notif.userInfo objectForKey: kProductPurchasedIdentifierKey];
    
    if( [identifier isEqualToString: kProductIdentifierPaginatedSearches] ) {
        [self morePushed: self.moreButton];
    }
}

- (void) image: (UIImage*) image didFinishSavingWithError: (NSError*) error contextInfo: (void*) contextInfo {
    if( error ) {
        NSString* msg = NSLocalizedString(@"Saving of screenshot failed", @"");
        
        [SVProgressHUD showErrorWithStatus: msg];
    }
    else {
        NSString* msg = nil;
        
        if( [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] )
            msg = NSLocalizedString(@"A screenshot has been saved to your Camera Roll album", @"");
        else
            msg = NSLocalizedString(@"A screenshot has been saved to your Saved Photos album", @"");
        
        
        [SVProgressHUD showSuccessWithStatus: msg];
    }
}

#pragma mark - Keyboard Management
- (void) keyboardWillAppear: (NSNotification*) notif {
    NSTimeInterval interval = [[notif.userInfo objectForKey: UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = (UIViewAnimationCurve)[[notif.userInfo objectForKey: UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    //currentEngineButton.center = CGPointMake(self.view.bounds.size.width-10-currentEngineButton.bounds.size.width/2.f, 10 + currentEngineButton.bounds.size.height/2.f);
    
    [UIView animateWithDuration: interval
                          delay: 0.0
                        options: curve
                     animations: ^{
                         self.fadeWorldView.alpha = 0.8;
                         
                         CGFloat xOffset = self.searchField.frame.origin.x;
                         
                         CGRect searchBarFrame = self.searchField.frame;
                         searchBarFrame.size.width = self.view.bounds.size.width - xOffset - currentEngineButton.bounds.size.width - 20;
                         
                         self.searchField.frame = searchBarFrame;
                         self.searchField.alpha = 1.f;
                         currentEngineButton.alpha = 1.f;
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
                         self.albumButton.alpha = 0.f;
                         self.googleButton.alpha = 0.f;
                         self.bingButton.alpha = 0.f;
                         self.flikrButton.alpha = 0.f;
                         
                     } completion: ^(BOOL finished) {
                         
                     }];
}

@end

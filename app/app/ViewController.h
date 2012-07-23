//
//  ViewController.h
//  app
//
//  Created by Paul de Lange on 15/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlanetView;
@class PhysicalWorldView;

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIButton *searchbutton;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIView *fadeWorldView;
@property (weak, nonatomic) IBOutlet PhysicalWorldView *worldCanvas;

@property (weak, nonatomic) IBOutlet PlanetView *planetView;

- (IBAction)infoPushed:(UIButton *)sender;
- (IBAction)searchPushed:(id)sender;
- (IBAction)closeDetailsPushed:(id)sender;

@end

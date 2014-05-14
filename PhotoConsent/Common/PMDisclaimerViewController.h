//
//  PMDisclaimerViewController.h
//  Photoconsent
//
//  Created by Alex Rafferty on 06/01/2014.
//  Copyright (c) 2014 Podmedics. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PMDisclaimerViewController : UIViewController

@property (strong, nonatomic) UIActivity* activity;

- (IBAction)acceptDisclaimer:(id)sender;
- (IBAction)cancel:(id)sender;


@end

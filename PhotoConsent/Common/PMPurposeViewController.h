//
//  PMPurposeViewController.h
//  Photoconsent
//
//  Created by Alex Rafferty on 06/01/2014.
//  Copyright (c) 2014 Podmedics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PMPurposeViewController : UIViewController


@property (nonatomic, weak) IBOutlet UITextView *textview;
@property (nonatomic, weak) IBOutlet UINavigationBar *navBar;
@property (nonatomic, weak) IBOutlet UINavigationItem *navItem;

@property (nonatomic, assign) NSUInteger purpose;


@end

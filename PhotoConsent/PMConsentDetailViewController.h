//
//  PMConsentDetailViewController.h
//  Photoconsent
//
//  Created by Edward Wallitt on 17/04/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface PMConsentDetailViewController : UIViewController

@property (strong, nonatomic) IBOutlet UISwitch *ib_assessmentSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *ib_educationSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *ib_publicationSwitch;

@property (strong, nonatomic) IBOutlet UIButton *assessmentLabel;
@property (strong, nonatomic) IBOutlet UIButton *educationLabel;
@property (strong, nonatomic) IBOutlet UIButton *publicationLabel;

@property (strong, nonatomic) id userPhoto;

- (IBAction)onAssessment:(id)sender;
- (IBAction)onEducation:(id)sender;
- (IBAction)onPublication:(id)sender;

@end

//
//  PMConsentDetailViewController.h
//  Photoconsent
//
//  Created by Edward Wallitt on 17/04/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMPhotoConsentProtocol.h"



@interface PMConsentDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISwitch *ib_assessmentSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *ib_educationSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *ib_publicationSwitch;

@property (weak, nonatomic) IBOutlet UIButton *assessmentLabel;
@property (weak, nonatomic) IBOutlet UIButton *educationLabel;
@property (weak, nonatomic) IBOutlet UIButton *publicationLabel;

@property (weak,nonatomic) id<ConsentDelegate> consentDelegate;

@property (strong, nonatomic) id userPhoto;

- (IBAction)onAssessment:(id)sender;
- (IBAction)onEducation:(id)sender;
- (IBAction)onPublication:(id)sender;
- (IBAction)cancelBtn:(id)sender;
- (IBAction)pressedNextButton:(id)sender;

@end

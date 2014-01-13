//
//  PMConsentViewController.h
//  Photoconsent
//
//  Created by Edward Wallitt on 27/02/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Parse/Parse.h>

@interface PMConsentViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView   *tblView;

@property (strong, nonatomic) id m_selectedPhoto;
@property (strong, nonatomic) UIActivity *activityConsent;

@end

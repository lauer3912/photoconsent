//
//  PMCompleteViewController.h
//  Photoconsent
//
//  Created by Edward Wallitt on 28/02/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "PMPhotoConsentProtocol.h"


@interface PMCompleteViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) id userPhoto;

@property (weak,nonatomic) id<ConsentDelegate> consentDelegate;

- (IBAction)completeAndUpload:(id)sender;



@end

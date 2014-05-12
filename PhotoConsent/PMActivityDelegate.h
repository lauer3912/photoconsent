//
//  PMActivityDelegate.h
//  Photoconsent
//
//  Created by Alex Rafferty on 09/01/2014.
//  Copyright (c) 2014 Podmedics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMPhotoConsentProtocol.h"

@interface PMActivityDelegate : UIViewController <PMPhotoConsentProtocol>

@property (strong, nonatomic) id senderController;

@property (strong, nonatomic) UIImagePickerController *cameraController;

//pass consent delegate on to cameraRoll activity
@property (weak, nonatomic) id<ConsentDelegate> consentDelegate;
//pass these delegates on to cameraRoll activity
@property (weak, nonatomic) id<UIAlertViewDelegate> alertviewDelegate;


@end

//
//  PMCameraRollActivity.h
//  Photoconsent
//
//  Created by Alex Rafferty on 09/01/2014.
//  Copyright (c) 2014 Podmedics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMPhotoConsentProtocol.h"


@interface PMCameraRollActivity : UIActivity

@property (strong,nonatomic) id<UIAlertViewDelegate> alertViewDelegate;

@property (strong, nonatomic) id senderController;

@property (weak, nonatomic) id<ConsentDelegate> consentDelegate;


@end

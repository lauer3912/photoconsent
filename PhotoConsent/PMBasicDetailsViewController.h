//
//  PMBasicDetailsViewController.h
//  Photoconsent
//
//  Created by Edward Wallitt on 27/02/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMPhotoConsentProtocol.h"

@interface PMBasicDetailsViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) id userPhoto;

@property (weak,nonatomic) id<ConsentDelegate> consentDelegate;


@end

//
//  PMMenuViewController.h
//  PhotoConsent
//
//  Created by Alex Rafferty on 16/02/2014.
//  Copyright (c) 2014 PM. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol shareActivityProtocol <NSObject>

- (void) shareActivity:(id)sender;
- (void) upgradePhotoConsent:(id)sender;
- (void) showConsentTypes;
- (void) showDisclaimer;

@end

@interface PMMenuViewController : UIViewController

@property (strong,nonatomic) id<shareActivityProtocol> delegate;

@end

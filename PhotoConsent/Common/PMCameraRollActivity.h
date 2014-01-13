//
//  PMCameraRollActivity.h
//  Photoconsent
//
//  Created by Alex Rafferty on 09/01/2014.
//  Copyright (c) 2014 Podmedics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PMCameraRollActivity : UIActivity

    @property (strong, nonatomic) id senderController;

- (id) initWithSenderController:(UIViewController*)controller;

@end

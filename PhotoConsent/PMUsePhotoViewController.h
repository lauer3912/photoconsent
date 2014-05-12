//
//  PMUsePhotoViewController.h
//  PhotoConsent
//
//  Created by Alex Rafferty on 07/05/2014.
//  Copyright (c) 2014 PM. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PMUsePhotoViewController : UIViewController

@property (strong,nonatomic) id<UIAlertViewDelegate> alertViewDelegate;

@property (weak, nonatomic) IBOutlet UIImageView *imageview;

@end

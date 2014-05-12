//
//  PMCloudContentsViewController.h
//  Photoconsent
//
//  Created by Alex Rafferty on 18/12/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "PMRefreshActivity.h"

@interface PMCloudContentsViewController : UICollectionViewController <MBProgressHUDDelegate,PMRefreshActivityProtocol,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray *allImages;
@property (strong, nonatomic) NSCache *cachedSmallImages;
@property (strong, nonatomic) NSCache *cachedLargeImages;
@property (strong, nonatomic) UIActivity *activity;
@property (strong, nonatomic) UIImagePickerController *cameraController;

@property (strong, nonatomic) NSNumber* dataArrayDidChange;
@property (assign, nonatomic) BOOL shouldDim;
@property (strong, nonatomic) UIImage *image;

- (IBAction)completeConsent:(UIStoryboardSegue *)segue;
- (void) clearCollectionView;
- (void) refreshAndCacheObjects;

@end

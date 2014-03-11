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
#import "PMPhotoConsentProtocol.h"
#import "PMRefreshActivity.h"

@interface PMCloudContentsViewController : UICollectionViewController <MBProgressHUDDelegate,PMRefreshActivityProtocol>

@property (strong, nonatomic) NSMutableArray *allImages;
@property (strong, nonatomic) NSCache *cachedImages;
@property (weak,nonatomic) id<PMPhotoConsentProtocol> activityDelegate;
@property (weak,nonatomic) id<PMPhotoConsentProtocol> cameraDelegate;

@property (strong, nonatomic) NSNumber* dataArrayDidChange;

- (IBAction)completeConsent:(UIStoryboardSegue *)segue;
- (void) clearCollectionView;
- (void) loadAndCacheObjects;

@end

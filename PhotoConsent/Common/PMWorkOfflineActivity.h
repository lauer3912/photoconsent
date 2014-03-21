//
//  PMWorkOfflineActivity.h
//  PhotoConsent
//
//  Created by Alex Rafferty on 12/03/2014.
//  Copyright (c) 2014 PM. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol PMWorkOfflineActivityProtocol <NSObject>

- (void) loadAndCacheDeviceImages:(id) sender;
- (void) userDidLogout:(id) sender;

@end


@interface PMWorkOfflineActivity : UIActivity

@property (weak, nonatomic) id<PMWorkOfflineActivityProtocol> offlineDelegate;


@end

//
//  PMRefreshActivity.h
//  PhotoConsent
//
//  Created by Alex Rafferty on 11/03/2014.
//  Copyright (c) 2014 PM. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PMRefreshActivityProtocol <NSObject>

- (void) loadAndCacheObjects;

@end


@interface PMRefreshActivity : UIActivity

@property (weak, nonatomic) id<PMRefreshActivityProtocol> refreshDelegate;

@end

//
//  PMLoginActivity.h
//  Photoconsent
//
//  Created by Alex Rafferty on 09/01/2014.
//  Copyright (c) 2014 Podmedics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMRefreshActivity.h"


@protocol PMWStopOfflineActivityProtocol <NSObject>

- (void) userDidLogout:(id) sender;

@end



@interface PMLoginActivity : UIActivity

@property (weak, nonatomic) id<PMWStopOfflineActivityProtocol> stopOfflineDelegate;
@property (weak, nonatomic) id<PMRefreshActivityProtocol> refreshDelegate;

@end

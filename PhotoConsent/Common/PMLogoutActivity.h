//
//  PMLogoutActivity.h
//  Photoconsent
//
//  Created by Alex Rafferty on 09/01/2014.
//  Copyright (c) 2014 Podmedics. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PMLogoutActivityProtocol <NSObject>

- (void) userDidLogout:(id) sender;

@end

@interface PMLogoutActivity : UIActivity

@property (weak, nonatomic) id<PMLogoutActivityProtocol> delegate;
@end

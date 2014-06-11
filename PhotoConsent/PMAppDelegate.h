//
//  PMAppDelegate.h
//  Photoconsent
//
//  Created by Edward Wallitt on 24/02/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <StoreKit/StoreKit.h>

@interface PMAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate, SKPaymentTransactionObserver, SKRequestDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readonly) int networkStatus;
@property (strong, nonatomic) dispatch_source_t timeoutTimer;

- (BOOL)isParseReachable;

@end

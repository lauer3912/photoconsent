//
//  ConsentStore.h
//  Photoconsent
//
//  Created by Alex Rafferty on 04/01/2014.
//  Copyright (c) 2014 Podmedics. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Consent;

@interface ConsentStore : NSObject


@property (nonatomic, strong) NSMutableDictionary *imageCache;

+ (ConsentStore *)sharedDeviceConsents;
- (NSArray *)allDeviceConsents;
- (NSString *)deviceConsentArchivePath;
- (BOOL)saveChanges;
- (Consent*)addDeviceConsent:(Consent *)deviceConsent;
- (void)deleteDeviceConsent:(Consent *)deviceConsent;



@end

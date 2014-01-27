//
//  ConsentStore.m
//  Photoconsent
//
//  Created by Alex Rafferty on 03/01/2014.
//  Copyright (c) 2014 Podmedics. All rights reserved.
//

#import "ConsentStore.h"
#import "Consent.h"

@interface ConsentStore ()
{
    NSMutableArray *allDeviceConsents;
}

@end

@implementation ConsentStore

- (id)init
{
    self = [super init];
    if (self) {
        NSString *path = [self deviceConsentArchivePath];
        allDeviceConsents = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        // if an array hadn't been saved previously, create a new empty one
        if (!allDeviceConsents)
            allDeviceConsents = [NSMutableArray new];
    }
    
    return self;
}


#pragma mark -
#pragma mark - Shared store and archiving

+ (ConsentStore *)sharedDeviceConsents
{
 // ensure that multiple instance of consent store cannot be created
   
    __strong static ConsentStore *sharedStore;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedStore = [ConsentStore new];
    });
    return sharedStore;
    
}

- (NSArray *)allDeviceConsents
{
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    NSArray *descriptors = [NSArray arrayWithObjects:descriptor, nil];
    return [allDeviceConsents sortedArrayUsingDescriptors:descriptors];
}

- (NSString *)deviceConsentArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"consents.archive"];
}

- (BOOL)saveChanges
{
    NSString *path = [self deviceConsentArchivePath];
    return [NSKeyedArchiver archiveRootObject:allDeviceConsents toFile:path];
}

- (Consent*)addDeviceConsent:(Consent *)deviceConsent
{
    if (deviceConsent) {
         [allDeviceConsents addObject:deviceConsent];
    }
   
    return deviceConsent;
    
}

- (void)deleteDeviceConsent:(Consent *)deviceConsent
{
    [allDeviceConsents removeObject:deviceConsent];
    
}


@end

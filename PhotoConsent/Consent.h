//
//  Consent.h
//  Photoconsent
//
//  Created by Alex Rafferty on 04/01/2014.
//  Copyright (c) 2014 Podmedics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Consent : NSObject <NSCoding>


@property (strong, nonatomic) NSString *referenceID;
@property (strong, nonatomic) NSString *patientName;
@property (strong, nonatomic) NSString *patientEmail;
@property (strong, nonatomic) NSNumber *Assessment;
@property (strong, nonatomic) NSNumber *Education;
@property (strong, nonatomic) NSNumber *Publication;
@property (strong, nonatomic)  NSDate *created;
@property (strong, nonatomic)  NSData *imageFile;
@property (strong, nonatomic)  NSData *consentSignature;
@property (strong, nonatomic)  NSURL *assetURL;

+ (void)saveConsent:(Consent *)consent;
+ (Consent *)getConsent;

- (id) initWithReference:(NSString*)referenceID imageFile:(NSData*)imageFile;
- (Consent *)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)anEncoder;

@end

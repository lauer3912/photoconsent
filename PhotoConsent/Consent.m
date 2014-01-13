//
//  Consent.m
//  Photoconsent
//
//  Created by Alex Rafferty on 03/01/2014.
//  Copyright (c) 2014 Podmedics. All rights reserved.
//

#import "Consent.h"

@implementation Consent


#pragma mark -
#pragma mark - NSCoding

- (id) initWithReference:(NSString*)referenceID imageFile:(NSData *)imageFile {
    self = [super init];
    if (self) {
        _referenceID = referenceID;
        _imageFile = imageFile;
    }
    return self;
}

+ (NSString *)getPathToArchive
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [paths objectAtIndex:0];
    
    return [docsDir stringByAppendingPathComponent:@"consent.model"];
}

- (Consent *)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _referenceID = [aDecoder decodeObjectForKey:@"referenceID"];
        _patientName= [aDecoder decodeObjectForKey:@"patientName"];
        _patientEmail = [aDecoder decodeObjectForKey:@"patientEmail"];
        _Assessment = [aDecoder decodeObjectForKey:@"Assessment"];
        _Education = [aDecoder decodeObjectForKey:@"Education"];
        _Publication = [aDecoder decodeObjectForKey:@"Publication"];
        _created = [aDecoder decodeObjectForKey:@"created"];
        _imageFile = [aDecoder decodeObjectForKey:@"imageFile"];
        _consentSignature = [aDecoder decodeObjectForKey:@"consentSignature"];
        _assetURL = [aDecoder decodeObjectForKey:@"assetURL"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)anEncoder
{
    [anEncoder encodeObject:_referenceID forKey:@"referenceID"];
    [anEncoder encodeObject:_patientName forKey:@"patientName"];
    [anEncoder encodeObject:_patientEmail forKey:@"patientEmail"];
    [anEncoder encodeObject:_Assessment forKey:@"Assessment"];
    [anEncoder encodeObject:_Education forKey:@"Education"];
    [anEncoder encodeObject:_Publication forKey:@"Publication"];
    [anEncoder encodeObject:_created forKey:@"created"];
    [anEncoder encodeObject:_imageFile forKey:@"imageFile"];
    [anEncoder encodeObject:_consentSignature forKey:@"consentSignature"];
    [anEncoder encodeObject:_assetURL forKey:@"assetURL"];
    
}


#pragma mark -
#pragma mark - Save and retrieve Consent data

+ (void)saveConsent:(Consent *)consent
{
    [NSKeyedArchiver archiveRootObject:consent toFile:[self getPathToArchive]];
}

+ (Consent *)getConsent
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self getPathToArchive]];
}


@end

/*
     File: PageViewControllerData.h
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 Modified by Alex Rafferty January - March 2014
 
 */

#import <Foundation/Foundation.h>


@protocol PageViewControllerImageToDisplayProtocol <NSObject>

- (UIImage*)imageAtIndex:(NSNumber*) index forCache:(NSCache*)imageCache;

@end

@interface PageViewControllerData : NSObject

   @property (strong, nonatomic) NSCache *largeCachedImages;

+ (PageViewControllerData *)sharedInstance;

    @property (nonatomic, strong) NSMutableArray *photoAssets;

    @property (weak, nonatomic) id<PageViewControllerImageToDisplayProtocol> delegate;

- (NSUInteger)photoCount;
- (UIImage *)photoAtIndex:(NSUInteger)index;
- (id)objectAtIndex:(NSUInteger)index;

@end
//
//  PMDimmableCollectionView.m
//  PhotoConsent
//
//  Created by Alex Rafferty on 16/02/2014.
//  Copyright (c) 2014 PM. All rights reserved.
//

#import "PMDimmableCollectionView.h"

@implementation PMDimmableCollectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


-(void)tintColorDidChange {
    if (self.tintAdjustmentMode == UIViewTintAdjustmentModeDimmed) {
        [self setAlpha:0.50];
    } else
        [self setAlpha:1.0];
}


@end

//
//  PMLogoLabel.m
//  Photoconsent
//
//  Created by Edward Wallitt on 06/06/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import "PMLogoLabel.h"

@implementation PMLogoLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, 100, 40)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.textColor = [UIColor whiteColor];
        [self setFont:[UIFont boldSystemFontOfSize:24]];
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

@end

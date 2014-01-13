//
//  PMTouchTrackerView.m
//  Photoconsent
//
//  Created by Edward Wallitt on 28/02/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//


#import "PMTouchTrackerView.h"

@interface PMTouchTrackerView ()
{
    NSUInteger touchCount;
}
@end

@implementation PMTouchTrackerView

- (void) clear
{
    path = nil;
    [self setNeedsDisplay];
}

#pragma mark - Touch Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    touchCount = 0;
    if (!path) {
        path = [UIBezierPath bezierPath];
        path.lineWidth = 2.5f;

    }
    
    UITouch *touch = [touches anyObject];
    [path moveToPoint:[touch locationInView:self]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    touchCount ++;
    UITouch *touch = [touches anyObject];
    [path addLineToPoint:[touch locationInView:self]];
    if (touchCount % 3 == 0) {
        [self setNeedsDisplay];
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    [path addLineToPoint:[touch locationInView:self]];
    [self setNeedsDisplay];
        
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    [[UIColor blackColor] set];
    [path stroke];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.multipleTouchEnabled = YES;  //was NO
        self.exclusiveTouch = YES; //added by AR
    }
    return self;
}

@end

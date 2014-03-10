//
//  RMPainter.m
//  Based on FingerPaint demo given by Elizabeth Reid on iTunes to Carnegie Mellon Students
//
//  Created by Alex Rafferty on 14/01/2014.
//  Copyright (c) 2014 RMS. All rights reserved.
//

#import "RMPainter.h"
#import "RMCanvas.h"
#import "RMCanvasView.h"
#import "PMSignViewController.h"
#import <QuartzCore/CAShapeLayer.h>
#import <QuartzCore/CALayer.h>

@interface RMPainter ()
{
    NSInteger locationCount;
}

@end

@implementation RMPainter

- (id) initWithCanvas:(RMCanvas *)canvas {
    
    if (self = [super init]) {
        
        _canvas = canvas;
        
        
    }
    return self;
}

-(void) setupContextWithCanvas:(RMCanvas*)canvas {
    
    RMCanvasView *canvasView = canvas.canvasView;
    
    //Create a bitmap reference for rendering into
    size_t width = ceilf(canvasView.bounds.size.width);
    size_t height = ceilf(canvasView.bounds.size.height);
    //up to the closest power of 2
    int bitMapBytesPerRow = ((width * 4 * 0x1F) & ~0x1F );
    if (_renderingContext) {
         CGContextRelease(_renderingContext);
    }
   
    _renderingContext = CGBitmapContextCreate(NULL, width, height, 8, bitMapBytesPerRow, CGColorSpaceCreateDeviceRGB(), kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst);
    
    CGContextTranslateCTM(_renderingContext, 0.0, height); 
    CGContextScaleCTM(_renderingContext, 1.0, -1.0);
    CGContextSetStrokeColorWithColor(_renderingContext, _canvas.currentPaintcolor.CGColor);
    CGContextSetLineCap(_renderingContext, kCGLineCapRound);
    locationCount = 0;
    [[(PMSignViewController*)_canvas.viewController nextButton] setEnabled:NO];
   
}

- (void) paintGesture:(UIGestureRecognizer*) paintGesture {
    
    CGPoint location = [paintGesture locationInView:_canvas.canvasView];
    locationCount++;

    switch (paintGesture.state) {
        case UIGestureRecognizerStatePossible:
            NSLog(@"A gesture recognizer should never fire in state possible");
            break;
        case UIGestureRecognizerStateBegan:
            _previousPoint = location;
            break;
        case UIGestureRecognizerStateChanged:
            CGContextSetLineWidth(_renderingContext, _canvas.currentStrokewidth);
            //Stroking the path clears out the line in the context, so we always need to move to the previous point before adding a line to the new point
            CGContextBeginPath(_renderingContext);
            CGContextMoveToPoint(_renderingContext, _previousPoint.x, _previousPoint.y);
            CGContextAddLineToPoint(_renderingContext, location.x, location.y);
            //then render the new path in the context
            CGContextStrokePath(_renderingContext);
            //and make an image from the bitmap context with all of the rendering
            
            CGImageRef currentImage = CGBitmapContextCreateImage(_renderingContext);
            //... and set it to the canvas view's contents
            _canvas.canvasView.layer.contents = (__bridge id)currentImage;
            CGImageRelease(currentImage);
            _previousPoint = location;
            break;
        case UIGestureRecognizerStateEnded:
            
            //enable the Next button when user signature exceeds 50
            if (locationCount > 2) {
                [[(PMSignViewController*)_canvas.viewController nextButton] setEnabled:YES];
                locationCount = 0;
            }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            //we have no special cleanup we have to do in this case, but sometimes state needs to be torn down when a gesture is cancelled
            break;
        default:
            break;
    }
    
}

@end

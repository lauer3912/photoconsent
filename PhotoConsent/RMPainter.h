//
//  RMPainter.h
//  Based on FingerPaint demo given by Elizabeth Reid on iTunes to Carnegie Mellon Students
//
//  Created by Alex Rafferty on 14/01/2014.
//  Copyright (c) 2014 RMS. All rights reserved.
//

#import <Foundation/Foundation.h>


@class RMCanvas, RMCanvasView;

@interface RMPainter : NSObject

@property (strong, nonatomic) RMCanvas* canvas;
@property (assign, nonatomic) CGContextRef renderingContext;
@property (assign, nonatomic) CGPoint previousPoint;

-(id) initWithCanvas:(RMCanvas*)canvas;
-(void) paintGesture:(UIGestureRecognizer*) paintGesture;
-(void) setupContextWithCanvas:(RMCanvas*)canvas;

@end

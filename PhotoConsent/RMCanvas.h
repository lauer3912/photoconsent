//
//  RMCanvas.h
//  Based on FingerPaint demo given by Elizabeth Reid on iTunes to Carnegie Mellon Students
//
//  Created by Alex Rafferty on 14/01/2014.
//  Copyright (c) 2014 RMS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RMCanvasView;


@interface RMCanvas : NSObject


@property (strong, nonatomic) RMCanvasView* canvasView;

@property (strong, nonatomic) UIColor* currentPaintcolor;
@property (assign, nonatomic) CGFloat currentStrokewidth;

@property (strong, nonatomic) UIViewController* viewController;


-(id) initWithCanvasView:(RMCanvasView*)canvasView;

@end

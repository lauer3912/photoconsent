//
//  RMCanvas.m
//  Based on FingerPaint demo given by Elizabeth Reid on iTunes to Carnegie Mellon Students
//
//  Created by Alex Rafferty on 14/01/2014.
//  Copyright (c) 2014 RMS. All rights reserved.
//

#import "RMCanvas.h"

@implementation RMCanvas



-(id) initWithCanvasView:(RMCanvasView *)canvasView {
    
    if (self = [super init]) {
        _canvasView = canvasView;
    }
    
    return self;
    
}


@end

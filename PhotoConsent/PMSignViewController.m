//
//  PMSignViewController.m
//  Photoconsent
//
//  Created by Edward Wallitt on 28/02/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import "PMSignViewController.h"
#import "PMTouchTrackerView.h"
#include <QuartzCore/QuartzCore.h>
#import "PMCompleteViewController.h"
#import "Consent.h"

#import "RMCanvas.h"
#import "RMCanvasView.h"
#import "RMPainter.h"
#import "UIColor+More.h"

@interface PMSignViewController ()
<UIGestureRecognizerDelegate>

@end

@implementation PMSignViewController

- (void)viewDidLoad  {
    [super viewDidLoad];
   
    //set up the canvas with its default values
    _canvas = [[RMCanvas alloc] initWithCanvasView:_canvasView];
    _canvas.currentStrokewidth = 2.2f;
    _canvas.currentPaintcolor = [UIColor darkTextColor];
    _canvas.viewController = self;
    
    //create a painter object and gesture to read touch events
    RMPainter *painter = [[RMPainter alloc] initWithCanvas:_canvas];
    UILongPressGestureRecognizer *paintGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:painter action:@selector(paintGesture:)];
    paintGesture.minimumPressDuration = 0;//recognises the touch immediately
    paintGesture.delegate = self;
    [_canvasView addGestureRecognizer:paintGesture];
    _painter = painter;
    
    
    [self.view setBackgroundColor:[UIColor turquoise]];
    
}

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self clear:nil];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goToConfirmationScreen"]) {
        PMCompleteViewController *controller = segue.destinationViewController;
        controller.userPhoto = _userPhoto;
    }
}

- (IBAction)pressedCompleteConsent:(id)sender {
    
    
    CGImageRef signature = CGBitmapContextCreateImage(_painter.renderingContext);
    UIImage *image = [UIImage imageWithCGImage:signature];
    CGImageRelease(signature);
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    if ([_userPhoto isKindOfClass:[PFObject class]]) {
        PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
        [_userPhoto setValue:imageFile forKey:@"consentSignature"];
    } else if ([_userPhoto isKindOfClass:[Consent class]])
        [_userPhoto setValue:imageData forKey:@"consentSignature"];
    
    
    // transition to the final screen
    [self performSegueWithIdentifier:@"goToConfirmationScreen" sender:nil];
    
}



- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    return YES;
}

-(IBAction)clear:(id)sender {
    
    CGImageRef currentImage = nil;
    //... and set it to the canvas view's contents
    _canvas.canvasView.layer.contents = (__bridge id)currentImage;
    CGImageRelease(currentImage);
    
    [_painter setupContextWithCanvas:_canvas];
}


@end

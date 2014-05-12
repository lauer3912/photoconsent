//
//  PMSignViewController.h
//  Photoconsent
//
//  Created by Edward Wallitt on 28/02/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMPhotoConsentProtocol.h"

@class RMCanvas, RMCanvasView, RMPainter;

@interface PMSignViewController : UIViewController

@property (strong, nonatomic) id userPhoto;


@property (strong, nonatomic) RMCanvas *canvas;
@property (weak, nonatomic) IBOutlet  RMCanvasView *canvasView;
@property (strong, nonatomic) RMPainter *painter;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;

@property (weak,nonatomic) id<ConsentDelegate> consentDelegate;

@end

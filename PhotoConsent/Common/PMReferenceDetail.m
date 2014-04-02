//
//  PMReferenceDetail.m
//  Photoconsent
//
//  Created by Alex Rafferty on 10/01/2014.
//  Copyright (c) 2014 Podmedics. All rights reserved.
//

#import "PMReferenceDetail.h"
#import "PMTextConstants.h"


@interface PMReferenceDetail ()

@end

@implementation PMReferenceDetail

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if ([self.title isEqualToString:@"Assessment"])  {
        [_textview setAttributedText:[self attributedStringForText:kPMTextConstants_Assessment]];
    } else
    if ([self.title isEqualToString:@"Education"])  {
        [_textview setAttributedText:[self attributedStringForText:kPMTextConstants_Education]];
    } else
    if ([self.title isEqualToString:@"Publication"])  {
        [_textview setAttributedText:[self attributedStringForText:kPMTextConstants_Publication]];
    }
    
    [self.view setBackgroundColor:[UIColor turquoise]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSAttributedString*) attributedStringForText: (NSString*)string {
    
    UIColor *foregroundColour = [UIColor darkTextColor];
    
    NSMutableAttributedString *attrMutableString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", string]];
    
    NSRange range = [[attrMutableString string] rangeOfString:string];
    [attrMutableString addAttributes:@{NSForegroundColorAttributeName: foregroundColour, NSFontAttributeName:[UIFont systemFontOfSize:14.0]} range:range];
    
    return attrMutableString;
}


@end

//
//  PMDisclaimerViewController.m
//  Photoconsent
//
//  Created by Alex Rafferty on 06/01/2014.
//  Copyright (c) 2014 Podmedics. All rights reserved.
//

#import "PMDisclaimerViewController.h"
#import "PMTextConstants.h"

@interface PMDisclaimerViewController ()


@property (weak, nonatomic) IBOutlet UILabel* dislcaimerLabel0;
@property (weak, nonatomic) IBOutlet UILabel* dislcaimerLabel1;
@property (weak, nonatomic) IBOutlet UILabel* dislcaimerLabel2;



@property (weak, nonatomic) IBOutlet UIButton* dislcaimerBtn0;
@property (weak, nonatomic) IBOutlet UIButton* dislcaimerBtn1;
@property (weak, nonatomic) IBOutlet UIButton* dislcaimerBtn2;
@property (weak, nonatomic) IBOutlet UIButton* dislcaimerBtn3;

@end

@implementation PMDisclaimerViewController

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
    [_dislcaimerLabel0 setAttributedText:[self attributedStringForText:[NSString stringWithFormat:@"%@ %@", kPMTextConstants_Disclaimer0, kPMTextConstants_Disclaimer1]]];
    
    [_dislcaimerLabel1 setAttributedText:[self attributedStringForText:kPMTextConstants_Disclaimer1]];
    [_dislcaimerLabel2 setAttributedText:[self attributedStringForText:[NSString stringWithFormat:@"%@  %@\n%@", kPMTextConstants_Disclaimer6, kPMTextConstants_Disclaimer7, kPMTextConstants_Disclaimer8]]];
    
    
    
    
    [_dislcaimerBtn0 setTitle:kPMTextConstants_Disclaimer2 forState:UIControlStateNormal];
    [_dislcaimerBtn0 setTag:0];
    [_dislcaimerBtn1 setTitle:kPMTextConstants_Disclaimer3 forState:UIControlStateNormal];
    [_dislcaimerBtn1 setTag:1];
    [_dislcaimerBtn2 setTitle:kPMTextConstants_Disclaimer4 forState:UIControlStateNormal];
    [_dislcaimerBtn2 setTag:2];
    [_dislcaimerBtn3 setTitle:kPMTextConstants_Disclaimer5 forState:UIControlStateNormal];
    [_dislcaimerBtn3 setTag:3];
    
    [self.view setBackgroundColor:[UIColor turquoise]];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)disclaimer:(id)sender {
    [self updateUserDefaults];
    if (_activity)
        [_activity activityDidFinish:YES];
    else
        [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
            
        }];
}

-(void) updateUserDefaults {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *disclaimerAcknowledged = [defaults objectForKey:@"disclaimerAcknowledged"];
    // set acknowledged = YES if it is not already, otherwise leave alone
    if ([disclaimerAcknowledged boolValue] == NO) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSString* formatString =  [NSDateFormatter dateFormatFromTemplate:@"EdMMMhh:mma" options:0 locale:[NSLocale currentLocale]];
        [dateFormatter setDateFormat:formatString];
         NSDate *date =  [NSDate date];
        
        disclaimerAcknowledged = [NSNumber numberWithBool:YES];
        [defaults setValue:disclaimerAcknowledged forKey:@"disclaimerAcknowledged"];
        [defaults setValue:[dateFormatter stringFromDate:date] forKey:@"disclaimerAcknowledgedDate"];
    }
    
}

-(NSAttributedString*) attributedStringForText: (NSString*)string {
    
    UIColor *foregroundColour = [UIColor darkTextColor];
    
    NSMutableAttributedString *attrMutableString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", string]];
    
    NSRange range = [[attrMutableString string] rangeOfString:string];
    [attrMutableString addAttributes:@{NSForegroundColorAttributeName: foregroundColour, NSFontAttributeName:[UIFont systemFontOfSize:14.0]} range:range];
    
    return attrMutableString;
}

- (IBAction)goToLink:(id)sender {
    
    NSURL *url;
    
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *linkBtn = (UIButton*)sender;
        switch (linkBtn.tag) {
            case 0:
                url = [NSURL URLWithString:@"http://www.gmc-uk.org/guidance/ethical_guidance/making_audiovisual.asp"];
                break;
            case 1:
                url = [NSURL URLWithString:@"http://www.gmc-uk.org/guidance/ethical_guidance/consent_guidance_index.asp"];
                break;
            case 2:
                url = [NSURL URLWithString:@"http://www.gmc-uk.org/guidance/ethical_guidance/children_guidance_index.asp"];
                break;
            case 3:
                url = [NSURL URLWithString:@"http://www.gmc-uk.org/guidance/ethical_guidance/21186.asp"];
                break;
                
            default:
                break;
        }
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}


@end

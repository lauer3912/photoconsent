//
//  PMConsentViewController.m
//  Photoconsent
//
//  Created by Edward Wallitt on 27/02/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import "PMConsentViewController.h"
#import "PMFunctions.h"
#import <Parse/Parse.h>


@interface PMConsentViewController ()

@end

@implementation PMConsentViewController

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
    
   
    [_tblView setBackgroundColor:[UIColor clearColor]];
   
    [self.view setBackgroundColor:[UIColor clearColor]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBAction

- (IBAction)didPressCancelButton:(UIBarButtonItem *)sender {
    //important to end the activity
    [_activityConsent activityDidFinish:YES];
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        
        [(UIViewController*)segue.destinationViewController setTitle:[[(UITableViewCell*)sender textLabel] text]];
    }
    
}


#pragma mark - tableview delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:@"consentCell"];
    
    switch (indexPath.row) {
    
        case 0:
            [cell setUserInteractionEnabled:NO];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [cell.contentView addSubview:[self titleView]];
            break;
    
        case 2:
            [cell setUserInteractionEnabled:NO];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [cell.contentView addSubview:[self consentLabelView]];
            break;
    
    
        case 1:
            [cell setUserInteractionEnabled:NO];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [cell.contentView addSubview:[self photoAndSignatureView]];
            break;
            
        case 3:
            [cell.textLabel setText:@"Assessment"];
            if ([[_m_selectedPhoto valueForKey:@"Assessment"] boolValue]) {
                cell.userInteractionEnabled = YES;
                [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
                cell.imageView.image = [UIImage imageNamed:@"icon-check"];
            } else {
               [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell.textLabel setAlpha:0.25];
            }
            break;
        case 4:
            [cell.textLabel setText:@"Education"];
            if ([[_m_selectedPhoto valueForKey:@"Education"] boolValue]) {
                cell.userInteractionEnabled = YES;
                [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
                cell.imageView.image = [UIImage imageNamed:@"icon-check"];
            } else {
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                 [cell.textLabel setAlpha:0.25];
            }
            break;
        case 5:
            [cell.textLabel setText:@"Publication"];
            if ([[_m_selectedPhoto valueForKey:@"Publication"] boolValue]) {
                cell.userInteractionEnabled = YES;
                [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
                cell.imageView.image = [UIImage imageNamed:@"icon-check"];
            } else  {
                [cell setAccessoryType:UITableViewCellAccessoryNone];
               [cell.textLabel setAlpha:0.25];
            }
            break;
        
        case  6:
            [cell setUserInteractionEnabled:NO];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [cell.contentView addSubview:[self referenceView]];
            break;
        
        default:
            break;

    }
    return cell;
}

- (UIView*)photoAndSignatureView {
    
    UIView *photoAndSignatureView = [UIView new];
    __block NSString* dateString;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(135.0, 30.0, 126.0, 108.0)];
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 120.0, 140.0)];
    //imageView of photo
    
    if ([_m_selectedPhoto isKindOfClass:[PFObject class]]) {
        
        //get the image using Parse background block
        PFFile *theImage = [_m_selectedPhoto valueForKey:@"imageFile"];
        
        [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0UL);
            
            dispatch_async(queue, ^{
                UIImage *image = [UIImage imageWithData:data];
                image = resizeImage(image, iv.bounds.size);
                
                ////get the signature using Parse background block
                PFFile *signImage = [_m_selectedPhoto valueForKey:@"consentSignature"];
                [signImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    
                    dispatch_async(queue, ^{
                        
                        UIImage *signatureImage = [UIImage imageWithData:data];
                        resizeImage(signatureImage, imageView.bounds.size);
                        
                        
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            imageView.image = signatureImage;
                            
                        });
                        
                    });
                    
                }]; //end Parse getdata for signature
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    iv.image = image;
                });
                
            }); //end imagefile dispatch
            
            
        }]; //end Parse getdata for imageFile
        
        
        
    } else {
        NSData *theImage = [_m_selectedPhoto valueForKey:@"imageFile"];
        iv.image =  resizeImage([UIImage imageWithData:theImage],iv.bounds.size);
        
        NSData *signImage = [_m_selectedPhoto valueForKey:@"consentSignature"];
        imageView.image = resizeImage([UIImage imageWithData:signImage], imageView.bounds.size);
        
        
        
    }
    [photoAndSignatureView addSubview:iv];
    [photoAndSignatureView addSubview:imageView];
    
    // show the date created
    NSDate *createdAt = [_m_selectedPhoto valueForKey:@"createdAt"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    dateString = [formatter stringFromDate:createdAt];
    
    UILabel *stringLabel = [[UILabel alloc] initWithFrame:CGRectMake(140.0, 5.0, 130.0, 20.0)];
    [stringLabel setBackgroundColor:[UIColor clearColor]];
    [stringLabel setTextAlignment:NSTextAlignmentLeft];
    NSString *string = [NSString stringWithFormat:@"Signed %@", dateString];
    [stringLabel setAttributedText:[self attributedStringForText:string]];
    [photoAndSignatureView addSubview:stringLabel];
    
    return photoAndSignatureView;
    
    
}

- (UIView *)titleView {
    
    UIView *headerView = [UIView new];
    UILabel *stringLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 280.0, 64.0)];
    [stringLabel setTextAlignment:NSTextAlignmentCenter];
    [stringLabel setNumberOfLines:2];
    NSString *name = [NSString stringWithFormat:@"%@",[_m_selectedPhoto valueForKey:@"patientName"]];
    NSString *email = [NSString stringWithFormat:@"%@",[_m_selectedPhoto valueForKey:@"patientEmail"]];
    NSString *string = [NSString stringWithFormat:@"%@\n%@", name, email];
    NSAttributedString *attrString = [self attributedStringForText:string subString:email];
    [stringLabel setAttributedText:attrString];
    [headerView addSubview:stringLabel];
    return headerView;
}


- (UIView *)consentLabelView {
    
    UIView *headerView = [UIView new];
    UILabel *stringLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 4.0, 255.0, 20.0)];
    [stringLabel setBackgroundColor:[UIColor clearColor]];
    [stringLabel setTextAlignment:NSTextAlignmentLeft];
    [stringLabel setAttributedText:[self attributedStringForText:@"Consent to use for:"]];
                                    
    [headerView addSubview:stringLabel];
    
    return headerView;
}


- (UIView *)referenceView{
   
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0., 280., 50.0)];
    NSString *reference = [_m_selectedPhoto valueForKey:@"referenceID"]; 
    UILabel *stringLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0., 255., 50.0)];
    stringLabel.numberOfLines = 2;
    [stringLabel setTextAlignment:NSTextAlignmentLeft];
    [stringLabel setAttributedText:[self attributedStringForText:(NSString*)reference]];
    [footerView addSubview:stringLabel];
    return footerView;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 || indexPath.row == 6) {
      [cell setBackgroundColor:[UIColor lightGrayColor]];
    }

    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat rowHeight = 40.0;
    switch (indexPath.row) {
        case 0:
            rowHeight = 64.0;
            break;
        case 1:
            rowHeight = 140.0;
            break;
        case 2:
            rowHeight = 20.0;
            break;
        case 6:
            rowHeight = 50.0;
            break;
        default:
            rowHeight = 40.0;
            break;
    }
    
    return rowHeight;
}

#pragma mark - attributed string
-(NSAttributedString*) attributedStringForText: (NSString*)string {
    
    UIColor *foregroundColour = [UIColor darkTextColor];
    
    NSMutableAttributedString *attrMutableString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", string]];
    NSRange range = [[attrMutableString string] rangeOfString:string];
    [attrMutableString addAttributes:@{NSForegroundColorAttributeName: foregroundColour, NSFontAttributeName:[UIFont systemFontOfSize:14.0]} range:range];
    return attrMutableString;
}

-(NSAttributedString*) attributedStringForText: (NSString*)string subString:(NSString*)subString {
    
    NSMutableAttributedString *attrMutableString = [[NSMutableAttributedString alloc] initWithString:string];
    UIColor *foregroundColour1 = [UIColor darkTextColor];
    UIColor *foregroundColour2 = [UIColor blueColor];
    
    NSRange range = [[attrMutableString string] rangeOfString:string];
    [attrMutableString addAttributes:@{NSForegroundColorAttributeName: foregroundColour1, NSFontAttributeName:[UIFont systemFontOfSize:19.0], NSTextEffectAttributeName:NSTextEffectLetterpressStyle} range:range];
    
    
    
    
    NSURL *emailAddress = [NSURL URLWithString:[subString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    range = [[attrMutableString string] rangeOfString:subString];
    [attrMutableString addAttributes:@{NSForegroundColorAttributeName: foregroundColour2,NSFontAttributeName:[UIFont systemFontOfSize:14.0], NSLinkAttributeName:emailAddress} range:range];
    [attrMutableString removeAttribute:NSTextEffectAttributeName range:range];
    
    return attrMutableString;
}

    
@end

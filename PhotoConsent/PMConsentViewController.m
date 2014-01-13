//
//  PMConsentViewController.m
//  Photoconsent
//
//  Created by Edward Wallitt on 27/02/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import "PMConsentViewController.h"
#import "PMFunctions.h"
#import "PMPurposeViewController.h"


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
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IBAction

- (IBAction)didPressCancelButton:(UIBarButtonItem *)sender {
    //important to end the activity
    [_activityConsent activityDidFinish:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
- (IBAction)onExportMail:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
        composer.mailComposeDelegate = self;
        
        // setup the content for the email
        NSMutableString *emailBody = [NSMutableString stringWithFormat:@"<p><strong>Consent details for medical image taken with the Photoconsent app</strong></p>"];
        
        // add basic patient details
        NSString *patientName = [NSString stringWithFormat:@"<p><strong>Patient Name</strong>: %@</p>", [_m_selectedPhoto valueForKey:@"patientName"]];
        NSString *patientEmail = [NSString stringWithFormat:@"<p><strong>Patient Email</strong>: %@ <p>", [_m_selectedPhoto valueForKey:@"patientEmail"]];
        [emailBody appendString:patientName];
        [emailBody appendString:patientEmail];
        
        // create the content of the consent
        BOOL isAssessment = [[_m_selectedPhoto valueForKey:@"Assessment"] boolValue];
        BOOL isEducation = [[_m_selectedPhoto valueForKey:@"Education"] boolValue];
        BOOL isPublication = [[_m_selectedPhoto valueForKey:@"Publication"] boolValue];
        
        if (isAssessment) {
            NSString *assessment = [NSString stringWithFormat:@"<p>%@<p>", kText_Assessment];
            [emailBody appendString:assessment];
        }
        if (isEducation) {
            NSString *education = [NSString stringWithFormat:@"<p>%@</p>", kText_Education];
            [emailBody appendString:education];
        }
        if (isPublication) {
            NSString *publication = [NSString stringWithFormat:@"<p>%@</p>", kText_Publication];
            [emailBody appendString:publication];
        }

        // set the message body
        [composer setMessageBody:emailBody isHTML:YES];
        
        // add the signature
        PFFile *signImage = [_m_selectedPhoto valueForKey:@"consentSignature"];
        NSData *signatureData = [signImage getData];
        [composer addAttachmentData:signatureData mimeType:@"image/jpeg" fileName:@"consent_signature.jpg"];
        
        PFFile *theImage = [_m_selectedPhoto valueForKey:@"imageFile"];
        NSData *imageData;
        imageData = [theImage getData];
        [composer addAttachmentData:imageData mimeType:@"image/jpeg" fileName:@"medical_image.jpg"];
        
        [self presentViewController:composer animated:YES completion:nil];
    } else {
        UIAlertView *noMailAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry. This device cannot send mail" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [noMailAlert show];
    }

}
*/

#pragma mark - tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 )
        return  1;
    else
        return 3;
}

#pragma mark - tableview delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *dateString = @"  /  /    ";
    UITableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:@"consentCell"];
    if (indexPath.section == 0) {
        [cell setUserInteractionEnabled:NO];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(140.0, 40.0, 140.0, 65.0)];
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 115.0, 120.0)];
        //imageView of photo
        if ([_m_selectedPhoto isKindOfClass:[PFObject class]]) {
            PFFile *theImage = [_m_selectedPhoto valueForKey:@"imageFile"];
            iv.image =  resizeImage([UIImage imageWithData:[theImage getData]], iv.bounds.size);
            
            PFFile *signImage = [_m_selectedPhoto valueForKey:@"consentSignature"];
            NSData *imageData = [signImage getData];
            imageView.image = resizeImage([UIImage imageWithData:imageData], imageView.bounds.size);
            
            NSDate *created = [_m_selectedPhoto valueForKey:@"createdAt"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterShortStyle];
            dateString = [formatter stringFromDate:created];
            
           
            
        } else {
            NSData *theImage = [_m_selectedPhoto valueForKey:@"imageFile"];
            iv.image =  resizeImage([UIImage imageWithData:theImage],iv.bounds.size);
            
            NSData *signImage = [_m_selectedPhoto valueForKey:@"consentSignature"];
            imageView.image = resizeImage([UIImage imageWithData:signImage], imageView.bounds.size);
           
            // show the date created
            NSDate *created = [_m_selectedPhoto valueForKey:@"created"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterShortStyle];
            dateString = [formatter stringFromDate:created];
            
        }
        
        [cell.contentView addSubview:iv];
        [cell.contentView addSubview:imageView];
        
        UILabel *stringLabel = [[UILabel alloc] initWithFrame:CGRectMake(130.0, 10.0, 130.0, 20.0)];
        [stringLabel setBackgroundColor:[UIColor clearColor]];
        [stringLabel setTextAlignment:NSTextAlignmentLeft];
        NSString *string = [NSString stringWithFormat:@"Signed  %@", dateString];
        [stringLabel setAttributedText:[self attributedStringForText:string]];
        [cell.contentView addSubview:stringLabel];
        
        
    } else
        switch (indexPath.row) {
            case 0:
                [cell.textLabel setText:@"Assessment"];
                if ([[_m_selectedPhoto valueForKey:@"Assessment"] boolValue]) {
                    cell.userInteractionEnabled = YES;
                    [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
                }
                
                break;
            case 1:
                [cell.textLabel setText:@"Education"];
                if ([[_m_selectedPhoto valueForKey:@"Education"] boolValue]) {
                    cell.userInteractionEnabled = YES;
                    [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
                }
                break;
            case 2:
                [cell.textLabel setText:@"Publication"];
                if ([[_m_selectedPhoto valueForKey:@"Publication"] boolValue]) {
                    cell.userInteractionEnabled = YES;
                    [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
                }
                break;
            default:
                break;
        }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section == 1) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        UIViewController *avc = [storyboard instantiateViewControllerWithIdentifier:@"purposeViewController"];
        
        [avc setModalPresentationStyle:UIModalPresentationFullScreen];
        if ([avc isKindOfClass:[PMPurposeViewController class]]) {
            [(PMPurposeViewController*)avc setPurpose:indexPath.row];
            
            [self presentViewController:avc animated:YES completion:^{
                
            }];

            
        }
        
    }
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 4.0;
    } else
        return 40.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return 54.0;
    else
        return 22.0;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [UIView new];
    if (section == 0) {
       
        if (section == 0) {
            UILabel *stringLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 0.0, 240.0, 50.0)];
            [stringLabel setBackgroundColor:[UIColor clearColor]];
            [stringLabel setTextAlignment:NSTextAlignmentCenter];
            [stringLabel setNumberOfLines:2];
            NSString *name = [NSString stringWithFormat:@"%@",[_m_selectedPhoto valueForKey:@"patientName"]];
            NSString *email = [NSString stringWithFormat:@"%@",[_m_selectedPhoto valueForKey:@"patientEmail"]];
            NSString *string = [NSString stringWithFormat:@"%@\n%@", name, email];
            NSAttributedString *attrString = [self attributedStringForText:string];
            [stringLabel setAttributedText:attrString];
            [headerView addSubview:stringLabel];
        }
        
    } else {
        UILabel *stringLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 0.0, 240.0, 20.0)];
        [stringLabel setBackgroundColor:[UIColor clearColor]];
        [stringLabel setTextAlignment:NSTextAlignmentLeft];
        [stringLabel setAttributedText:[self attributedStringForText:@"Consent to use for:" subString:@"Consent to use for:"]];
                                        
        [headerView addSubview:stringLabel];
        
    }
    return headerView;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0., 320., 60.0)];
    
    
   if (section == 1) {
        NSString *reference = [_m_selectedPhoto valueForKey:@"referenceID"];
     
//       NSAssert(reference, @"ReferenceID cannot be nil");
     
        UILabel *stringLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 0., 260., 40.0)];
        [stringLabel setBackgroundColor:[UIColor clearColor]];
        [stringLabel setTextAlignment:NSTextAlignmentLeft];
        [stringLabel setAttributedText:[self attributedStringForText:(NSString*)reference]];
        [footerView addSubview:stringLabel];
       
    }
    
    return footerView;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 & indexPath.row == 0) {
        [cell setBackgroundColor:[UIColor lightGrayColor]];
    
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 & indexPath.row == 0 ) {
        return 120.0;
    } else
        return 44.0;
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
    UIColor *foregroundColour2 = self.view.tintColor;
    
    NSRange range = [[attrMutableString string] rangeOfString:string];
    [attrMutableString addAttributes:@{NSForegroundColorAttributeName: foregroundColour1, NSFontAttributeName:[UIFont systemFontOfSize:14.0]} range:range];
    
    
    range = [[attrMutableString string] rangeOfString:subString];
    [attrMutableString addAttributes:@{NSForegroundColorAttributeName: foregroundColour2,NSFontAttributeName:[UIFont systemFontOfSize:14.0]} range:range];
    
    return attrMutableString;
}

    
@end

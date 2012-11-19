//
//  VoicesViewController.m
//  Voices
//
//  Created by Peter Casinelli on 10/12/12.
//  Copyright (c) 2012 Peter Casinelli. All rights reserved.
//

#import "VoicesViewController.h"
#import "Location.h"
#import "Location+Helper.h"
#import <MapKit/MapKit.h>

@interface VoicesViewController ()

@end

@implementation VoicesViewController

/*@synthesize longitude = _longitude;
@synthesize latitude = _latitude;
@synthesize locationTitle = _locationTitle;*/
@synthesize voiceTitle = _voiceTitle;
@synthesize latitudeTextField = _latitudeTextField;
@synthesize longitudeTextField = _longitudeTextField;
@synthesize dataSource = _dataSource;

//Hide the keyboard when user touches on background
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (IBAction)addVoiceFromDataSource:(id)sender {
    
    NSString *title = [[NSString alloc] init];
    if (self.voiceTitle.text.length == 0)
    {
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
        [dateFormat setDateFormat:@"HH:mm:ss zzz"];
        NSString *dateString = [dateFormat stringFromDate:date];
        
        title = [NSString stringWithFormat:@"Voice at %@", dateString];
    } else {
        title = self.voiceTitle.text;
    }
    
    Location *newVoice = [self.dataSource addVoiceWithTitle:title];
    
    if (newVoice == nil)
    {
        NSLog(@"Error adding new voice");
    } else {
        NSLog(@"Added successfully");
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
- (IBAction)cancelButtonPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CLLocationCoordinate2D currentLocation = [self.dataSource getCurrentLocationCoordinates];

    self.latitudeTextField.text = [NSString stringWithFormat:@"%g", currentLocation.latitude];
    self.longitudeTextField.text = [NSString stringWithFormat:@"%g", currentLocation.longitude];
    
    [self.voiceTitle becomeFirstResponder];
    NSLog(@"viewDidLoad VVC");
}


@end

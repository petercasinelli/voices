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

@interface VoicesViewController ()

@end

@implementation VoicesViewController

@synthesize longitude = _longitude;
@synthesize latitude = _latitude;
@synthesize locationTitle = _locationTitle;
@synthesize dataSource = _dataSource;

//Hide the keyboard when user touches on background
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (IBAction)addLocation:(id)sender {
    NSLog(@"Pressed add location");
    
    [self.dataSource addLocationPressedWithTitle:self.locationTitle.text AndLatitude:[self.latitude.text doubleValue] andLongitude:[self.longitude.text doubleValue]];
}

@end

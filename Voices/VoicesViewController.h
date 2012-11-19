//
//  VoicesViewController.h
//  Voices
//
//  Created by Peter Casinelli on 10/12/12.
//  Copyright (c) 2012 Peter Casinelli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import <MapKit/MapKit.h>

@class VoicesViewController;

@protocol VoicesDataSource
/*- (IBAction)addLocationPressedWithTitle: (NSString *)title AndLatitude: (double) latitude andLongitude: (double) longitude;*/
-(Location *)addVoiceWithTitle:(NSString *)title;
-(CLLocationCoordinate2D) getCurrentLocationCoordinates;
@end

@interface VoicesViewController : UIViewController

/*@property (weak, nonatomic) IBOutlet UITextField *latitude;
@property (weak, nonatomic) IBOutlet UITextField *longitude;
@property (weak, nonatomic) IBOutlet UITextField *locationTitle;*/
@property (weak, nonatomic) IBOutlet UITextField *voiceTitle;
@property (weak, nonatomic) IBOutlet UILabel *latitudeTextField;
@property (weak, nonatomic) IBOutlet UILabel *longitudeTextField;

@property (nonatomic, weak) IBOutlet id <VoicesDataSource> dataSource;

@end

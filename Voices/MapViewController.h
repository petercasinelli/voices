//
//  MapViewController.h
//  Voices
//
//  Created by Peter Casinelli on 10/24/12.
//  Copyright (c) 2012 Peter Casinelli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>

@interface MapViewController : UIViewController <CLLocationManagerDelegate, AVAudioRecorderDelegate>

@property (nonatomic, strong) UIManagedDocument *locationsDatabase;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, strong) NSArray *locations;

@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;

@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *recordButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *stopButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playButton;



@property (nonatomic, strong) NSArray *annotations;


@end

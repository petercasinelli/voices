//
//  LocationsTableViewController.h
//  Voices
//
//  Created by Peter Casinelli on 10/12/12.
//  Copyright (c) 2012 Peter Casinelli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface LocationsTableViewController : CoreDataTableViewController

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@end

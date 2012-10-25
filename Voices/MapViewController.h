//
//  MapViewController.h
//  Voices
//
//  Created by Peter Casinelli on 10/24/12.
//  Copyright (c) 2012 Peter Casinelli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapViewController : UIViewController

@property (nonatomic, strong) UIManagedDocument *locationsDatabase;

@property (nonatomic, weak) NSArray *annotations;

@end

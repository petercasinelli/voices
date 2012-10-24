//
//  VoicesViewController.h
//  Voices
//
//  Created by Peter Casinelli on 10/12/12.
//  Copyright (c) 2012 Peter Casinelli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VoicesViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *latitude;
@property (weak, nonatomic) IBOutlet UITextField *longitude;
@property (weak, nonatomic) IBOutlet UITextField *locationTitle;

@property (nonatomic, strong) UIManagedDocument *locationsDatabase;

@end

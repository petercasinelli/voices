//
//  MapViewController.m
//  Voices
//
//  Created by Peter Casinelli on 10/24/12.
//  Copyright (c) 2012 Peter Casinelli. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // we'll segue to ANY view controller that has a photographer @property
    if ([segue.destinationViewController respondsToSelector:@selector(setupFetchedResultsControllerinManagedObjectContext:)]) {
        // use performSelector:withObject: to send without compiler checking
        // (which is acceptable here because we used introspection to be sure this is okay)
        NSLog(@"Seguing...");
        [segue.destinationViewController performSelector:@selector(setupFetchedResultsControllerinManagedObjectContext:) withObject:self.locationsDatabase.managedObjectContext];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

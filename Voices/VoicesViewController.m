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

@synthesize locationsDatabase = _locationsDatabase;

//Check different cases of document state
- (void) useDocument {
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.locationsDatabase.fileURL path]]) {
        // does not exist on disk, so create it
        [self.locationsDatabase saveToURL:self.locationsDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            //[self setupFetchedResultsController];
        }];
    } else if (self.locationsDatabase.documentState == UIDocumentStateClosed) {
        // exists on disk, but we need to open it
        [self.locationsDatabase openWithCompletionHandler:^(BOOL success) {
            //[self setupFetchedResultsController];
        }];
    } else if (self.locationsDatabase.documentState == UIDocumentStateNormal) {
        // already open and ready to use
        //[self setupFetchedResultsController];
    }
}

- (void) setLocationsDatabase:(UIManagedDocument *)locationsDatabase
{
    if (_locationsDatabase != locationsDatabase){
        _locationsDatabase = locationsDatabase;
        [self useDocument];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Create database if necessary; then set up fetch results controller
    if (!self.locationsDatabase){
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Default Locations Database"];
        self.locationsDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    
    
    
}

- (IBAction)addLocationPressed:(id)sender {

    double latitudeDouble = [self.latitude.text doubleValue];
    double longitudeDouble = [self.longitude.text doubleValue];
    
    NSDictionary *locationInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithDouble:latitudeDouble],  @"latitude",
                                  [NSNumber numberWithDouble:longitudeDouble], @"longitude",
                                  self.locationTitle.text, @"title", nil];
    
    [Location locationWithInfo:locationInfo
              inManagedObjectContext:self.locationsDatabase.managedObjectContext];
    
    NSLog(@"Add location was pressed and latitude is %@ and longitude is %@", self.latitude.text, self.longitude.text);

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

//Hide the keyboard when user touches on background
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

@end

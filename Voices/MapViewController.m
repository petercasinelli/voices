//
//  MapViewController.m
//  Voices
//
//  Created by Peter Casinelli on 10/24/12.
//  Copyright (c) 2012 Peter Casinelli. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "VoicesViewController.h"
#import "Location.h"

@interface MapViewController () <VoicesDataSource>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation MapViewController

@synthesize locationsDatabase = _locationsDatabase;
@synthesize annotations = _annotations;


-(void) updateMapView
{
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.annotations) [self.mapView addAnnotations:self.annotations];
}

- (void) setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}

-(void) setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
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
	// Do any additional setup after loading the view.
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

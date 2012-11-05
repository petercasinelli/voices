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
#import "Location+Helper.h"

#define METERS_PER_MILE 1609.344

@interface MapViewController () <VoicesDataSource, AVAudioRecorderDelegate, AVAudioPlayerDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation MapViewController

@synthesize locationsDatabase = _locationsDatabase;
@synthesize locationManager = _locationManager;

@synthesize latitude = _latitude;
@synthesize longitude = _longitude;

@synthesize audioRecorder = _audioRecorder;
@synthesize audioPlayer = _audioPlayer;

@synthesize recordButton = _recordButton;
@synthesize stopButton = _stopButton;

@synthesize annotations = _annotations;


#pragma mark - Map View

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

/*
-(void) setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
}
*/

#pragma mark - Location

- (CLLocationManager *)locationManager
{
    if (_locationManager != nil)
        return _locationManager;
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    
    return _locationManager;
  
}

- (IBAction)storeLocation:(id)sender {
    
    CLLocationCoordinate2D currentLocation = self.mapView.userLocation.coordinate;
    double latitude = currentLocation.latitude;
    double longitude = currentLocation.longitude;
    
    [self addLocationPressedWithTitle:@"Map Test" AndLatitude:latitude  andLongitude:longitude];
   NSLog(@"Adding location %g %g", latitude, longitude);

}

- (void)addLocationPressedWithTitle: (NSString *)title AndLatitude: (double) latitude andLongitude: (double) longitude {
 
 NSDictionary *locationInfo = [NSDictionary dictionaryWithObjectsAndKeys:
 [NSNumber numberWithDouble:latitude],  @"latitude",
 [NSNumber numberWithDouble:longitude], @"longitude",
 title, @"title", nil];
 
 [Location locationWithInfo:locationInfo
 inManagedObjectContext:self.locationsDatabase.managedObjectContext];
 
 NSLog(@"Add location was pressed and latitude is %g and longitude is %g", latitude, longitude);
 
 }

#pragma mark - LocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

    MKCoordinateRegion region;
    region.center = self.mapView.userLocation.coordinate;
    region.span = MKCoordinateSpanMake(2.0, 2.0);
    region = [self.mapView regionThatFits:region];
    [self.mapView setRegion:region animated:YES];
    
    //NSLog(@"NewLocation %@ %@", self.latitude, self.longitude);
}


#pragma mark - Core Data

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

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // we'll segue to ANY view controller that has a photographer @property
    if ([segue.destinationViewController respondsToSelector:@selector(setupFetchedResultsControllerinManagedObjectContext:)]) {
        // use performSelector:withObject: to send without compiler checking
        // (which is acceptable here because we used introspection to be sure this is okay)
        NSLog(@"Seguing...");
        [segue.destinationViewController performSelector:@selector(setupFetchedResultsControllerinManagedObjectContext:) withObject:self.locationsDatabase.managedObjectContext];
    } else if ([segue.identifier isEqualToString:@"Add Location Form"]) {
        NSLog(@"Setting the data source...");
        VoicesViewController *vvc = (VoicesViewController *)segue.destinationViewController;
        
            vvc.dataSource = self;
    }

}



#pragma mark - AVAudioRecorder

-(void) setupAudioSession
{
    
    NSError *setCategoryError = nil;
    [[AVAudioSession sharedInstance]
     setCategory: AVAudioSessionCategoryRecord
     error: &setCategoryError];
    
    if (setCategoryError) { /* handle the error condition */ }
    
    
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    self.recordButton.enabled = YES;
    self.stopButton.enabled = NO;
    self.playButton.enabled = YES;
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"Audio Recorder Decode Error occurred: %@", [error localizedDescription]);
    
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"Audio Player Decode Error occurred: %@", [error localizedDescription]);
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    self.recordButton.enabled = YES;
    self.stopButton.enabled = NO;
    self.playButton.enabled = YES;
}


#pragma mark -AVAudioSession

- (IBAction)recordButtonPressed:(id)sender {
    
    if (!self.audioRecorder.recording)
    {
        [self.audioRecorder record];
        self.playButton.enabled = NO;
        self.stopButton.enabled = YES;
        
    } else {
        
    }
}

- (IBAction)playButtonPressed:(id)sender {

    if (!self.audioRecorder.recording)
    {
        self.stopButton.enabled = YES;
        self.recordButton.enabled = NO;
        
        NSError *error;
        
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.audioRecorder.url error:&error];
        NSLog(@"AudioPlayer URL: %@", self.audioRecorder.url);
        self.audioPlayer.delegate = self;
        
        if (error)
        {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            [self.audioPlayer play];
        }
        
        
    }

}

- (IBAction)stopButtonPressed:(id)sender {
    
    self.stopButton.enabled = NO;
    self.playButton.enabled = YES;
    self.recordButton.enabled = YES;
    
    if (self.audioRecorder.recording){
        [self.audioRecorder stop];
    } else if (self.audioPlayer.playing) {
        [self.audioPlayer stop];
    }
}

//Get the bytes from temporary sound file
//Create record in database using bytes
- (IBAction)saveButtonPressed:(id)sender {

    NSURL *soundFileUrl = self.audioRecorder.url;
    //self.audioRecorder.url
    NSData* audioRecording = [NSData dataWithContentsOfURL:soundFileUrl];
    //NSData *audioRecording2 = [[NSData alloc] initWithContentsOfURL:soundFileUrl];
    CLLocationCoordinate2D currentLocation = self.mapView.userLocation.coordinate;
    double latitude = currentLocation.latitude;
    double longitude = currentLocation.longitude;
    
    NSString *title = [NSString stringWithFormat:@"Audio at %@", [NSDate date]];
    [self addLocationWithTitle:title AndLatitude:latitude andLongitude:longitude andAudio:audioRecording];
    
    //NSLog(@"%@", audioRecording);
    
}

- (void)addLocationWithTitle: (NSString *)title AndLatitude: (double) latitude andLongitude: (double) longitude andAudio: (NSData *)data
{

    
    //***** If I was using file system
    //Create file with file name that depends on time
    
    NSError *error;
    
    /* Create file manager
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Point to Document directory
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    //Get URL from documents directory
    NSURL *documentsUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    //Append recording file name
    NSString *newFileName = [NSString stringWithFormat:@"voice-%g.caf", [[NSDate date] timeIntervalSince1970]];
   
    NSURL *soundFileUrl = [documentsUrl URLByAppendingPathComponent:newFileName];
    
    NSURL *tempFilePath = [documentsUrl URLByAppendingPathComponent:@"recording.caf"];*/
    
    
    /*BOOL writeResult = [data writeToURL:soundFileUrl options:NSDataWritingAtomic error:&error];
    
    if (error)
    {
        NSLog(@"Error is: %@", [error localizedDescription]);
    } else {
        NSLog(@"Result was: %d", writeResult);
        NSLog(@"Documents directory: %@",
              [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
        
        
    }*/
    
    //[fileManager copyItemAtPath:resourcePath toPath:txtPath error:&error];
    //[fileManager copyItemAtURL:tempFilePath toURL:soundFileUrl error:&error];
    
     //NSLog(@"File name: %@", newFileName);
    
    //Insert into DB with file name as location
    NSDictionary *locationInfo = [NSDictionary  dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithDouble:latitude],  @"latitude",
                                  [NSNumber numberWithDouble:longitude], @"longitude",
                                  title, @"title",
                                  /*newFileName, @"fileName",*/ //If I was using file system
                                  data, @"audioRecording",
                                  nil];
    
    /*Location *newLocation = */[Location locationWithInfo:locationInfo
                                inManagedObjectContext:self.locationsDatabase.managedObjectContext];

     //NSLog(@"Object URI is: %@ and its name is %@ and add audio location was pressed and latitude is %@ and longitude is %@", newLocation.objectID.URIRepresentation, newLocation.fileName, newLocation.latitude, newLocation.longitude);
}


-(void) prepareAudioRecorder
{
    //Disable stop button since record button has not been pressed
    self.stopButton.enabled = NO;
    
    //Get URL from documents directory
    NSURL *soundFileUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    //Append recording file name
    soundFileUrl = [soundFileUrl URLByAppendingPathComponent:@"recording.caf"];
    
    NSDictionary *recordingSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInt:1],AVEncoderAudioQualityKey,
                                       [NSNumber numberWithInt:2],AVEncoderBitRateKey,
                                       [NSNumber numberWithInt:2],AVNumberOfChannelsKey,
                                       [NSNumber numberWithInt:2],AVSampleRateKey,
                                       nil];
     NSError *error = nil;
    
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:soundFileUrl settings:recordingSettings error:&error];
    
    if (error)
    {
        NSLog(@"Error is: %@", [error localizedDescription]);
    } else {
        //Prepare to record to make sure recording will be ready as soon as record button is pressed
        [self.audioRecorder prepareToRecord];
        NSLog(@"AVAudioRecorder setup");
    }
    

    
}

#pragma mark - MKMapViewDelegate
/*
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
        aView.canShowCallout = YES;
        aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        // could put a rightCalloutAccessoryView here
    }
    
    aView.annotation = annotation;
    [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];
    
    return aView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView
{
    UIImage *image = [self.delegate mapViewController:self imageForAnnotation:aView.annotation];
    [(UIImageView *)aView.leftCalloutAccessoryView setImage:image];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"callout accessory tapped for annotation %@", [view.annotation title]);
}*/


#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self prepareAudioRecorder];
    [self.locationManager startUpdatingLocation];
    
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

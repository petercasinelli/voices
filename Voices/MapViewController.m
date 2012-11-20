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
#import "VoicesAnnotation.h"

#define METERS_PER_MILE 1609.344

@interface MapViewController () <VoicesDataSource, AVAudioRecorderDelegate, AVAudioPlayerDelegate, MKMapViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSDictionary *lastSavedLocation;
@end

@implementation MapViewController

@synthesize locationsDatabase = _locationsDatabase;
@synthesize locationManager = _locationManager;
@synthesize locations = _locations;
@synthesize lastSavedLocation = _lastSavedLocation;
@synthesize annotations = _annotations;

@synthesize latitude = _latitude;
@synthesize longitude = _longitude;

@synthesize audioRecorder = _audioRecorder;
@synthesize audioPlayer = _audioPlayer;

@synthesize recordButton = _recordButton;
@synthesize stopButton = _stopButton;


#pragma mark - Map View

-(void) updateMapView
{
    NSLog(@"updateMapView");
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.annotations) [self.mapView addAnnotations:self.annotations];
}

- (void) setMapView:(MKMapView *)mapView
{
    NSLog(@"setMapView");
    _mapView = mapView;
    
    _mapView.delegate = self;
    
   // [self updateMapView];
    
}


#pragma mark - Annotations

-(void) setAnnotations:(NSArray *)annotations
{
    NSLog(@"setAnnotations");
    _annotations = annotations;
    [self updateMapView];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)annotationViews
{
    NSLog(@"Annotation was added!");
     for (MKAnnotationView *annView in annotationViews)
    {
        CGRect endFrame = annView.frame;
        annView.frame = CGRectOffset(endFrame, 0, -500);
        [UIView animateWithDuration:0.5
                         animations:^{ annView.frame = endFrame; }];
    }
}

#pragma mark - Location

//Get locations from core data
- (void) updateLocations
{
    NSLog(@"Update loc");
    NSManagedObjectContext *moc = self.locationsDatabase.managedObjectContext;
    //NSLog(@"Moc is %@", moc);
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:moc];
    
    CLLocationCoordinate2D currentLocation = [self getCurrentLocationCoordinates];
    double latitude = currentLocation.latitude;
    double longitude = currentLocation.longitude;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"latitude > %g AND latitude < %g AND longitude > %g AND longitude < %g", latitude-5, latitude+5, longitude-5, longitude+5];
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    
    //NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    
    
    NSError *error;
    NSArray *newLocations = [moc executeFetchRequest:request error:&error];
    NSLog(@"Array is %d", [newLocations count]);
    
    if (error){
        NSLog(@"Error");
    }
    if (newLocations == nil)
    {
        // Deal with error...
        NSLog(@"Nil");
    }
    
    NSMutableArray *voiceAnnotations = [[NSMutableArray alloc] initWithCapacity:[newLocations count]];
    for (Location *location in newLocations){
        NSDictionary *voiceDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                         location.title,@"title",
                                         location.latitude, @"latitude",
                                         location.longitude, @"longitude",
                                         location.audioRecording, @"audioRecording"//,
                                         //location.fileName, @"fileName"
                                         , nil];
        VoicesAnnotation *annotation = [VoicesAnnotation annotationForVoice:voiceDictionary];
        [voiceAnnotations addObject:annotation];
        
    }
    
    self.annotations = voiceAnnotations;

    
    
}

- (CLLocationManager *)locationManager
{
    if (_locationManager != nil)
        return _locationManager;
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    
    return _locationManager;
  
}

- (CLLocationCoordinate2D) getCurrentLocationCoordinates
{
    return self.mapView.userLocation.coordinate;
}
#pragma mark - Debug/Test Methods 
/*
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
    
    [self updateLocations];
 NSLog(@"Add location was pressed and latitude is %g and longitude is %g", latitude, longitude);
 
 }*/

-(Location *)addVoiceWithTitle:(NSString *)title
{
    NSURL *soundFileUrl = self.audioRecorder.url;
    NSData* audioRecording = [NSData dataWithContentsOfURL:soundFileUrl];
    
    CLLocationCoordinate2D currentLocation = [self getCurrentLocationCoordinates];
    double latitude = currentLocation.latitude;
    double longitude = currentLocation.longitude;
    
    NSDictionary *locationInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithDouble:latitude],  @"latitude",
                                  [NSNumber numberWithDouble:longitude], @"longitude",
                                  title, @"title",
                                  audioRecording, @"audioRecording",
                                  nil];
    
    Location *newVoice = [Location locationWithInfo:locationInfo
        inManagedObjectContext:self.locationsDatabase.managedObjectContext];
    
    return newVoice;
    
}

#pragma mark - LocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

  /*  NSLog(@"Latitudes: %g",fabs(newLocation.coordinate.latitude - oldLocation.coordinate.latitude));
    NSLog(@"Longitudes: %g",fabs(newLocation.coordinate.longitude - oldLocation.coordinate.longitude));*/

   if (fabs(newLocation.coordinate.latitude - oldLocation.coordinate.latitude) > 0.25 &&
        fabs(newLocation.coordinate.longitude - oldLocation.coordinate.longitude) > 0.25){
    MKCoordinateRegion mapRegion;
    mapRegion.center = newLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.5;
    mapRegion.span.longitudeDelta = 0.5;
    
    [self.mapView setRegion:mapRegion animated: YES];
    
    NSLog(@"New Location: %g %g   Old Location: %g %g", newLocation.coordinate.latitude, newLocation.coordinate.longitude, oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
    }
}

#pragma mark - UIAlertViewDelegate
/*
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
     NSLog(@"Button pressed at index %d", buttonIndex);
    NSLog(@"Entered: %@",[[alertView textFieldAtIndex:0] text]);
    //NSLog(@"Last saved location is %@",self.lastSavedLocation);
    
    //No Title so use default date title
    if (buttonIndex == 0){
        
        NSString *defaultTitle = @"Default title";
        NSMutableDictionary *locationWithTitle = [self.lastSavedLocation mutableCopy];
        [locationWithTitle setObject:defaultTitle forKey:@"title"];
        
        Location *newLocation = [Location locationWithInfo:locationWithTitle
                                    inManagedObjectContext:self.locationsDatabase.managedObjectContext];
        
        [self updateLocations];
        
        NSLog(@"Object URI is: %@ and its name is %@ and add audio location was pressed and latitude is %@ and longitude is %@", newLocation.objectID.URIRepresentation, newLocation.fileName, newLocation.latitude, newLocation.longitude);
        
    //Entered a title
    } else if (buttonIndex == 1){
   
        
        NSMutableDictionary *locationWithTitle = [self.lastSavedLocation mutableCopy];
        [locationWithTitle setObject:[[alertView textFieldAtIndex:0] text] forKey:@"title"];
        Location *newLocation = [Location locationWithInfo:locationWithTitle
                                        inManagedObjectContext:self.locationsDatabase.managedObjectContext];
        
        [self updateLocations];
        
        NSLog(@"Object URI is: %@ and its name is %@ and add audio location was pressed and latitude is %@ and longitude is %@", newLocation.objectID.URIRepresentation, newLocation.fileName, newLocation.latitude, newLocation.longitude);

    }
        
}
*/

#pragma mark - Core Data

//Check different cases of document state
- (void) useDocument {
    NSLog(@"Using document...");
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.locationsDatabase.fileURL path]]) {
        // does not exist on disk, so create it
        [self.locationsDatabase saveToURL:self.locationsDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            [self updateLocations];
        }];
    } else if (self.locationsDatabase.documentState == UIDocumentStateClosed) {
        // exists on disk, but we need to open it
        [self.locationsDatabase openWithCompletionHandler:^(BOOL success) {
            [self updateLocations];
        }];
    } else if (self.locationsDatabase.documentState == UIDocumentStateNormal) {
        // already open and ready to use
        //[self updateLocations];
    }
}

- (void) setLocationsDatabase:(UIManagedDocument *)locationsDatabase
{
    if (_locationsDatabase != locationsDatabase){
        _locationsDatabase = locationsDatabase;
        NSLog(@"Setting locations database...");
        [self useDocument];
    }
}

#pragma mark - Segue
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    //NSLog(@"Checking to see if file has been used");
    if ([identifier isEqualToString:@"Save Voice Button"])
    {
    double fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:[self.audioRecorder.url path] error:nil][NSFileSize] doubleValue];
    //NSLog(@"File size is %g",fileSize);
    if (!self.audioRecorder.recording && fileSize > 4096)
        return YES;
    else
        return NO;
    }
    
    //NSLog(@"Got to yes");
    //Default return YES
    return YES;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.destinationViewController respondsToSelector:@selector(setupFetchedResultsControllerinManagedObjectContext:)]) {
        // use performSelector:withObject: to send without compiler checking
        // (which is acceptable here because we used introspection to be sure this is okay)
        NSLog(@"Seguing...");
        [segue.destinationViewController performSelector:@selector(setupFetchedResultsControllerinManagedObjectContext:) withObject:self.locationsDatabase.managedObjectContext];
    } else if ([segue.identifier isEqualToString:@"Save Voice Button"]) {
        
        
        NSLog(@"Setting the data source...");
        //Save temporary data in case last recording is added
       /* NSURL *soundFileUrl = self.audioRecorder.url;
        NSData* audioRecording = [NSData dataWithContentsOfURL:soundFileUrl];
        
        CLLocationCoordinate2D coordinates = [self getCurrentLocationCoordinates];
        double latitude = coordinates.latitude;
        double longitude = coordinates.longitude;*/
        
       /* NSDictionary *locationInfo = [NSDictionary  dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithDouble:latitude],  @"latitude",
                                      [NSNumber numberWithDouble:longitude], @"longitude",
                                      /*newFileName, @"fileName",*/ //If I was using file system
                                      /*audioRecording, @"audioRecording",*/
                                     /* nil];
        self.lastSavedLocation = locationInfo;*/
        
        VoicesViewController *vvc = (VoicesViewController *)segue.destinationViewController;
        
        vvc.dataSource = self;
    }

}



#pragma mark - AVAudioRecorder

-(void) setupAudioSession
{
    
    NSError *setCategoryError = nil;
    [[AVAudioSession sharedInstance]
     setCategory: AVAudioSessionCategoryPlayAndRecord
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
    NSLog(@"Successful play");
    self.audioPlayer = nil;
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

    double fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:[self.audioRecorder.url path] error:nil][NSFileSize] doubleValue];
    //NSLog(@"File size is %g",fileSize);
    if (!self.audioRecorder.recording && fileSize > 4096)
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
            NSFileManager *mgr = [NSFileManager defaultManager];
            if ([mgr fileExistsAtPath:[self.audioRecorder.url path]])
            {
                
                NSLog(@"It exists so playing");
                [self.audioPlayer prepareToPlay];
                [self.audioPlayer play];
            }
            
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
/*
- (IBAction)saveButtonPressed:(id)sender {
    NSLog(@"Save button pressed");
    NSURL *soundFileUrl = self.audioRecorder.url;
    //self.audioRecorder.url
    NSData* audioRecording = [NSData dataWithContentsOfURL:soundFileUrl];
    //NSData *audioRecording2 = [[NSData alloc] initWithContentsOfURL:soundFileUrl];
    CLLocationCoordinate2D currentLocation = [self getCurrentLocationCoordinates];
    double latitude = currentLocation.latitude;
    double longitude = currentLocation.longitude;
    
    NSString *title = [NSString stringWithFormat:@"Audio at %@", [NSDate date]];
    [self addLocationWithTitle:title AndLatitude:latitude andLongitude:longitude andAudio:audioRecording];
    
    //NSLog(@"%@", audioRecording);
    
}
*/

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
    
    NSDictionary *locationInfo = [NSDictionary  dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithDouble:latitude],  @"latitude",
                                  [NSNumber numberWithDouble:longitude], @"longitude",
                                  /*newFileName, @"fileName",*/ //If I was using file system
                                  data, @"audioRecording",
                                  nil];
    self.lastSavedLocation = locationInfo;
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Save Your Voice" message:@"Enter a title for your Voice:" delegate:self cancelButtonTitle:@"No Title" otherButtonTitles:@"Save", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
    
    /*UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Save Your Voice" message:@"nnn" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    
    UITextField *voiceTitleTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 50.0, 260.0, 25.0)];
    [voiceTitleTextField setBackgroundColor:[UIColor whiteColor]];
    [voiceTitleTextField setPlaceholder:@"Enter your Voice title"];
    [voiceTitleTextField becomeFirstResponder];
    [alertView addSubview:voiceTitleTextField];
    
    [alertView show];*/
    

    

}


-(void) prepareAudioRecorder
{
    //Disable stop button since record button has not been pressed
    self.stopButton.enabled = NO;
    
    //Get URL from documents directory
    NSURL *soundFileUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    //Append recording file name
    soundFileUrl = [soundFileUrl URLByAppendingPathComponent:@"recording.ima4"];
    
    NSDictionary *recordingSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInt:kAudioFormatAppleIMA4],AVFormatIDKey,
                                       [NSNumber numberWithInt:32000.0],AVSampleRateKey,
                                       [NSNumber numberWithInt: 1],AVNumberOfChannelsKey,
                                       [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
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

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        //Don't trample the user location annotation (pulsing blue dot).
        return nil;
    }
    
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
        aView.canShowCallout = YES;
        
        //aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        UIImage *playButtonImage = [UIImage imageNamed:@"playButton.png"];
        
        UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        playButton.frame = CGRectMake(40, 5, 29.0, 29.0);
        [playButton setBackgroundImage:playButtonImage forState:UIControlStateNormal];
        //[playButton addTarget:self action:@selector(playButtonPressed:withEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        //aView.rightCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playButton.png"]];
        aView.rightCalloutAccessoryView = playButton;
        // could put a rightCalloutAccessoryView here
    }
    
    
    aView.annotation = annotation;
    
    //[(UIImageView *)aView.leftCalloutAccessoryView setImage:[UIImage imageNamed:@"playButton.png"]];
    
    
    return aView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView
{
    /*UIImage *image = [self.delegate mapViewController:self imageForAnnotation:aView.annotation];
    [(UIImageView *)aView.leftCalloutAccessoryView setImage:image];*/
    NSLog(@"didSelectAnnotationView");
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    VoicesAnnotation *voicesAnnotation = (VoicesAnnotation *)view.annotation;
    NSLog(@"callout accessory tapped for annotation %@", [view.annotation title]);
    //NSLog(@"Audio data: %@", [VoicesAnnotation audioRecordingForVoice:voicesAnnotation.voice]);
    if (!self.audioPlayer.playing)
    {
        NSLog(@"Prepping");
        self.audioPlayer = nil;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:[VoicesAnnotation audioRecordingForVoice:voicesAnnotation.voice] error:nil];
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
        
        /*UIImage *pauseButtonImage = [UIImage imageNamed:@"pauseButton.png"];
    
        UIButton *pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        pauseButton.frame = CGRectMake(40, 5, 29.0, 29.0);
        [pauseButton setBackgroundImage:pauseButtonImage forState:UIControlStateNormal];

        view.rightCalloutAccessoryView = pauseButton;*/
    }
    
}


#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
        
    [self prepareAudioRecorder];
    [self.locationManager startUpdatingLocation];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"viewWillAppear");
    //Create database if necessary; then set up fetch results controller
    if (!self.locationsDatabase){
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Default Locations Database"];
        self.locationsDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
        //NSLog(@"Context is %@", self.locationsDatabase.managedObjectContext);
    }
    
    
    [self updateLocations];

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

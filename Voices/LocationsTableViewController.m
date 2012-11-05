//
//  LocationsTableViewController.m
//  Voices
//
//  Created by Peter Casinelli on 10/12/12.
//  Copyright (c) 2012 Peter Casinelli. All rights reserved.
//

#import "LocationsTableViewController.h"
#import "Location+Helper.h"
#import "Location.h"

@interface LocationsTableViewController () <UITableViewDelegate, AVAudioPlayerDelegate>

@end

@implementation LocationsTableViewController

//@synthesize locationsDatabase = _locationsDatabase;
@synthesize audioPlayer = _audioPlayer;

//Necessary to be a sublcass of CoreDataViewController (done so in the header)

- (void)setupFetchedResultsControllerinManagedObjectContext:(NSManagedObjectContext *)context // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    // no predicate because we want ALL the Photographers
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:context
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}


//Set up each cell's data
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Location Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Location *location = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = location.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ , %@",location.latitude, location.longitude];
    
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [playButton setTitle:@"Play" forState:UIControlStateNormal];
    [playButton setFrame:CGRectMake(0, 0, 60, 35)];
    playButton.userInteractionEnabled = YES;
    [playButton addTarget:self action:@selector(playButtonPressed:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.accessoryView = playButton;
    
    return cell;
}

-(void) playButtonPressed: (UIControl *)button withEvent: (UIEvent *) event
{
    //NSLog(@"play button pressed...");
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.tableView]];
    if ( indexPath == nil )
        return;
    
    [self.tableView.delegate tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
    
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
    //NSLog(@"Button pressed at %@", indexPath);
    
    Location *location = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Create file manager
   // NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    // Point to Document directory
    /*NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];*/
    //Get URL from documents directory
    NSURL *soundFileUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
   
    //If I was using file system
    //Append recording file name
    //NSString *newFileName = [NSString stringWithFormat:@"voice-%@.caf", location.fileName];
    
    //If I was using file system
    //soundFileUrl = [soundFileUrl URLByAppendingPathComponent:location.fileName];
    
    soundFileUrl = [soundFileUrl URLByAppendingPathComponent:@"recording.caf"];
    NSLog(@"File name: %@", soundFileUrl);
    
    NSError *error1;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:location.audioRecording error:&error1];
    
    //If I was using file system
    //self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileUrl error:&error1];
    
    self.audioPlayer.delegate = self;
    
    if (error1){
        NSLog(@"Player error: %@", [error1 localizedDescription]);
    } else {
        [self.audioPlayer play];
        NSLog(@"Playing...");
        
    }
    
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"Audio Player Decode Error occurred: %@", [error localizedDescription]);
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"DONE");
}

@end

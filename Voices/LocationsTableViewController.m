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

@interface LocationsTableViewController ()

@end

@implementation LocationsTableViewController

//@synthesize locationsDatabase = _locationsDatabase;


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
    
    return cell;
}

@end

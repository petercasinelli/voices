//
//  Location+Helper.m
//  Voices
//
//  Created by Peter Casinelli on 10/12/12.
//  Copyright (c) 2012 Peter Casinelli. All rights reserved.
//

#import "Location+Helper.h"

@implementation Location (Helper)

+ (Location *) locationWithInfo:(NSDictionary *)locationInfo
                inManagedObjectContext:(NSManagedObjectContext *)context
{
    Location *location = nil;
    
    location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:context];
    
    location.latitude = [locationInfo objectForKey:@"latitude"];
    location.longitude = [locationInfo objectForKey:@"longitude"];
    location.title = [locationInfo objectForKey:@"title"];
    
    return location;
}

@end

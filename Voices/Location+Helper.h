//
//  Location+Helper.h
//  Voices
//
//  Created by Peter Casinelli on 10/12/12.
//  Copyright (c) 2012 Peter Casinelli. All rights reserved.
//

#import "Location.h"

@interface Location (Helper)

+ (Location *) locationWithInfo:(NSDictionary *)locationInfo
         inManagedObjectContext:(NSManagedObjectContext *)context;
@end

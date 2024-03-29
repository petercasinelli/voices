//
//  Location.h
//  Voices
//
//  Created by Peter Casinelli on 11/4/12.
//  Copyright (c) 2012 Peter Casinelli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Location : NSManagedObject

@property (nonatomic, retain) NSData * audioRecording;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * title;

@end

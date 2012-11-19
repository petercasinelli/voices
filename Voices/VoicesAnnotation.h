//
//  VoicesAnnotation.h
//  Voices
//
//  Created by Peter Casinelli on 11/4/12.
//  Copyright (c) 2012 Peter Casinelli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface VoicesAnnotation : NSObject <MKAnnotation>

+ (VoicesAnnotation *) annotationForVoice:(NSDictionary *)voice; //Voice dictionary
+ (NSData *)audioRecordingForVoice:(NSDictionary *)voice;

@property (nonatomic, strong) NSDictionary *voice;

@end

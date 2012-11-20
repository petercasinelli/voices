//
//  VoicesAnnotation.m
//  Voices
//
//  Created by Peter Casinelli on 11/4/12.
//  Copyright (c) 2012 Peter Casinelli. All rights reserved.
//

#import "VoicesAnnotation.h"

@implementation VoicesAnnotation

@synthesize voice = _voice;

+ (VoicesAnnotation *) annotationForVoice:(NSDictionary *)voice
{
    VoicesAnnotation *annotation = [[VoicesAnnotation alloc] init];
    annotation.voice = voice;
    return annotation;
}
+ (NSData *)audioRecordingForVoice:(NSDictionary *)voice
{
    return [voice objectForKey:@"audioRecording"];
}

- (NSString *)title
{
    return [self.voice objectForKey:@"title"];
}

- (NSString *)subtitle {
    
    NSString *latitude = [NSString stringWithFormat:@"%@",[self.voice objectForKey:@"latitude"]];
    NSString *longitude = [NSString stringWithFormat:@"%@", [self.voice objectForKey:@"longitude"]];
    
    NSString *subtitle = [[NSString alloc] initWithFormat:@"%@, %@", [latitude substringToIndex:7],[longitude substringToIndex:8]];
                          
    return subtitle;
}

- (NSData *)audioRecording
{
    return [self.voice objectForKey:@"audioRecording"];
}

-(CLLocationCoordinate2D) coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.voice objectForKey:@"latitude"] doubleValue];
    coordinate.longitude = [[self.voice objectForKey:@"longitude"] doubleValue];
    
    return coordinate;
}

@end

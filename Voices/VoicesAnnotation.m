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

- (NSString *)title
{
    return [self.voice objectForKey:@"title"];
}

- (NSString *)subtitle {
    
    NSString *subtitle = [[NSString alloc] initWithFormat:@"%@, %@", [self.voice objectForKey:@"latitude"], [self.voice objectForKey:@"longitude"]];
    return subtitle;
}

-(CLLocationCoordinate2D) coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.voice objectForKey:@"latitude"] doubleValue];
    coordinate.longitude = [[self.voice objectForKey:@"longitude"] doubleValue];
    
    return coordinate;
}

@end

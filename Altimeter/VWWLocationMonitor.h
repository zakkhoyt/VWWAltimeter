//
//  VWWLocationMonitor.h
//  Altimeter
//
//  Created by Zakk Hoyt on 10/1/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;
#import "VWWLocation.h"





static NSString *VWWLocationMonitorUpdated = @"VWWLocationMonitorUpdated";
@interface VWWLocationMonitor : NSObject

+(VWWLocationMonitor*)sharedInstance;
-(void)start;
-(void)stop;
-(void)reset;
-(NSString*)jsonRepresentation;

@property (nonatomic, strong, readonly) NSMutableArray *session;

@property (nonatomic, strong, readonly) NSString *absoluteAltitudeString;
@property (nonatomic, strong, readonly) NSString *minAbsoluteAltitudeString;
@property (nonatomic, strong, readonly) NSString *maxAbsoluteAltitudeString;
@property (nonatomic, readonly) float minAbsoluteAltitude;
@property (nonatomic, readonly) float maxAbsoluteAltitude;

@property (nonatomic, strong, readonly) NSString *relativeAltitudeString;
@property (nonatomic, strong, readonly) NSString *minRelativeAltitudeString;
@property (nonatomic, strong, readonly) NSString *maxRelativeAltitudeString;
@property (nonatomic, readonly) float minRelativeAltitude;
@property (nonatomic, readonly) float maxRelativeAltitude;


@property (nonatomic, strong, readonly) NSString *speedString;
@property (nonatomic, strong, readonly) NSString *minSpeedString;
@property (nonatomic, strong, readonly) NSString *maxSpeedString;
@property (nonatomic, readonly) float minSpeed;
@property (nonatomic, readonly) float maxSpeed;






@end

//
//  VWWMotionMonitor.h
//  Altimeter
//
//  Created by Zakk Hoyt on 9/30/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *VWWMotionMonitorUpdated = @"VWWMotionMonitorUpdated";
static NSString *VWWMotionMonitorActivityUpdated = @"VWWMotionMonitorActivityUpdated";
static NSString *VWWMotionMonitorPedometerUpdated = @"VWWMotionMonitorPedometerUpdated";

@interface VWWMotionMonitor : NSObject
+(VWWMotionMonitor*)sharedInstance;
-(void)start;
-(void)stop;
-(void)reset;
-(NSString*)jsonRepresentation;
@property (nonatomic, strong, readonly) NSMutableArray *session;


@property (nonatomic, strong, readonly) NSString *altitudeString;
@property (nonatomic, strong, readonly) NSString *minAltitudeString;
@property (nonatomic, strong, readonly) NSString *maxAltitudeString;
@property (nonatomic, readonly) float minAltitude;
@property (nonatomic, readonly) float maxAltitude;

@property (nonatomic, strong, readonly) NSString *pressureString;
@property (nonatomic, strong, readonly) NSString *minPressureString;
@property (nonatomic, strong, readonly) NSString *maxPressureString;
@property (nonatomic, readonly) float minPressure;
@property (nonatomic, readonly) float maxPressure;

@property (nonatomic, strong, readonly) NSString *activityString;
@property (nonatomic, strong, readonly) NSString *activityConfidenceString;

@property (nonatomic, strong, readonly) NSString *stepsString;
@property (nonatomic, strong, readonly) NSString *floorsAscendedString;
@property (nonatomic, strong, readonly) NSString *floorsDescendedString;


@end

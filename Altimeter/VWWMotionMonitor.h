//
//  VWWMotionMonitor.h
//  Altimeter
//
//  Created by Zakk Hoyt on 9/30/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *VWWMotionMonitorUpdated = @"VWWMotionMonitorUpdated";
@interface VWWMotionMonitor : NSObject
+(VWWMotionMonitor*)sharedInstance;
-(void)start;
-(void)stop;
-(void)reset;
-(NSString*)jsonRepresentation;
@property (nonatomic, strong, readonly) NSMutableArray *session;
@property (nonatomic, strong, readonly) NSString *altitudeString;
@property (nonatomic, strong, readonly) NSString *pressureString;
@property (nonatomic, strong, readonly) NSString *minPressureString;
@property (nonatomic, strong, readonly) NSString *maxPressureString;
@property (nonatomic, strong, readonly) NSString *minAltitudeString;
@property (nonatomic, strong, readonly) NSString *maxAltitudeString;
@property (nonatomic, readonly) float minAltitude;
@property (nonatomic, readonly) float maxAltitude;
@property (nonatomic, readonly) float minPressure;
@property (nonatomic, readonly) float maxPressure;

@end

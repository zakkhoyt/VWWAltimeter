//
//  VWWLocationMonitor.h
//  Altimeter
//
//  Created by Zakk Hoyt on 10/1/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

static NSString *VWWLocationMonitorUpdated = @"VWWLocationMonitorUpdated";
@interface VWWLocationMonitor : NSObject
@property (nonatomic, strong, readonly) CLLocation *location;

@property (nonatomic, strong, readonly) NSString *altitudeString;
@property (nonatomic, strong, readonly) NSString *minAltitudeString;
@property (nonatomic, strong, readonly) NSString *maxAltitudeString;
@property (nonatomic, readonly) float minAltitude;
@property (nonatomic, readonly) float maxAltitude;

@property (nonatomic, strong, readonly) NSString *speedString;
@property (nonatomic, strong, readonly) NSString *minSpeedString;
@property (nonatomic, strong, readonly) NSString *maxSpeedString;
@property (nonatomic, readonly) float minSpeed;
@property (nonatomic, readonly) float maxSpeed;




+(VWWLocationMonitor*)sharedInstance;
-(void)start;
-(void)stop;
-(void)reset;


@end

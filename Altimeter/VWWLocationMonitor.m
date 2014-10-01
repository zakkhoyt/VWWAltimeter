//
//  VWWLocationMonitor.m
//  Altimeter
//
//  Created by Zakk Hoyt on 10/1/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWLocationMonitor.h"
#import "VWWUserDefaults.h"

@interface VWWLocationMonitor () <CLLocationManagerDelegate>
@property (nonatomic, strong, readwrite) CLLocation *location;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) NSNumber *baseAltitude;
@property (nonatomic, strong, readwrite) NSString *altitudeString;
@property (nonatomic, strong, readwrite) NSString *minAltitudeString;
@property (nonatomic, strong, readwrite) NSString *maxAltitudeString;
@property (nonatomic, readwrite) float minAltitude;
@property (nonatomic, readwrite) float maxAltitude;

@property (nonatomic, strong, readwrite) NSString *speedString;
@property (nonatomic, strong, readwrite) NSString *minSpeedString;
@property (nonatomic, strong, readwrite) NSString *maxSpeedString;
@property (nonatomic, readwrite) float minSpeed;
@property (nonatomic, readwrite) float maxSpeed;

@end

@implementation VWWLocationMonitor


+(VWWLocationMonitor*)sharedInstance{
    static VWWLocationMonitor *instance;
    if(instance == nil){
        instance = [[VWWLocationMonitor alloc]init];
    }
    return instance;
}

-(instancetype)init{
    self = [super init];
    if(self){
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = self;
        
    }
    return self;
}


-(void)start{
    [_locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    self.location = [self.locationManager location];

}
-(void)stop{
    [self.locationManager stopUpdatingHeading];
    [self.locationManager stopUpdatingLocation];
}

-(void)reset{
    [self stop];
    self.location = nil;
    self.baseAltitude = nil;
}



#pragma mark CLLocationManagerDelegate


/*
 *  locationManager:didUpdateLocations:
 *
 *  Discussion:
 *    Invoked when new locations are available.  Required for delivery of
 *    deferred locations.  If implemented, updates will
 *    not be delivered to locationManager:didUpdateToLocation:fromLocation:
 *
 *    locations is an array of CLLocation objects in chronological order.
 */
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations{
    CLLocation *location = locations[0];
    self.location = location;
    
//    NSLog(@"location.verticalAccuracy: %.2f", location.verticalAccuracy);
    
    if(self.baseAltitude == nil){
        self.baseAltitude = @(location.altitude);
    }
    
    float relativeAltitude = location.altitude - self.baseAltitude.floatValue;
    
    self.minAltitude = MIN(self.minAltitude, relativeAltitude);
    self.maxAltitude = MAX(self.maxAltitude, relativeAltitude);

    const float kAltitudeFactor = 3.28084;
    float altitude = [VWWUserDefaults altitudeUnits] == 0 ? relativeAltitude : relativeAltitude * kAltitudeFactor;
    NSString *altitudeUnitsString = [VWWUserDefaults altitudeUnits] == 0 ? @"m" : @"f";

    
    self.altitudeString = [NSString stringWithFormat:@"△ Altitude\n%@%.2f%@",
                           altitude > 0 ? @"⬆︎" : @"⬇︎",
                           fabs(altitude),
                           altitudeUnitsString];
    self.minAltitudeString = [NSString stringWithFormat:@"%.2f%@", self.minAltitude, altitudeUnitsString];
    self.maxAltitudeString = [NSString stringWithFormat:@"%.2f%@", self.maxAltitude, altitudeUnitsString];

    
    
    self.minSpeed = MIN(self.minSpeed, location.speed);
    self.maxSpeed = MAX(self.maxSpeed, location.speed);
    
    const float kSpeedFPSFactor = 3.281;
    const float kSpeedMilesPerHourFactor = 2.237;
    const float kSpeedKilometersPerHourFactor = 3.6;
    NSString *speedUnitsString = nil;
    float speed = 0;
    switch ([VWWUserDefaults speedUnits]) {
        case 0:
            speed = location.speed;
            speedUnitsString = @"mps";
            break;
        case 1:
            speed = location.speed * kSpeedFPSFactor;
            speedUnitsString = @"fps";
            break;
        case 2:
            speed = location.speed * kSpeedMilesPerHourFactor;
            speedUnitsString = @"mph";
            break;
        case 3:
            speed = location.speed * kSpeedKilometersPerHourFactor;
            speedUnitsString = @"kmph";
            break;
        default:
            break;
    }
    
    
    
    self.speedString = [NSString stringWithFormat:@"Speed\n%.2f%@",
                           fabs(speed),
                           speedUnitsString];
    self.minSpeedString = [NSString stringWithFormat:@"%.2f%@", self.minSpeed, speedUnitsString];
    self.maxSpeedString = [NSString stringWithFormat:@"%.2f%@", self.maxSpeed, speedUnitsString];

    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VWWLocationMonitorUpdated object:nil];
}


/*
 *  locationManagerShouldDisplayHeadingCalibration:
 *
 *  Discussion:
 *    Invoked when a new heading is available. Return YES to display heading calibration info. The display
 *    will remain until heading is calibrated, unless dismissed early via dismissHeadingCalibrationDisplay.
 */
- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager{
    return NO;
}

/*
 *  locationManager:didFailWithError:
 *
 *  Discussion:
 *    Invoked when an error has occurred. Error types are defined in "CLError.h".
 */
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    NSLog(@"Error: %@", error.localizedDescription);
}

/*
 *  locationManager:didChangeAuthorizationStatus:
 *
 *  Discussion:
 *    Invoked when the authorization status changes for this application.
 */
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    NSLog(@"CoreLocation status changed to %ld", (long)status);
}

@end

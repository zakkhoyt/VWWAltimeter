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
@property (nonatomic, strong, readwrite) NSString *absoluteAltitudeString;
@property (nonatomic, strong, readwrite) NSString *minAbsoluteAltitudeString;
@property (nonatomic, strong, readwrite) NSString *maxAbsoluteAltitudeString;
@property (nonatomic, readwrite) float minAbsoluteAltitude;
@property (nonatomic, readwrite) float maxAbsoluteAltitude;

@property (nonatomic, strong, readwrite) NSString *relativeAltitudeString;
@property (nonatomic, strong, readwrite) NSString *minRelativeAltitudeString;
@property (nonatomic, strong, readwrite) NSString *maxRelativeAltitudeString;
@property (nonatomic, readwrite) float minRelativeAltitude;
@property (nonatomic, readwrite) float maxRelativeAltitude;


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
        _session = [@[]mutableCopy];
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

-(NSString*)jsonRepresentation{
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:self.session.count];
    for(VWWLocation *data in self.session){
        NSDictionary *dictionary = @{@"relativeAltitude" : @(data.relativeAltitude),
                                     @"absoluteAltitude" : @(data.absoluteAltitude),
                                     @"speed" : @(data.speed)};
        [array addObject:dictionary];
    }
    
    NSString *json = [self jsonRepresentationOfArray:array prettyPrint:YES];
    return json;
}

-(NSString*)jsonRepresentationOfArray:(NSArray*)array prettyPrint:(BOOL)prettyPrint{
    if([NSJSONSerialization isValidJSONObject:array] == NO){
        NSLog(@"Cannot convert object to json");
        return nil;
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    if (! jsonData) {
        NSLog(@"%@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
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
    
//    [self.session addObject:location];
    
//    NSLog(@"location.verticalAccuracy: %.2f", location.verticalAccuracy);
    

    // ****************************** ABSOLUTE ALTITUDE
    self.minAbsoluteAltitude = MIN(self.minAbsoluteAltitude, location.altitude);
    self.maxAbsoluteAltitude = MAX(self.maxAbsoluteAltitude, location.altitude);

    const float kAltitudeFactor = 3.28084;
    float absoluteAltitude = [VWWUserDefaults altitudeUnits] == 0 ? location.altitude : location.altitude * kAltitudeFactor;
    NSString *altitudeUnitsString = [VWWUserDefaults altitudeUnits] == 0 ? @"m" : @"f";

    
    self.absoluteAltitudeString = [NSString stringWithFormat:@"△ Altitude\n%@%.2f%@",
                           absoluteAltitude > 0 ? @"⬆︎" : @"⬇︎",
                           fabs(absoluteAltitude),
                           altitudeUnitsString];
    self.minAbsoluteAltitudeString = [NSString stringWithFormat:@"%.2f%@", self.minAbsoluteAltitude, altitudeUnitsString];
    self.maxAbsoluteAltitudeString = [NSString stringWithFormat:@"%.2f%@", self.maxAbsoluteAltitude, altitudeUnitsString];

    

    // ****************************** RELATIVE ALTITUDE
    if(self.baseAltitude == nil){
        self.baseAltitude = @(location.altitude);
    }
    
    float adjustedAltitude = location.altitude - self.baseAltitude.floatValue;
    self.minRelativeAltitude = MIN(self.minRelativeAltitude, adjustedAltitude);
    self.maxRelativeAltitude = MAX(self.maxRelativeAltitude, adjustedAltitude);
    
    const float kRelativeAltitudeFactor = 3.28084;
    float relativeAltitude = [VWWUserDefaults altitudeUnits] == 0 ? adjustedAltitude : adjustedAltitude * kRelativeAltitudeFactor;
    NSString *relativeAltitudeUnitsString = [VWWUserDefaults altitudeUnits] == 0 ? @"m" : @"f";
    
    
    self.relativeAltitudeString = [NSString stringWithFormat:@"△ Altitude\n%@%.2f%@",
                                   relativeAltitude > 0 ? @"⬆︎" : @"⬇︎",
                                   fabs(relativeAltitude),
                                   relativeAltitudeUnitsString];
    self.minRelativeAltitudeString = [NSString stringWithFormat:@"%.2f%@", self.minRelativeAltitude, relativeAltitudeUnitsString];
    self.maxRelativeAltitudeString = [NSString stringWithFormat:@"%.2f%@", self.maxRelativeAltitude, relativeAltitudeUnitsString];
    
    
    
    
    
    // ****************************** SPEED
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

    
    
    // ****************************** Min/Max
    self.minAbsoluteAltitude = MIN(self.minAbsoluteAltitude, location.altitude);
    self.maxAbsoluteAltitude = MAX(self.maxAbsoluteAltitude, location.altitude);
    self.minRelativeAltitude = MIN(self.minRelativeAltitude, relativeAltitude);
    self.maxRelativeAltitude = MAX(self.maxRelativeAltitude, relativeAltitude);
    self.minSpeed = MIN(self.minSpeed, location.speed);
    self.maxSpeed = MAX(self.maxSpeed, location.speed);

    NSLog(@"minAbsoluteAltitude: %.2f", self.minAbsoluteAltitude);
    NSLog(@"maxAbsoluteAltitude: %.2f", self.maxAbsoluteAltitude);
    NSLog(@"minRelativeAltitude: %.2f", self.minRelativeAltitude);
    NSLog(@"maxRelativeAltitude: %.2f", self.maxRelativeAltitude);
    NSLog(@"minSpeed: %.2f", self.minSpeed);
    NSLog(@"maxSpeed: %.2f", self.maxSpeed);

    
    
    
    
    // ****************************** Store for plotting
    VWWLocation *data = [[VWWLocation alloc]init];
    data.relativeAltitude = adjustedAltitude;
    data.absoluteAltitude = location.altitude;
    data.speed = speed;
    [self.session addObject:data];
    
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

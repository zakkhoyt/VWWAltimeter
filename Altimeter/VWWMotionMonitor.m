//
//  VWWMotionMonitor.m
//  Altimeter
//
//  Created by Zakk Hoyt on 9/30/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWMotionMonitor.h"
@import CoreMotion;
#import "VWWUserDefaults.h"

@interface VWWMotionMonitor ()
@property (nonatomic, strong) CMAltimeter *altimeterManager;
@property (nonatomic, strong, readwrite) NSMutableArray *session;
@property (nonatomic, strong, readwrite) NSString *altitudeString;
@property (nonatomic, strong, readwrite) NSString *pressureString;
@property (nonatomic, strong, readwrite) NSString *minPressureString;
@property (nonatomic, strong, readwrite) NSString *maxPressureString;
@property (nonatomic, strong, readwrite) NSString *minAltitudeString;
@property (nonatomic, strong, readwrite) NSString *maxAltitudeString;

@property (nonatomic, readwrite) float minAltitude;
@property (nonatomic, readwrite) float maxAltitude;
@property (nonatomic, readwrite) float minPressure;
@property (nonatomic, readwrite) float maxPressure;

@end

@implementation VWWMotionMonitor

+(VWWMotionMonitor*)sharedInstance{
    static VWWMotionMonitor *instance;
    if(instance == nil){
        instance = [[VWWMotionMonitor alloc]init];
    }
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.altimeterManager = [[CMAltimeter alloc]init];
        self.session = [@[]mutableCopy];
        self.minAltitude =  100000;
        self.maxAltitude = -100000;
        self.minPressure =  100000;
        self.maxPressure = -100000;

    }
    return self;
}


-(void)start{
    //    @"△";
    //    @"⬆︎";
    //    @"⬇︎";

    [self.altimeterManager startRelativeAltitudeUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAltitudeData *altitudeData, NSError *error) {
        [self.session addObject:altitudeData];
        
        self.minAltitude = MIN(self.minAltitude, altitudeData.relativeAltitude.floatValue);
        self.maxAltitude = MAX(self.maxAltitude, altitudeData.relativeAltitude.floatValue);
        self.minPressure = MIN(self.minPressure, altitudeData.pressure.floatValue);
        self.maxPressure = MAX(self.maxPressure, altitudeData.pressure.floatValue);
        
        NSLog(@"minAltitude: %.2f", self.minAltitude);
        NSLog(@"maxAltitude: %.2f", self.maxAltitude);
        NSLog(@"minPressure: %.2f", self.minPressure);
        NSLog(@"maxPressure: %.2f", self.maxPressure);

        
        
        
        
        const float kAltitudeFactor = 3.28084;
        float altitude = [VWWUserDefaults altitudeUnits] == 0 ? altitudeData.relativeAltitude.floatValue : altitudeData.relativeAltitude.floatValue * kAltitudeFactor;
        NSString *altitudeUnitsString = [VWWUserDefaults altitudeUnits] == 0 ? @"m" : @"f";
        self.altitudeString = [NSString stringWithFormat:@"△ Altitude\n%@%.2f%@",
                                   altitude > 0 ? @"⬆︎" : @"⬇︎",
                                   fabs(altitude),
                                   altitudeUnitsString];
        self.minAltitudeString = [NSString stringWithFormat:@"%.2f%@", self.minAltitude, altitudeUnitsString];
        self.maxAltitudeString = [NSString stringWithFormat:@"%.2f%@", self.maxAltitude, altitudeUnitsString];
        
        
        
        
        const float kPressurePSIFactor = 0.14503773773020923;
        const float kPressureInchesFactor = 0.3;
        const float kPressureMillimetersFactor = 7.50061682704;
        float pressure = 0;
        NSString *pressureUnitsString = nil;
        switch ([VWWUserDefaults pressureUnits]) {
            case 0:
                pressure = altitudeData.pressure.floatValue;
                pressureUnitsString = @"kPa";
                break;
            case 1:
                pressure = altitudeData.pressure.floatValue * kPressurePSIFactor;
                pressureUnitsString = @"psi";
                break;
            case 2:
                pressure = altitudeData.pressure.floatValue * kPressureInchesFactor;
                pressureUnitsString = @"in";
                break;
            case 3:
                pressure = altitudeData.pressure.floatValue * kPressureMillimetersFactor;
                pressureUnitsString = @"mm";
            default:
                break;
        }
        self.pressureString = [NSString stringWithFormat:@"Pressure\n%.2f%@",
                                   pressure,
                                   pressureUnitsString];
        self.minPressureString = [NSString stringWithFormat:@"%.2f%@", self.minPressure, pressureUnitsString];
        self.maxPressureString = [NSString stringWithFormat:@"%.2f%@", self.maxPressure, pressureUnitsString];

        
        [self notify];
    }];

}
-(void)stop{
    [self.altimeterManager stopRelativeAltitudeUpdates];
    
}
-(void)reset{
    [_session removeAllObjects];
    [self stop];
    [self start];
    
}

-(void)notify{
    [[NSNotificationCenter defaultCenter] postNotificationName:VWWMotionMonitorUpdated object:nil];
}


@end

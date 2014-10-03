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
@property (nonatomic, strong) CMMotionActivityManager *motionActivity;
@property (nonatomic, strong) CMPedometer *pedometer;

@property (nonatomic, strong, readwrite) NSMutableArray *session;

@property (nonatomic, strong, readwrite) NSString *altitudeString;
@property (nonatomic, strong, readwrite) NSString *minAltitudeString;
@property (nonatomic, strong, readwrite) NSString *maxAltitudeString;
@property (nonatomic, readwrite) float minAltitude;
@property (nonatomic, readwrite) float maxAltitude;


@property (nonatomic, strong, readwrite) NSString *pressureString;
@property (nonatomic, strong, readwrite) NSString *minPressureString;
@property (nonatomic, strong, readwrite) NSString *maxPressureString;
@property (nonatomic, readwrite) float minPressure;
@property (nonatomic, readwrite) float maxPressure;


@property (nonatomic, strong, readwrite) NSString *activityString;
@property (nonatomic, strong, readwrite) NSString *activityConfidenceString;

@property (nonatomic, strong, readwrite) NSString *stepsString;

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
        if([CMAltimeter isRelativeAltitudeAvailable]){
            self.altimeterManager = [[CMAltimeter alloc]init];
        }
        
        if([CMMotionActivityManager isActivityAvailable]){
            self.motionActivity = [[CMMotionActivityManager alloc]init];
        }
        
        if([CMPedometer isStepCountingAvailable]){
            self.pedometer = [[CMPedometer alloc]init];
        }

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
        
//        NSLog(@"minAltitude: %.2f", self.minAltitude);
//        NSLog(@"maxAltitude: %.2f", self.maxAltitude);
//        NSLog(@"minPressure: %.2f", self.minPressure);
//        NSLog(@"maxPressure: %.2f", self.maxPressure);

        
        
        
        
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

        
        [[NSNotificationCenter defaultCenter] postNotificationName:VWWMotionMonitorUpdated object:nil];
    }];
    
    
    
    [self.motionActivity startActivityUpdatesToQueue:[[NSOperationQueue alloc]init] withHandler:^(CMMotionActivity *activity) {
        
        if(activity.automotive){
            self.activityString = @"Driving";
        } else if(activity.cycling){
            self.activityString = @"Cycling";
        } else if(activity.running){
            self.activityString = @"Running";
        } else if(activity.walking){
            self.activityString = @"Walking";
        } else if(activity.stationary){
            self.activityString = @"Doing Nothing";
        } else if(activity.unknown){
            self.activityString = @"??";
        }
        
        if(activity.confidence == CMMotionActivityConfidenceHigh){
            self.activityConfidenceString = @"Very confident that you're ";
        } else if(activity.confidence == CMMotionActivityConfidenceMedium){
            self.activityConfidenceString = @"It looks like you're ";
        } else if(activity.confidence == CMMotionActivityConfidenceLow){
            self.activityConfidenceString = @"Guessing that you're ";
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:VWWMotionMonitorActivityUpdated object:nil];
        
    }];

    
    [self.pedometer startPedometerUpdatesFromDate:[NSDate date] withHandler:^(CMPedometerData *pedometerData, NSError *error) {
        self.stepsString = [NSString stringWithFormat:@"%ld steps", (long)pedometerData.numberOfSteps];
        [[NSNotificationCenter defaultCenter] postNotificationName:VWWMotionMonitorPedometerUpdated object:nil];
    }];
}
-(void)stop{
    [self.altimeterManager stopRelativeAltitudeUpdates];
    [self.motionActivity stopActivityUpdates];
    [self.pedometer stopPedometerUpdates];
    
}
-(void)reset{
    [_session removeAllObjects];
    [self stop];
    [self start];
    [[NSNotificationCenter defaultCenter] postNotificationName:VWWMotionMonitorUpdated object:nil];
}

-(NSString*)jsonRepresentation{
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:self.session.count];
    for(CMAltitudeData *data in self.session){
        NSDictionary *dictionary = @{@"relativeAltitude" : @(data.relativeAltitude.floatValue),
                                     @"pressure" : @(data.pressure.floatValue)};
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

-(void)notify{
    [[NSNotificationCenter defaultCenter] postNotificationName:VWWMotionMonitorUpdated object:nil];
}


@end

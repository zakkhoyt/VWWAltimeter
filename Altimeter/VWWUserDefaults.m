//
//  VWWUserDefaults.m
//  Altimeter
//
//  Created by Zakk Hoyt on 9/30/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWUserDefaults.h"
static NSString *VWWUserDefaultsPressureUnits = @"pressureUnits";
static NSString *VWWUserDefaultsAltitudeUnits = @"altitudeUnits";
@implementation VWWUserDefaults

+(void)setPressureUnits:(NSUInteger)units{
    [[NSUserDefaults standardUserDefaults] setObject:@(units) forKey:VWWUserDefaultsPressureUnits];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSUInteger)pressureUnits{
    NSNumber *unitsNumber = [[NSUserDefaults standardUserDefaults] objectForKey:VWWUserDefaultsPressureUnits];
    if(unitsNumber == nil){
        unitsNumber = @(0);
    }
    return unitsNumber.integerValue;
}
+(void)setAltitudeUnits:(NSUInteger)units{
    [[NSUserDefaults standardUserDefaults] setObject:@(units) forKey:VWWUserDefaultsAltitudeUnits];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSUInteger)altitudeUnits{
    NSNumber *unitsNumber = [[NSUserDefaults standardUserDefaults] objectForKey:VWWUserDefaultsAltitudeUnits];
    if(unitsNumber == nil){
        unitsNumber = @(0);
    }
    return unitsNumber.integerValue;
}
@end

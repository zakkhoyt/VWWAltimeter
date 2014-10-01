//
//  VWWUserDefaults.h
//  Altimeter
//
//  Created by Zakk Hoyt on 9/30/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VWWUserDefaults : NSObject
+(void)setPressureUnits:(NSUInteger)units;
+(NSUInteger)pressureUnits;

+(void)setAltitudeUnits:(NSUInteger)units;
+(NSUInteger)altitudeUnits;

+(void)setSpeedUnits:(NSUInteger)units;
+(NSUInteger)speedUnits;

@end

//
//  VWWLocation.h
//  Altimeter
//
//  Created by Zakk Hoyt on 10/1/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VWWLocation : NSObject
@property (nonatomic) float relativeAltitude;
@property (nonatomic) float absoluteAltitude;
@property (nonatomic) float speed;
@end

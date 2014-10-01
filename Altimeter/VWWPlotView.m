//
//  VWWPlotView.m
//  RCToolsBalancer
//
//  Created by Zakk Hoyt on 9/10/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWPlotView.h"
#import "VWWMotionMonitor.h"
@import CoreMotion;
@import CoreText;

@interface VWWPlotView ()

@end
@implementation VWWPlotView


#pragma mark Public
-(void)setSession:(NSArray*)session{
    _session = session;
    
    [self.delegate plotViewDidUpdateMinMax:self];
    [self setNeedsDisplay];
    NSLog(@"Set session with %ld data points", (long)_session.count);
}
-(void)drawSolidLineUsingContext:(CGContextRef)context fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint color:(UIColor*)color{
    CGContextSetLineWidth(context, 0.5f);
    CGContextMoveToPoint(context, 0, fromPoint.y);
    CGContextAddLineToPoint(context, self.bounds.size.width, toPoint.y);
    CGContextStrokePath(context);
    
}

-(void)drawDashedLineUsingContext:(CGContextRef)context fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint color:(UIColor*)color{
    const CGFloat kStepWidth = 4;
    const CGFloat kWidth = self.bounds.size.width;// self.bounds.size.width;
    const CGFloat kNumSteps = kWidth / (float)kStepWidth;
    CGContextSetLineWidth(context, 0.5f);
    for(NSUInteger steps = 0; steps < kNumSteps; steps+=2){
        CGContextMoveToPoint(context, steps * kStepWidth, fromPoint.y);
        CGContextAddLineToPoint(context, (steps+1) * kStepWidth, fromPoint.y);
    }
    CGContextStrokePath(context);
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef cgContext = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(cgContext);
    
    const NSUInteger numSteps = self.session.count;
    const CGFloat stepWidth = self.bounds.size.width / (self.session.count - 1);

//    NSLog(@"numSteps: %ld, stepWidth = %ld)
    UIColor *xColor = [UIColor blueColor];
    CGContextSetStrokeColorWithColor(cgContext , xColor.CGColor);
    CGContextSetLineWidth(cgContext, 6.0f);
    
    if([VWWMotionMonitor sharedInstance].maxPressure == 0){
        NSLog(@"");
    }
    
    
    CGFloat maxPressureY = self.bounds.size.height;
    CGFloat minPressureY = 0;
    CGFloat swingPressureY = [VWWMotionMonitor sharedInstance].maxPressure - [VWWMotionMonitor sharedInstance].minPressure;
    CGFloat yPressureFactor = (maxPressureY - minPressureY) / swingPressureY;
    
    
    for(NSInteger index = 0; index < numSteps; index++){
        CMAltitudeData *data = self.session[index];
        CGFloat x = index * stepWidth;
        CGFloat y = ((data.pressure.floatValue * yPressureFactor) - ([VWWMotionMonitor sharedInstance].minPressure * yPressureFactor));
        
        if(index == 0){
            CGContextMoveToPoint(cgContext, x, y);
        } else {
            CGContextAddLineToPoint(cgContext, x, y);
        }
    }
    CGContextStrokePath(cgContext);
    xColor = [UIColor greenColor];
    CGContextSetStrokeColorWithColor(cgContext , xColor.CGColor);
    CGContextSetLineWidth(cgContext, 3.0f);
    
    
    if([VWWMotionMonitor sharedInstance].maxAltitude == 0){
        NSLog(@"");
    }
    
    CGFloat maxAltitudeY = self.bounds.size.height;
    CGFloat minAltitudeY = 0;
    CGFloat swingAltitudeY = [VWWMotionMonitor sharedInstance].maxAltitude - [VWWMotionMonitor sharedInstance].minAltitude;
    CGFloat yAltitudeFactor = (maxAltitudeY - minAltitudeY) / swingAltitudeY;
    
    
    for(NSInteger index = 0; index < numSteps; index++){
        CMAltitudeData *data = self.session[index];
        CGFloat x = index * stepWidth;
        CGFloat y = self.bounds.size.height - ((data.relativeAltitude.floatValue * yAltitudeFactor) - ([VWWMotionMonitor sharedInstance].minAltitude * yAltitudeFactor));

        if(index == 0){
            CGContextMoveToPoint(cgContext, x, y);
        } else {
            CGContextAddLineToPoint(cgContext, x, y);
        }
    }
    CGContextStrokePath(cgContext);
}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    [self.delegate plotView:self touchesBegan:touches withEvent:event];
//}
@end

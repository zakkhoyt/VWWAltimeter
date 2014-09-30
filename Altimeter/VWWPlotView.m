//
//  VWWPlotView.m
//  RCToolsBalancer
//
//  Created by Zakk Hoyt on 9/10/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWPlotView.h"
@import CoreMotion;
@import CoreText;

@interface VWWPlotView ()
@property (nonatomic, readwrite) float minAltitude;
@property (nonatomic, readwrite) float maxAltitude;
@property (nonatomic, readwrite) float minPressure;
@property (nonatomic, readwrite) float maxPressure;

@end
@implementation VWWPlotView


#pragma mark Public
-(void)setSession:(NSArray*)session{
    _session = session;
    self.minAltitude =  100000;
    self.maxAltitude = -100000;
    self.minPressure =  100000;
    self.maxPressure = -100000;
    for(CMAltitudeData *data in _session){
        self.minAltitude = MIN(self.minAltitude, data.relativeAltitude.floatValue);
        self.maxAltitude = MAX(self.maxAltitude, data.relativeAltitude.floatValue);
        self.minPressure = MIN(self.minPressure, data.pressure.floatValue);
        self.maxPressure = MAX(self.maxPressure, data.pressure.floatValue);
    }
    NSLog(@"minAltitude: %.2f", self.minAltitude);
    NSLog(@"maxAltitude: %.2f", self.maxAltitude);
    NSLog(@"minPressure: %.2f", self.minPressure);
    NSLog(@"maxPressure: %.2f", self.maxPressure);
    
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
    const NSUInteger stepWidth = self.bounds.size.width / (self.session.count);

    UIColor *xColor = [UIColor greenColor];
    CGContextSetStrokeColorWithColor(cgContext , xColor.CGColor);
    CGContextSetLineWidth(cgContext, 2.0f);
    
    
    if(self.maxAltitude == 0){
        NSLog(@"");
    }
    if(self.maxPressure == 0){
        NSLog(@"");
    }
    
    CGFloat maxY = self.bounds.size.height;
    CGFloat minY = 0;
    CGFloat swingY = self.maxAltitude - self.minAltitude;
    CGFloat yAltitudeFactor = (maxY - minY) / swingY;
    
    
    for(NSInteger index = 0; index < numSteps; index++){
        CMAltitudeData *data = self.session[index];
        CGFloat x = index * stepWidth;
        CGFloat y = self.bounds.size.height - ((data.relativeAltitude.floatValue * yAltitudeFactor) - (self.minAltitude * yAltitudeFactor));

        if(index == 0){
            CGContextMoveToPoint(cgContext, x, y);
        } else {
            CGContextAddLineToPoint(cgContext, x, y);
        }
        NSLog(@"Drawing line to point; %@", NSStringFromCGPoint(CGPointMake(x, y)));
    }
    CGContextStrokePath(cgContext);
    

    
}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    [self.delegate plotView:self touchesBegan:touches withEvent:event];
//}
@end

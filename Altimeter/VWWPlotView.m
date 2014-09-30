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
    
    const CGFloat yAltitudeFactor = self.bounds.size.height / self.maxAltitude;
    
    for(NSInteger index = 0; index < numSteps; index++){
        CMAltitudeData *data = self.session[index];
        CGFloat x = index * stepWidth;
        CGFloat y = data.relativeAltitude.floatValue * yAltitudeFactor;

//        if(x > self.bounds.size.height){
//            NSAssert(NO, @"Bad x");
//        }
//        if(y > self.bounds.size.width){
//            NSAssert(NO, @"Bad y");
//        }
        if(index == 0){
            CGContextMoveToPoint(cgContext, x, y);
        } else {
            CGContextAddLineToPoint(cgContext, x, y);
        }
        NSLog(@"Drawing line to point; %@", NSStringFromCGPoint(CGPointMake(x, y)));
    }
    CGContextStrokePath(cgContext);
    
    
//    
//    [self drawSolidLineUsingContext:cgContext fromPoint:CGPointMake(0, xBaseline) toPoint:CGPointMake(self.bounds.size.width, xBaseline) color:xColor];
//    
//    CGFloat yMax = xBaseline - _limits.x.max * yFactor;
//    [self drawDashedLineUsingContext:cgContext fromPoint:CGPointMake(0, yMax) toPoint:CGPointMake(self.bounds.size.width, yMax) color:xColor];
//
//    CGFloat yMin = xBaseline - _limits.x.min * yFactor;
//    [self drawDashedLineUsingContext:cgContext fromPoint:CGPointMake(0, yMin) toPoint:CGPointMake(self.bounds.size.width, yMin) color:xColor];
//    
//    CGContextSetLineWidth(cgContext, 2.0f);
//    for(NSInteger index = 0; index < kSamples; index++){
//        NSDictionary *d = self.session.data[startIndex + index];
//        NSNumber *yNumber = d[@"x"];
//        CGFloat y = -yNumber.floatValue * yFactor + xBaseline;
//        if(index == 0){
//            CGContextMoveToPoint(cgContext, 0, y);
//        } else {
//            CGFloat x = index * xFactor;
//            CGContextAddLineToPoint(cgContext, x, y);
//        }
//    }
//    CGContextStrokePath(cgContext);
//
//    
//    {
//        UIColor *color = [UIColor greenColor];
//        CGContextSetStrokeColorWithColor(cgContext , color.CGColor);
//        [self drawSolidLineUsingContext:cgContext fromPoint:CGPointMake(0, yBaseline) toPoint:CGPointMake(self.bounds.size.width, yBaseline) color:color];
//        
//        CGFloat yMax = yBaseline - _limits.y.max * yFactor;
//        [self drawDashedLineUsingContext:cgContext fromPoint:CGPointMake(0, yMax) toPoint:CGPointMake(self.bounds.size.width, yMax) color:xColor];
//        
//        CGFloat yMin = yBaseline - _limits.y.min * yFactor;
//        [self drawDashedLineUsingContext:cgContext fromPoint:CGPointMake(0, yMin) toPoint:CGPointMake(self.bounds.size.width, yMin) color:xColor];
//
//        CGContextSetLineWidth(cgContext, 2.0f);
//        for(NSInteger index = 0; index < kSamples; index++){
//            NSDictionary *d = self.session.data[startIndex + index];
//            NSNumber *yNumber = d[@"y"];
//            CGFloat y = -yNumber.floatValue * yFactor + yBaseline;
//            if(index == 0){
//                CGContextMoveToPoint(cgContext, 0, y);
//            } else {
//                CGFloat x = index * xFactor;
//                CGContextAddLineToPoint(cgContext, x, y);
//            }
//        }
//        CGContextStrokePath(cgContext);
//    }
//    
//    {
//        UIColor *color = [UIColor cyanColor];
//        CGContextSetStrokeColorWithColor(cgContext , color.CGColor);
//        [self drawSolidLineUsingContext:cgContext fromPoint:CGPointMake(0, zBaseline) toPoint:CGPointMake(self.bounds.size.width, zBaseline) color:color];
//        
//        CGFloat yMax = zBaseline - _limits.z.max * yFactor;
//        [self drawDashedLineUsingContext:cgContext fromPoint:CGPointMake(0, yMax) toPoint:CGPointMake(self.bounds.size.width, yMax) color:xColor];
//        
//        CGFloat yMin = zBaseline - _limits.z.min * yFactor;
//        [self drawDashedLineUsingContext:cgContext fromPoint:CGPointMake(0, yMin) toPoint:CGPointMake(self.bounds.size.width, yMin) color:xColor];
//
//        CGContextSetLineWidth(cgContext, 2.0f);
//        for(NSInteger index = 0; index < kSamples; index++){
//            NSDictionary *d = self.session.data[startIndex + index];
//            NSNumber *yNumber = d[@"z"];
//            CGFloat y = -yNumber.floatValue * yFactor + zBaseline;
//            if(index == 0){
//                CGContextMoveToPoint(cgContext, 0, y);
//            } else {
//                CGFloat x = index * xFactor;
//                CGContextAddLineToPoint(cgContext, x, y);
//            }
//        }
//        CGContextStrokePath(cgContext);
//    }
    //    // Text
    //    CGMutablePathRef path = CGPathCreateMutable(); //1
    //    //    CGPathAddRect(path, NULL, self.bounds);
    //
    //    CGFloat y = self.bounds.size.height - (self.session.limits.x.max * yFactor + xBaseline);
    //    CGPathAddRect(path, NULL, CGRectMake(10, -y, 300, 10));
    //    NSString *s = [NSString stringWithFormat:@"%.4f", self.session.limits.x.max];
    //    NSAttributedString* attString = [[NSAttributedString alloc] initWithString:s attributes:@{NSForegroundColorAttributeName : [UIColor redColor]}];
    //    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef) attString);
    //    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attString length]), path, NULL);
    //
    //
    //
    //    // Flip the coordinate system
    //    CGContextSetTextMatrix(cgContext, CGAffineTransformIdentity);
    //    CGContextTranslateCTM(cgContext, 0, self.bounds.size.height);
    //    CGContextScaleCTM(cgContext, 1.0, -1.0);
    //
    //
    //    CTFrameDraw(frame, cgContext); //4
    //    
    //    CFRelease(frame); //5
    //    CFRelease(path);
    //    CFRelease(framesetter);
    
}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    [self.delegate plotView:self touchesBegan:touches withEvent:event];
//}
@end

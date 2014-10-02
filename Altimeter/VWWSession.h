//
//  VWWSession.h
//  Altimeter
//
//  Created by Zakk Hoyt on 10/2/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VWWSession : NSObject
+(VWWSession*)sharedInstance;
-(void)addData:(NSDictionary*)data forType:(NSString*)type date:(NSDate*)date;
-(void)reset;
-(NSString*)jsonRepresentation;
@end

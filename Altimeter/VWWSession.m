//
//  VWWSession.m
//  Altimeter
//
//  Created by Zakk Hoyt on 10/2/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWSession.h"

@interface VWWSession ()
@property (nonatomic, strong) NSMutableArray *data;
@end

@implementation VWWSession
+(VWWSession*)sharedInstance{
    static VWWSession *instance;
    if(instance == nil){
        instance = [[VWWSession alloc]init];
    }
    return instance;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self reset];
    }
    return self;
}


-(void)addData:(NSDictionary*)data forType:(NSString*)type date:(NSDate*)date{
    @synchronized(self){
        NSDictionary *dictionary = @{@"date" : date.description,
                                     @"type" : type,
                                     @"data" : data};
        [self.data addObject:dictionary];
    }
}

-(void)reset{
    @synchronized(self){
        self.data = [@[]mutableCopy];
    }
}

-(NSString*)jsonRepresentation{
    @synchronized(self){
        NSString *json = [self jsonRepresentationOfArray:self.data prettyPrint:YES];
        return json;
    }
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


@end

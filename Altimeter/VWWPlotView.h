//
//  VWWPlotView.h
//  RCToolsBalancer
//
//  Created by Zakk Hoyt on 9/10/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VWWSession;
@class VWWPlotView;

@protocol VWWPlotViewDelegate <NSObject>
-(void)plotView:(VWWPlotView*)sender touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)plotViewDidUpdateMinMax:(VWWPlotView*)sender;
@end

@interface VWWPlotView : UIView
@property (nonatomic, strong) NSArray *motionSession;
@property (nonatomic, strong) NSArray *locationSession;
@property (nonatomic, weak) id <VWWPlotViewDelegate> delegate;
@end

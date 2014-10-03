//
//  VWWSummaryViewController.m
//  Altimeter
//
//  Created by Zakk Hoyt on 9/30/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWSummaryViewController.h"
#import "VWWPlotView.h"
#import "VWWMotionMonitor.h"
#import "VWWLocationMonitor.h"

@interface VWWSummaryViewController () <VWWPlotViewDelegate>
@property (weak, nonatomic) IBOutlet VWWPlotView *plotView;
@property (weak, nonatomic) IBOutlet UILabel *maxRelativeAltitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *minRelativeAltitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxPressureLabel;
@property (weak, nonatomic) IBOutlet UILabel *minPressureLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *minSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxAbsoluteAltitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *minAbsoluteAltitudeLabel;

@end

@implementation VWWSummaryViewController

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.plotView.delegate = self;
    self.plotView.motionSession = self.motionSession;
    self.plotView.locationSession = self.locationSession;
    self.title = @"Summary";
    
    self.maxRelativeAltitudeLabel.layer.masksToBounds = YES;
    self.maxRelativeAltitudeLabel.layer.cornerRadius = 8;
    self.minRelativeAltitudeLabel.layer.masksToBounds = YES;
    self.minRelativeAltitudeLabel.layer.cornerRadius = 8;
    self.maxPressureLabel.layer.masksToBounds = YES;
    self.maxPressureLabel.layer.cornerRadius = 8;
    self.minPressureLabel.layer.masksToBounds = YES;
    self.minPressureLabel.layer.cornerRadius = 8;

    [[NSNotificationCenter defaultCenter] addObserverForName:VWWMotionMonitorUpdated object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        self.plotView.motionSession = [VWWMotionMonitor sharedInstance].session;
        [self.plotView setNeedsDisplay];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:VWWLocationMonitorUpdated object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        self.plotView.locationSession = [VWWLocationMonitor sharedInstance].session;
        [self.plotView setNeedsDisplay];
    }];

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    self.plotView.motionSession = [VWWMotionMonitor sharedInstance].session;
    self.plotView.locationSession = [VWWLocationMonitor sharedInstance].session;
    [self.plotView setNeedsDisplay];

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark VWWPlotViewDelegate
-(void)plotView:(VWWPlotView*)sender touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

-(void)plotViewDidUpdateMinMax:(VWWPlotView*)sender{
    self.minRelativeAltitudeLabel.text = [VWWMotionMonitor sharedInstance].minAltitudeString;
    self.maxRelativeAltitudeLabel.text = [VWWMotionMonitor sharedInstance].maxAltitudeString;
    self.minPressureLabel.text = [VWWMotionMonitor sharedInstance].minPressureString;
    self.maxPressureLabel.text = [VWWMotionMonitor sharedInstance].maxPressureString;

    self.minSpeedLabel.text = [VWWLocationMonitor sharedInstance].minSpeedString;
    self.maxSpeedLabel.text = [VWWLocationMonitor sharedInstance].maxSpeedString;
    self.minAbsoluteAltitudeLabel.text = [VWWLocationMonitor sharedInstance].minAbsoluteAltitudeString;
    self.maxAbsoluteAltitudeLabel.text = [VWWLocationMonitor sharedInstance].maxAbsoluteAltitudeString;
}


@end

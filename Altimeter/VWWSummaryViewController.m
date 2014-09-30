//
//  VWWSummaryViewController.m
//  Altimeter
//
//  Created by Zakk Hoyt on 9/30/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWSummaryViewController.h"
#import "VWWPlotView.h"

@interface VWWSummaryViewController () <VWWPlotViewDelegate>
@property (weak, nonatomic) IBOutlet VWWPlotView *plotView;
@property (weak, nonatomic) IBOutlet UILabel *maxAltitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *minAltitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxPressureLabel;
@property (weak, nonatomic) IBOutlet UILabel *minPressureLabel;

@end

@implementation VWWSummaryViewController

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.plotView.delegate = self;
    self.plotView.session = self.session;
    self.title = @"Summary";
    
    self.maxAltitudeLabel.layer.masksToBounds = YES;
    self.maxAltitudeLabel.layer.cornerRadius = 8;
    self.minAltitudeLabel.layer.masksToBounds = YES;
    self.minAltitudeLabel.layer.cornerRadius = 8;
    self.maxPressureLabel.layer.masksToBounds = YES;
    self.maxPressureLabel.layer.cornerRadius = 8;
    self.minPressureLabel.layer.masksToBounds = YES;
    self.minPressureLabel.layer.cornerRadius = 8;

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
}

#pragma mark VWWPlotViewDelegate
-(void)plotView:(VWWPlotView*)sender touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

-(void)plotViewDidUpdateMinMax:(VWWPlotView*)sender{
    self.minAltitudeLabel.text = [NSString stringWithFormat:@"%.2f", self.plotView.minAltitude];
    self.maxAltitudeLabel.text = [NSString stringWithFormat:@"%.2f", self.plotView.maxAltitude];
    self.minPressureLabel.text = [NSString stringWithFormat:@"%.2f", self.plotView.minPressure];
    self.maxPressureLabel.text = [NSString stringWithFormat:@"%.2f", self.plotView.maxPressure];

}


@end

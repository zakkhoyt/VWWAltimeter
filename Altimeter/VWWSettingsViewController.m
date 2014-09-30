//
//  VWWSettingsViewController.m
//  Altimeter
//
//  Created by Zakk Hoyt on 9/30/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWSettingsViewController.h"
#import "VWWUserDefaults.h"

@interface VWWSettingsViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *pressureUnitsSegment;

@property (weak, nonatomic) IBOutlet UISegmentedControl *altitudeUnitsSegment;

@end

@implementation VWWSettingsViewController

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.pressureUnitsSegment.selectedSegmentIndex = [VWWUserDefaults pressureUnits];
    self.altitudeUnitsSegment.selectedSegmentIndex = [VWWUserDefaults altitudeUnits];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pressureUnitsSegmentValueChanged:(UISegmentedControl *)sender {
    [VWWUserDefaults setPressureUnits:sender.selectedSegmentIndex];
}
- (IBAction)altitudeUnitsSegmentValueChanged:(UISegmentedControl *)sender {
    [VWWUserDefaults setAltitudeUnits:sender.selectedSegmentIndex];
}


@end

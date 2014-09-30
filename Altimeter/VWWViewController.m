//
//  ViewController.m
//  Altimeter
//
//  Created by Zakk Hoyt on 9/30/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWViewController.h"
#import "VWWUserDefaults.h"
#import "VWWSummaryViewController.h"
#define VWW_FAKE_IT 1;

@import CoreMotion;

static NSString *VWWSegueMainToSettings = @"VWWSegueMainToSettings";
static NSString *VWWSegueMainToSummary = @"VWWSegueMainToSummary";

@interface VWWViewController () <UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UILabel *altitudeLabel;

@property (weak, nonatomic) IBOutlet UILabel *pressureLabel;
@property (nonatomic, strong) CMAltimeter *altimeterManager;
@property (nonatomic, strong) NSMutableArray *session;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation VWWViewController


-(BOOL)prefersStatusBarHidden{
    return YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _session = [@[]mutableCopy];
    
    [self start];
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapHandler:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTapGesture];
    

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    
    self.infoLabel.alpha = 1.0;
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(timerAction:) userInfo:nil repeats:NO];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    // 4s 48    
    // 5  58
    // 6  68
    // 6+
    UIFont *font = nil;
    CGFloat portraitHeight = MAX(self.view.bounds.size.width, self.view.bounds.size.height);
    if(portraitHeight <= 480){
        
        font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:48];
    } else if(portraitHeight <= 568){
        font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:58];
    } else if(portraitHeight <= 667){
        font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:68];
    } else {
        font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:78];
    }
    self.altitudeLabel.font = font;
    self.pressureLabel.font = font;
    
    NSLog(@"");
}
-(void)doubleTapHandler:(UITapGestureRecognizer*)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:@"Reset Altitude", @"Summary", @"Settings", nil];
    [actionSheet showInView:self.view];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:VWWSegueMainToSummary]){
        VWWSummaryViewController *vc = segue.destinationViewController;
        vc.session = self.session;
    }
}


-(void)timerAction:(id)sender{
    [UIView animateWithDuration:1.0 animations:^{
        self.infoLabel.alpha = 0.0;
    }];
}
-(void)start{
//    @"△";
//    @"⬆︎";
//    @"⬇︎";
    
#if defined(VWW_FAKE_IT)
    self.altitudeLabel.text = @"△ Altitude\n18.73m";
    self.pressureLabel.text = @"Pressure\n101.12kPa";
    return;
#endif
    self.altitudeLabel.text = @"△ Altitude\n...";
    self.pressureLabel.text = @"Pressure\n...";

    if([CMAltimeter isRelativeAltitudeAvailable]){
        self.altimeterManager = [[CMAltimeter alloc]init];
        [self.altimeterManager startRelativeAltitudeUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAltitudeData *altitudeData, NSError *error) {
            [self.session addObject:altitudeData];
            const float kAltitudeFactor = 3.28084;
            float altitude = [VWWUserDefaults altitudeUnits] == 0 ? altitudeData.relativeAltitude.floatValue : altitudeData.relativeAltitude.floatValue * kAltitudeFactor;
            NSString *altitudeUnitsString = [VWWUserDefaults altitudeUnits] == 0 ? @"m" : @"f";
            self.altitudeLabel.text = [NSString stringWithFormat:@"△ Altitude\n%@%.2f%@",
                                       altitude > 0 ? @"⬆︎" : @"⬇︎",
                                       fabs(altitude),
                                       altitudeUnitsString];
            
            const float kPressurePSIFactor = 0.14503773773020923;
            const float kPressureInchesFactor = 0.3;
            const float kPressureMillimetersFactor = 7.50061682704;
            float pressure = 0;
            NSString *pressureUnitsString = nil;
            switch ([VWWUserDefaults pressureUnits]) {
                case 0:
                    pressure = altitudeData.pressure.floatValue;
                    pressureUnitsString = @"kPa";
                    break;
                case 1:
                    pressure = altitudeData.pressure.floatValue * kPressurePSIFactor;
                    pressureUnitsString = @"psi";
                    break;
                case 2:
                    pressure = altitudeData.pressure.floatValue * kPressureInchesFactor;
                    pressureUnitsString = @"in";
                    break;
                case 3:
                    pressure = altitudeData.pressure.floatValue * kPressureMillimetersFactor;
                    pressureUnitsString = @"mm";
                default:
                    break;
            }
            self.pressureLabel.text = [NSString stringWithFormat:@"Pressure\n%.2f%@",
                                       pressure,
                                       pressureUnitsString];
        }];
        NSLog(@"Started altimeter");
    } else {
        self.altitudeLabel.text = @"△ Altitude\nn/a";
        self.pressureLabel.text = @"Pressure\nn/a";
        NSLog(@"Altimeter not available");
    }

}

-(void)stop{
    self.altitudeLabel.text = @"△ Altitude\n-";
    self.pressureLabel.text = @"Pressure\n-";

    [self.altimeterManager stopRelativeAltitudeUpdates];
}

-(void)reset{
    [_session removeAllObjects];
    [self stop];
    [self start];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        [self reset];
    } else if(buttonIndex == 1){
        [self performSegueWithIdentifier:VWWSegueMainToSummary sender:self];
    } else if(buttonIndex == 2){
        [self performSegueWithIdentifier:VWWSegueMainToSettings sender:self];
    }
    
    
}
@end

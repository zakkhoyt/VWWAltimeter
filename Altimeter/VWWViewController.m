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
#import "VWWMotionMonitor.h"
#import "VWWPlotView.h"
#import "MBProgressHUD.h"
#import "VWWLocationMonitor.h"
#import "VWWAltitudeCollectionViewCell.h"

//#define VWW_FAKE_IT 1;
#define VWW_FORCE_GPS 1
@import CoreMotion;
@import CoreLocation;

static NSString *VWWSegueMainToSettings = @"VWWSegueMainToSettings";
static NSString *VWWSegueMainToSummary = @"VWWSegueMainToSummary";

@interface VWWViewController () <UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UILabel *altitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *pressureLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSIndexPath *indexPath;
@end

@implementation VWWViewController


-(BOOL)prefersStatusBarHidden{
    return YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView.collectionViewLayout = layout;
    
    [self start];
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapHandler:)];
    [self.view addGestureRecognizer:doubleTapGesture];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:VWWMotionMonitorUpdated object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        VWWAltitudeCollectionViewCell *cell = (VWWAltitudeCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        [cell setFirstLabelText:[VWWMotionMonitor sharedInstance].altitudeString color:[UIColor greenColor]];
        [cell setSecondLabelText:[VWWMotionMonitor sharedInstance].pressureString color:[UIColor yellowColor]];
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:VWWLocationMonitorUpdated object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        VWWAltitudeCollectionViewCell *cell = (VWWAltitudeCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
        [cell setFirstLabelText:[VWWLocationMonitor sharedInstance].absoluteAltitudeString color:[UIColor redColor]];
        [cell setSecondLabelText:[VWWLocationMonitor sharedInstance].speedString color:[UIColor cyanColor]];
    }];


    [[NSNotificationCenter defaultCenter] addObserverForName:VWWMotionMonitorActivityUpdated object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        VWWAltitudeCollectionViewCell *cell = (VWWAltitudeCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]];
        [cell setFirstLabelText:[VWWMotionMonitor sharedInstance].activityConfidenceString color:[UIColor purpleColor]];
        [cell setSecondLabelText:[VWWMotionMonitor sharedInstance].activityString color:[UIColor orangeColor]];
    }];

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


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
//    NSUInteger index = self.collectionView.contentOffset.x / self.view.bounds.size.width;
//    self.indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self.collectionView.collectionViewLayout invalidateLayout];
//    [self.collectionView scrollToItemAtIndexPath:self.indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}
//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
//    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
//    NSUInteger index = self.collectionView.contentOffset.x / self.view.bounds.size.width;
//    self.indexPath = [NSIndexPath indexPathForItem:index inSection:0];
////    [self.collectionView.collectionViewLayout invalidateLayout];
////    [self.collectionView layoutSubviews];
////    [self.view layoutSubviews];
//}
//
//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
//    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
//
//
////    [self.collectionView.collectionViewLayout invalidateLayout];
////    [self.collectionView layoutSubviews];
////    [self.view layoutSubviews];
//
//}

-(void)doubleTapHandler:(UITapGestureRecognizer*)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:@"Reset Altitude", @"Summary", @"Settings", @"Share Data", @"Share Plot", nil];
    [actionSheet showInView:self.view];
}

//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    if([segue.identifier isEqualToString:VWWSegueMainToSummary]){
//        VWWSummaryViewController *vc = segue.destinationViewController;
//
//    }
//}


-(void)timerAction:(id)sender{
    [UIView animateWithDuration:1.0 animations:^{
        self.infoLabel.alpha = 0.0;
    }];
}
-(void)start{
    
#if defined(VWW_FAKE_IT)
    self.altitudeLabel.text = @"△ Altitude\n18.73m";
    self.pressureLabel.text = @"Pressure\n101.12kPa";
    return;
#endif
    self.altitudeLabel.text = @"△ Altitude\n...";
    self.pressureLabel.text = @"Pressure\n...";


    if([CMAltimeter isRelativeAltitudeAvailable]){
        [[VWWMotionMonitor sharedInstance] start];
    } else {
        self.altitudeLabel.text = @"△ Altitude\nn/a";
        self.pressureLabel.text = @"Pressure\nn/a";
        NSLog(@"Altimeter not available");
    }

    [[VWWLocationMonitor sharedInstance] start];
}


-(void)reset{
    [[VWWMotionMonitor sharedInstance]reset];
}


-(void)shareSessionData{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    void (^shareSessionString)(NSString *sessionString) = ^(NSString *sessionString){
        NSMutableArray *items = [@[sessionString]mutableCopy];
        NSMutableArray *activities = [@[]mutableCopy];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc]initWithActivityItems:items
                                                                                            applicationActivities:activities];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError){
            if(completed){
                [self dismissViewControllerAnimated:YES completion:^{
                }];
            }
            
        }];
        
        [self presentViewController:activityViewController animated:YES completion:nil];
    };

    NSString *motionJSON = [VWWMotionMonitor sharedInstance].jsonRepresentation;
    NSString *locationJSON = [VWWLocationMonitor sharedInstance].jsonRepresentation;
    NSString *json = [NSString stringWithFormat:@"%@\n%@", motionJSON, locationJSON];
    shareSessionString(json);
}


-(void)shareSessionPlot{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    void (^shareSessionPlot)(UIImage *sessionPlot) = ^(UIImage *sessionPlot){
        NSMutableArray *items = [@[sessionPlot]mutableCopy];
        NSMutableArray *activities = [@[]mutableCopy];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc]initWithActivityItems:items
                                                                                            applicationActivities:activities];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError){
            if(completed){
                [self dismissViewControllerAnimated:YES completion:^{
                }];
            }
            
        }];
        
        [self presentViewController:activityViewController animated:YES completion:nil];
    };
    
    
    
    VWWPlotView *plotView = [[VWWPlotView alloc]initWithFrame:CGRectMake(0, 0, 400, 300)];
    plotView.motionSession = [VWWMotionMonitor sharedInstance].session;
    plotView.locationSession = [VWWLocationMonitor sharedInstance].session;
    [plotView setNeedsDisplay];
    UIImage *image = [self imageFromView:plotView];
    
    if(image){
        shareSessionPlot(image);
    }
}

-(UIImage*)imageFromView:(UIView *)view{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0);
    // [view.layer renderInContext:UIGraphicsGetCurrentContext()]; // <- same result...
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}



#pragma mark UICollectionViewFlowLayoutDelegate
#pragma mark UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"bounds: %@", NSStringFromCGRect(self.view.bounds));
    NSLog(@"frame: %@", NSStringFromCGRect(self.view.frame));
    return self.view.bounds.size;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

#pragma mark UICollectionViewDatasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VWWAltitudeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VWWAltitudeCollectionViewCell" forIndexPath:indexPath];
    if(indexPath.item == 0){
        if([VWWMotionMonitor sharedInstance].altitudeString){
            [cell setFirstLabelText:[VWWMotionMonitor sharedInstance].altitudeString color:[UIColor greenColor]];
        } else {
            [cell setFirstLabelText:@"△ Altitude\n..." color:[UIColor greenColor]];
        }
        if([VWWMotionMonitor sharedInstance].pressureString){
            [cell setSecondLabelText:[VWWMotionMonitor sharedInstance].pressureString color:[UIColor yellowColor]];
        } else {
            [cell setSecondLabelText:@"Pressure\n..." color:[UIColor yellowColor]];
        }
        
        
    } else if(indexPath.item == 1){
        if([VWWLocationMonitor sharedInstance].absoluteAltitudeString){
            [cell setFirstLabelText:[VWWLocationMonitor sharedInstance].absoluteAltitudeString color:[UIColor redColor]];
        } else {
            [cell setFirstLabelText:@"Altitude\n..." color:[UIColor redColor]];
        }
        
        if([VWWLocationMonitor sharedInstance].speedString){
            [cell setSecondLabelText:[VWWLocationMonitor sharedInstance].speedString color:[UIColor cyanColor]];
        } else {
            [cell setSecondLabelText:@"Speed\n..." color:[UIColor cyanColor]];
        }
        
        
    } else if(indexPath.item == 1){
        if([VWWMotionMonitor sharedInstance].activityConfidenceString){
            [cell setFirstLabelText:[VWWMotionMonitor sharedInstance].activityConfidenceString color:[UIColor purpleColor]];
        } else {
            [cell setFirstLabelText:@"Confidence\n..." color:[UIColor purpleColor]];
        }
        
        if([VWWMotionMonitor sharedInstance].activityString){
            [cell setSecondLabelText:[VWWMotionMonitor sharedInstance].activityString color:[UIColor orangeColor]];
        } else {
            [cell setSecondLabelText:@"Activity\n..." color:[UIColor orangeColor]];
        }
        
        
    }
    return cell;
}







#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        [self reset];
    } else if(buttonIndex == 1){
        [self performSegueWithIdentifier:VWWSegueMainToSummary sender:self];
    } else if(buttonIndex == 2){
        [self performSegueWithIdentifier:VWWSegueMainToSettings sender:self];
    } else if(buttonIndex == 3){
        [self shareSessionData];
    } else if(buttonIndex == 4){
        [self shareSessionPlot];
    }
    
    
}
@end

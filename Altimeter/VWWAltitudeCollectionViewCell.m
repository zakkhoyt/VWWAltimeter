//
//  VWWAltitudeCollectionViewCell.m
//  Altimeter
//
//  Created by Zakk Hoyt on 10/1/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWAltitudeCollectionViewCell.h"

@interface VWWAltitudeCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;

@end
@implementation VWWAltitudeCollectionViewCell

-(void)setupFonts{
    UIFont *font = nil;
    CGFloat portraitHeight = MAX(self.bounds.size.width, self.bounds.size.height);
    if(portraitHeight <= 480){
        font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:48];
    } else if(portraitHeight <= 568){
        font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:58];
    } else if(portraitHeight <= 667){
        font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:68];
    } else {
        font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:78];
    }
    self.firstLabel.font = font;
    self.secondLabel.font = font;
}
-(void)setFirstLabelText:(NSString*)text color:(UIColor*)color{
    self.firstLabel.text = text;
    self.firstLabel.textColor = color;
}
-(void)setSecondLabelText:(NSString*)text color:(UIColor*)color{
    self.secondLabel.text = text;
    self.secondLabel.textColor = color;
}

@end

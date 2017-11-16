//
//  UserHeaderView.m
//  WaveAnimation
//
//  Created by YLCHUN on 2017/11/13.
//  Copyright © 2017年 YLCHUN. All rights reserved.
//

#import "UserHeaderView.h"
#import "WaveAnimation.h"

@interface UserHeaderView ()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (nonatomic, assign) BOOL displayFlag;
@end

@implementation UserHeaderView

+(instancetype)headerViewWithWidth:(CGFloat)width {
    UserHeaderView *view = [[NSBundle mainBundle] loadNibNamed:@"UserHeaderView" owner:nil options:nil].firstObject;
    CGRect frame = view.bounds;
    frame.size.width = width;
    view.frame = frame;
    return view;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.imgView.image = [UIImage imageNamed:@"img.jpg"];
    self.titleLabel.text = @"巴拉巴拉";
    self.subTitleLabel.text = @"📱137****0000";
}

-(void)didMoveToWindow
{
    [super didMoveToWindow];
    self.displayFlag = !self.displayFlag;
    if (self.displayFlag)
    {
        if (self.waveAnimation) {
            [self.waveAnimation start];
        }else {
            [self initWaveAnimation];
        }
    }
    else
    {
        [self.waveAnimation stop];
    }
}

-(void)initWaveAnimation
{
    CGRect frame  = self.bounds;
    frame.size.height = 10;
    frame.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(frame);
    
    WaveAnimation *waveAnimation = [[WaveAnimation alloc] initWithView:self waveFrame:frame wavePeriod:400 waveSpeed:3];
    
    CGPoint center = self.imgView.center;
    CGPoint origin = CGPointMake(CGRectGetMinX(self.imgView.bounds) + 5, center.y);
    
    __weak typeof(self) wself = self;
    [waveAnimation setWaveYCallback:^(double currentY) {
        __strong typeof(self) sself = wself;
        sself.imgView.transform = CGAffineTransformIdentity;
        sself.imgView.transform = CGAffineTransformRotate2D(center, origin, (currentY-5)*2 / 180.0 * M_PI);
    } atWaveX:50];
    
    [waveAnimation start];
}

static CGAffineTransform CGAffineTransformRotate2D(CGPoint center, CGPoint origin, float angle)
{
    CGFloat x = origin.x - center.x;
    CGFloat y = origin.y - center.y;
    CGAffineTransform trans = CGAffineTransformMakeTranslation(x, y);
    trans = CGAffineTransformRotate(trans, angle);
    trans = CGAffineTransformTranslate(trans, -x, -y);
    return trans;
}

@end

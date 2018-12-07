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
    self.autoresizingMask = UIViewAutoresizingNone;
    self.imgView.image = [UIImage imageNamed:@"img.jpg"];
    self.titleLabel.text = @"YLCHUN";
    self.subTitleLabel.text = @"📱177****5002";
}

-(void)didMoveToWindow
{
    [super didMoveToWindow];
    self.displayFlag = !self.displayFlag;
    if (self.displayFlag) {
        if (self.waveAnimation) {
            [self.waveAnimation start];
        }else {
            [self initWaveAnimation];
        }
    } else{
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
    [waveAnimation setWaveYCallback:^(double y, double tangentAngle) {
        __strong typeof(self) sself = wself;
        sself.imgView.transform = CGAffineTransformIdentity;
        sself.imgView.transform = CGAffineTransformRotate2D(center, origin,  tangentAngle + tangentAngle);
    } atWaveX:50];
    
    [self initWaveBoat:waveAnimation];
    
    [waveAnimation start];
    
}

-(void)initWaveBoat:(WaveAnimation*)waveAnimation  {
    double h = 3;
    double w = 20;
    UIView *boatView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    boatView.backgroundColor = [UIColor cyanColor];
    [self addSubview:boatView];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:boatView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:boatView.bounds.size];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = boatView.bounds;
    maskLayer.path = maskPath.CGPath;
    boatView.layer.mask = maskLayer;
    
    [waveAnimation setWaveBuoyCallback:^(double x, double y, double tangentAngle) {
        boatView.center = CGPointMake(x, y);
        boatView.transform = CGAffineTransformMakeRotation(tangentAngle);
    } margin:w/2 normalLineOffset:h/2];
}

static CGAffineTransform CGAffineTransformRotate2D(CGPoint point, CGPoint origin, double angle)
{
    CGFloat x = origin.x - point.x;
    CGFloat y = origin.y - point.y;
    CGAffineTransform trans = CGAffineTransformMakeTranslation(x, y);
    trans = CGAffineTransformRotate(trans, angle);
    trans = CGAffineTransformTranslate(trans, -x, -y);
    return trans;
}

@end

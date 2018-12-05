//
//  WaveAnimation.m
//  WaveAnimation
//
//  Created by YLCHUN on 2017/10/26.
//  Copyright © 2017年 YLCHUN. All rights reserved.
//

#import "WaveAnimation.h"
#import "WaveCounter.h"
#import <objc/runtime.h>

@interface UIView ()
@property (nonatomic) WaveAnimation *waveAnimation;
@end

@interface WaveAnimation ()

@property (nonatomic, weak) UIView *view;

@property (nonatomic, assign) CGRect waveFrame;
@property (nonatomic, assign) double wavePeriod;
@property (nonatomic, assign) double waveSpeed;

@property (nonatomic, strong) WaveCounter *waveCounter;

@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, strong) CAShapeLayer *waveLayer_fg;
@property (nonatomic, strong) CAShapeLayer *waveLayer_bg;

@property (nonatomic, strong) UIColor *fgColor;
@property (nonatomic, strong) UIColor *bgColor;

@property (nonatomic, assign) CGFloat waveX;
@property (nonatomic, copy) void(^waveY)(CGFloat currentY, double tangentAngle);
@property (nonatomic, copy) void(^wave)(double x, double y, double tangentAngle);
@end


@implementation WaveAnimation

-(instancetype)initWithView:(UIView*)view waveFrame:(CGRect)frame wavePeriod:(double)period waveSpeed:(double)speed {
    if (!view) {
        return nil;
    }
    self = [super init];
    if (self) {
        _waveFrame = CGRectEqualToRect(frame, CGRectZero)?view.bounds:frame;
        _wavePeriod = period;
        _waveSpeed = speed;
        _view = view;
        self.fgColor = [UIColor whiteColor];
        self.bgColor = [UIColor colorWithWhite:1 alpha:0.5];
        [self addToView];
    }
    return self;
}

-(void)dealloc {
    [self removeFromView];
}

-(BOOL)didAdd {
   return self.view.waveAnimation != nil;
}

-(void)addToView {
    if (![self didAdd]) {
        [self.view.layer addSublayer:self.waveLayer_bg];
        [self.view.layer addSublayer:self.waveLayer_fg];
        self.view.waveAnimation = self;
    }
}

-(void)removeFromView {
    if ([self didAdd]) {
        [_waveLayer_fg removeFromSuperlayer];
        [_waveLayer_bg removeFromSuperlayer];
        self.view.waveAnimation = nil;
    }
}

- (void)start {
    if (!self.displayLink) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(doWave)];
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)stop {
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

void setLayerPath(CAShapeLayer *layer, CGPathRef path) {
    layer.path = path;
    CGPathRelease(path);
}

-(void)doWave {
    __weak typeof(self) wself = self;
    
    [self.waveCounter wavePath:^(CGPathRef path1, CGPathRef path2) {
        __strong typeof(self) sself = wself;
        setLayerPath(sself.waveLayer_fg, path1);
        setLayerPath(sself.waveLayer_bg, path2);
    }];
    
    double wy = CGRectGetMinY(_waveFrame);
    if (self.waveY) {
        [self.waveCounter waveY:^(double y, double tangentAngle) {
            wself.waveY(wy + y, tangentAngle);
        } atWaveX:self.waveX];
    }
    if (self.wave) {
        [self.waveCounter wave:^(double x, double y, double tangentAngle) {
            wself.wave(x, wy + y, tangentAngle);
        }];
    }
    [self.waveCounter nextTime];
}

-(void)setWaveYCallback:(void(^)(double currentY, double tangentAngle))waveY atWaveX:(double)waveX {
    self.waveX = waveX;
    self.waveY = waveY;
}

-(void)setWaveCallback:(void(^)(double x, double y, double tangentAngle))wave {
    self.wave = wave;
}

-(CAShapeLayer *)waveLayer_fg {
    if (!_waveLayer_fg) {
        _waveLayer_fg = [CAShapeLayer layer];
        _waveLayer_fg.frame = self.waveFrame;
        _waveLayer_fg.fillColor = self.fgColor.CGColor;
    }
    return _waveLayer_fg;
}

-(CAShapeLayer *)waveLayer_bg {
    if (!_waveLayer_bg) {
        _waveLayer_bg = [CAShapeLayer layer];
        _waveLayer_bg.frame = self.waveFrame;
        _waveLayer_bg.fillColor = self.bgColor.CGColor;
    }
    return _waveLayer_bg;
}

-(WaveCounter *)waveCounter {
    if (!_waveCounter) {
        _waveCounter = [[WaveCounter alloc] initWithPeriod:self.wavePeriod speed:self.waveSpeed areaSize:self.waveFrame.size];
    }
    return _waveCounter;
}

@end




@implementation UIView (WaveAnimation)
static void* kWaveAnimationKey = @"_kWaveAnimationKey";

-(WaveAnimation *)waveAnimation {
    return objc_getAssociatedObject(self, kWaveAnimationKey);
}

-(void)setWaveAnimation:(WaveAnimation *)waveAnimation {
    objc_setAssociatedObject(self, kWaveAnimationKey, waveAnimation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

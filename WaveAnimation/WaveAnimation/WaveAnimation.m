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

@implementation UIView (WaveAnimation)
-(WaveAnimation *)waveAnimation {
    return objc_getAssociatedObject(self, @selector(waveAnimation));
}
-(void)setWaveAnimation:(WaveAnimation *)waveAnimation {
    objc_setAssociatedObject(self, @selector(waveAnimation), waveAnimation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end




@interface WaveAnimation ()
@property (nonatomic, readonly) WaveCounter *waveCounter;
@property (nonatomic, readonly) CAShapeLayer *waveLayer_fg;
@property (nonatomic, readonly) CAShapeLayer *waveLayer_bg;
@property (nonatomic, readonly) void(^waveY)(double y, double tangentAngle);
@property (nonatomic, readonly) void(^waveBuoy)(double x, double y, double tangentAngle);
@end

@implementation WaveAnimation
{
    CADisplayLink *_displayLink;
    __weak UIView *_view;
    UIColor *_fgColor;
    UIColor *_bgColor;
    double _waveX;
    double _waveBuoyMargin;
    double _waveBuoyNormalLineOffset;
}
@synthesize waveFrame = _waveFrame;
@synthesize wavePeriod = _wavePeriod;
@synthesize waveSpeed = _waveSpeed;
@synthesize waveCounter = _waveCounter;
@synthesize waveLayer_fg = _waveLayer_fg;
@synthesize waveLayer_bg = _waveLayer_bg;
@synthesize waveY = _waveY;
@synthesize waveBuoy = _waveBuoy;

-(instancetype)initWithView:(UIView*)view waveFrame:(CGRect)frame wavePeriod:(double)period waveSpeed:(double)speed {
    if (!view) {
        return nil;
    }
    self = [super init];
    if (self) {
        _waveFrame = CGRectEqualToRect(frame, CGRectZero)?view.bounds:frame;
        _wavePeriod = period;
        _waveSpeed = speed / 60.0;
        _view = view;
        _fgColor = [UIColor whiteColor];
        _bgColor = [UIColor colorWithWhite:1 alpha:0.5];
        [self addToView];
    }
    return self;
}

-(void)dealloc {
    [self removeFromView];
}

-(BOOL)didAdd {
    return _view.waveAnimation != nil;
}

-(void)addToView {
    if (![self didAdd]) {
        [_view.layer addSublayer:self.waveLayer_bg];
        [_view.layer addSublayer:self.waveLayer_fg];
        _view.waveAnimation = self;
    }
}

-(void)removeFromView {
    if ([self didAdd]) {
        [_waveLayer_fg removeFromSuperlayer];
        [_waveLayer_bg removeFromSuperlayer];
        _view.waveAnimation = nil;
    }
}

- (void)start {
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(doWave)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)stop {
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
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
    if (_waveY) {
        [self.waveCounter waveY:^(double y, double tangentAngle) {
            wself.waveY(wy + y, tangentAngle);
        } atWaveX:_waveX];
    }
    
    if (_waveBuoy) {
        [self.waveCounter waveBuoy:^(double x, double y, double tangentAngle) {
            wself.waveBuoy(x, wy + y, tangentAngle);
        } margin:_waveBuoyMargin normalLineOffset:_waveBuoyNormalLineOffset];
    }
    
    [self.waveCounter nextWithOffset:_waveSpeed];
}

-(void)setWaveYCallback:(void(^)(double y, double tangentAngle))waveY atWaveX:(double)waveX {
    _waveX = waveX;
    _waveY = waveY;
}

-(void)setWaveBuoyCallback:(void(^)(double x, double y, double tangentAngle))waveBuoy margin:(double)margin normalLineOffset:(double)normalLineOffset{
    _waveBuoy = waveBuoy;
    _waveBuoyMargin = margin;
    _waveBuoyNormalLineOffset = normalLineOffset;
}

-(CAShapeLayer *)waveLayer_fg {
    if (!_waveLayer_fg) {
        _waveLayer_fg = [CAShapeLayer layer];
        _waveLayer_fg.frame = _waveFrame;
        _waveLayer_fg.fillColor = _fgColor.CGColor;
    }
    return _waveLayer_fg;
}

-(CAShapeLayer *)waveLayer_bg {
    if (!_waveLayer_bg) {
        _waveLayer_bg = [CAShapeLayer layer];
        _waveLayer_bg.frame = _waveFrame;
        _waveLayer_bg.fillColor = _bgColor.CGColor;
    }
    return _waveLayer_bg;
}

-(WaveCounter *)waveCounter {
    if (!_waveCounter) {
        _waveCounter = [[WaveCounter alloc] initWithPeriod:_wavePeriod areaSize:_waveFrame.size];
    }
    return _waveCounter;
}

@end


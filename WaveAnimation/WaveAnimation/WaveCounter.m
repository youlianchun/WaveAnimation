//
//  WaveCounter.m
//  WaveAnimation
//
//  Created by YLCHUN on 2017/10/26.
//  Copyright © 2017年 YLCHUN. All rights reserved.
//

#import "WaveCounter.h"

@implementation WaveCounter {
    double _period;
    double _speed;
    CGSize _size;
    long double _offset;
}

-(instancetype)initWithPeriod:(double)period speed:(double)speed areaSize:(CGSize)size {
    self = [super init];
    if (self) {
        _period = period;
        _speed = speed;
        _size = size;
        _offset = 0;
    }
    return self;
}

-(void)nextTimePath:(void(^)(CGPathRef path1, CGPathRef path2))path waveY:(void(^)(double currentY))waveY atWaveX:(double)waveX {
    
    CGMutablePathRef path1 = CGPathCreateMutable();
    CGMutablePathRef path2 = CGPathCreateMutable();
    
    CGPathMoveToPoint(path1, NULL, 0, _size.height);
    CGPathMoveToPoint(path2, NULL, 0, _size.height);
    
    for (double x = 0; x <= _size.width; x++) {
        CGPathAddLineToPoint(path1, NULL, x, get_wave_y(_offset, x, _period, _size.height));
        CGPathAddLineToPoint(path2, NULL, x, get_wave_y(_offset*0.5, x, _period, _size.height));
    }
    
    CGPathAddLineToPoint(path1, NULL, _size.width, _size.height);
    CGPathAddLineToPoint(path2, NULL, _size.width, _size.height);
    
    CGPathAddLineToPoint(path1, NULL, 0, _size.height);
    CGPathAddLineToPoint(path2, NULL, 0, _size.height);
    
    CGPathCloseSubpath(path1);
    CGPathCloseSubpath(path2);
    
    path(path1, path2);
    
    if (waveY && (waveX >= 0 && waveX <= _size.width)) {
        waveY(get_wave_y(_offset, waveX, _period, _size.height));
    }
    
    _offset += _speed;
    
}

static double get_wave_y(double time_offset, double wave_x, double period, double amplitude) {
    double x = wave_x;
    double A = amplitude / 2.0;
    double O = ( 2 * M_PI ) / period;
    double P = -time_offset / 60.0;
    double b = -A;
    return sin_y(x, A, O, P, b);
}

/**
 y = Asin(ωx+φ)+b

 @param x x
 @param A 决定峰值（即纵向拉伸压缩的倍数)
 @param O (ω)：决定周期（最小正周期T=2π/∣ω∣）
 @param P (φ)：决定波形与X轴位置关系或横向移动距离（左加右减）
 @param b 表示波形在Y轴的位置关系或纵向移动距离（上加下减）
 @return y
 */
static double sin_y(double x, double A, double O, double P, double b) {
    return A * sin( O * x + P ) + b;
}

static double sin_y_angle(double x, double A, double O, double P) {
    return A * O * cos( O * x + P );
}

static CGPoint sin_y_center(double height, double x, double y, double angle) {
    double h_2 = height / 2;
    double cx = h_2 * sin(angle) + x;
    double cy = h_2 * cos(angle) + y - height;
    return CGPointMake(cx, cy);
}

@end

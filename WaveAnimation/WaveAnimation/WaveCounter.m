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

-(void)waveY:(void(^)(double y, double tangentAngle))waveY atWaveX:(double)waveX {
    if (waveY && (waveX >= 0 && waveX <= _size.width)) {
        double y, angle;
        get_wave(_offset, waveX, _period, _size.height, &y, &angle);
        waveY(y, angle);
    }
}

-(void)wavePath:(void(^)(CGPathRef path1, CGPathRef path2))path {
    
    CGMutablePathRef path1 = CGPathCreateMutable();
    CGMutablePathRef path2 = CGPathCreateMutable();
    
    CGPathMoveToPoint(path1, NULL, 0, _size.height);
    CGPathMoveToPoint(path2, NULL, 0, _size.height);
    
    for (int x = 0; x <= _size.width; x++) {
        double y1, y2;
        get_wave(_offset, x, _period, _size.height, &y1, NULL);
        get_wave(_offset * 0.5, x, _period, _size.height, &y2, NULL);
        
        CGPathAddLineToPoint(path1, NULL, x, y1);
        CGPathAddLineToPoint(path2, NULL, x, y2);
    }
    
    CGPathAddLineToPoint(path1, NULL, _size.width, _size.height);
    CGPathAddLineToPoint(path2, NULL, _size.width, _size.height);
    
    CGPathAddLineToPoint(path1, NULL, 0, _size.height);
    CGPathAddLineToPoint(path2, NULL, 0, _size.height);
    
    CGPathCloseSubpath(path1);
    CGPathCloseSubpath(path2);
    
    path(path1, path2);
}

-(void)nextTime {
    _offset += _speed;
}

-(void)wave:(void(^)(double x, double y, double tangentAngle))wave {
    double x;
    get_wave2(_offset, 0, _size.width, _size.width, &x);
    [self waveY:^(double y, double tangentAngle) {
        wave(x, y, tangentAngle);
    } atWaveX:x];
}

-(void)nextTimePath:(void(^)(CGPathRef path1, CGPathRef path2))path waveY:(void(^)(double y, double tangentAngle))waveY atWaveX:(double)waveX {
    
    [self wavePath:path];
    [self waveY:waveY atWaveX:waveX];

    [self nextTime];
}

static void get_wave(double wave_offset_x, double wave_x, double wave_t, double wave_a, double *wave_y, double *tangent_angle) {
    double x = wave_x;
    double A = wave_a / 2.0;
    double O = ( 2 * M_PI ) / wave_t;
    double P = -wave_offset_x / 60.0;
    if (wave_y) {
        double b = -A; //wave_offset_y
        *wave_y = sin_y(x, A, O, P, b);
    }
    if (tangent_angle) {
        *tangent_angle = sin_tangent_angle(x, A, O, P);
    }
}

// 待优化 获取当前时刻下波浪x的位置（小船水平位置）
static void get_wave2(double wave_offset_x, double wave_x, double wave_t, double wave_a, double *wave_y) {
    double x = wave_x;
    double A = wave_a / 2.0;
    double O = ( 2 * M_PI ) / wave_t;
    double P = -wave_offset_x / 60.0 / 10;
    double b = A;
    *wave_y = A * cos( O * x + P ) + b;
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

/**
 sin_tangent_angle

 @param x x
 @param A 决定峰值（即纵向拉伸压缩的倍数)
 @param O (ω)：决定周期（最小正周期T=2π/∣ω∣）
 @param P (φ)：决定波形与X轴位置关系或横向移动距离（左加右减）
 @return 切线与水平线(x轴)夹角
 */
static double sin_tangent_angle(double x, double A, double O, double P) {
    return A * O * cos( O * x + P );
}

/**
 sin_tangent_center

 @param height view height
 @param x x
 @param y y
 @param tangent_angle 切线与水平线(x轴)夹角
 @return view new center
 */
static CGPoint sin_tangent_center(double height, double x, double y, double tangent_angle) {
    double h_2 = height / 2;
    double cx = h_2 * sin(tangent_angle) + x;
    double cy = h_2 * cos(tangent_angle) + y - height;
    return CGPointMake(cx, cy);
}

@end

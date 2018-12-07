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
    CGSize _size;
    long double _offset;
}

-(instancetype)initWithPeriod:(double)period areaSize:(CGSize)size {
    self = [super init];
    if (self) {
        _period = period;
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

-(void)nextWithOffset:(double)offset {
    _offset += offset;
}

-(void)waveBuoy:(void(^)(double x, double y, double tangentAngle))buoy margin:(double)margin normalLineOffset:(double)normalLineOffset {
    double x = get_buoy_x(_offset / 10, _size.width, margin);
    double y, angle;
    get_wave(_offset, x, _period, _size.height, &y, &angle);
    get_buoy_point(x, y, angle, normalLineOffset, &x, &y);
    buoy(x, y, angle);
}


static void get_wave(double wave_offset_x, double wave_x, double wave_t, double wave_a, double *wave_y, double *tangent_angle) {
    double x = wave_x;
    double A = wave_a / 2.0;
    double O = ( 2 * M_PI ) / wave_t;
    double P = -wave_offset_x ;
    if (wave_y) {
        double b = -A; //wave_offset_y
        *wave_y = sin_ae(x, A, O, P, b);
    }
    if (tangent_angle) {
        *tangent_angle = sin_tangent_angle(x, A, O, P);
    }
}

// 获取当前时刻下波浪x的位置（浮标平位置）
static double get_buoy_x(double wave_offset_x, double wave_w, double margin) {
    double x = 0;
    double A = wave_w / 2.0 - margin;
    double O = ( 2 * M_PI ) / wave_w;
    double P = -wave_offset_x;
    double b = A + margin;
    return cos_ae(x, A, O, P, b);
}

// 获取浮标在法线方向上偏移后的新坐标
static void get_buoy_point(double x, double y, double tangent_angle, double normal_line_offset, double *nx, double *ny) {
    *nx = sin_ae(0, normal_line_offset, 0, tangent_angle, x);
    *ny = cos_ae(0, normal_line_offset, 0, tangent_angle, y - normal_line_offset * 2);
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
    return cos_ae(x, A * O , O, P, 0);
}

/**
 y = Acos(ωx+φ)+b
 
 @param x x
 @param A 决定峰值（即纵向拉伸压缩的倍数)
 @param O (ω)：决定周期（最小正周期T=2π/∣ω∣）
 @param P (φ)：决定波形与X轴位置关系或横向移动距离（左加右减）
 @param b 表示波形在Y轴的位置关系或纵向移动距离（上加下减）
 @return y
 */
static double cos_ae(double x, double A, double O, double P, double b) {
    return A * cos( O * x + P ) + b;
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
static double sin_ae(double x, double A, double O, double P, double b) {
    return A * sin( O * x + P ) + b;
}

@end

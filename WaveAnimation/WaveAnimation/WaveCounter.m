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

double get_wave_y(double time_offset, double wave_x, double period, double amplitude)
{
    return amplitude/2.0*(sinf(2*M_PI * wave_x/period + M_PI_2 - time_offset/60.0)+1);
}

@end

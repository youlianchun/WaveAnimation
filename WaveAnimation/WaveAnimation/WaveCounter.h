//
//  WaveCounter.h
//  WaveAnimation
//
//  Created by YLCHUN on 2017/10/26.
//  Copyright © 2017年 YLCHUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGPath.h>

@interface WaveCounter : NSObject

-(instancetype)initWithPeriod:(double)period areaSize:(CGSize)size;
-(void)waveY:(void(^)(double y, double tangentAngle))waveY atWaveX:(double)waveX;
-(void)wavePath:(void(^)(CGPathRef path1, CGPathRef path2))path;
-(void)waveBuoy:(void(^)(double x, double y, double tangentAngle))buoy margin:(double)margin normalLineOffset:(double)normalLineOffset;
-(void)nextWithOffset:(double)offset;

@end

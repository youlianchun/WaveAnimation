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

-(instancetype)initWithPeriod:(double)period speed:(double)speed areaSize:(CGSize)size;
-(void)waveY:(void(^)(double y, double tangentAngle))waveY atWaveX:(double)waveX;
-(void)wavePath:(void(^)(CGPathRef path1, CGPathRef path2))path;
-(void)wave:(void(^)(double x, double y, double tangentAngle))wave margin:(double)margin;
-(void)nextTime;
@end

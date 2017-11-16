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

-(void)nextTimePath:(void(^)(CGPathRef path1, CGPathRef path2))path waveY:(void(^)(double currentY))waveY atWaveX:(double)waveX;

@end

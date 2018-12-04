//
//  WaveAnimation.h
//  WaveAnimation
//
//  Created by YLCHUN on 2017/10/26.
//  Copyright © 2017年 YLCHUN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaveAnimation : NSObject

/**
 创建一个波浪动画

 @param view animation 所在View
 @param frame animation区域位置（View内的一个rect）其中 rect.size.height 为波浪的最高值
 @param period 周期（一个完整波浪的宽度）
 @param speed 速度
 @return <#return value description#>
 */
-(instancetype)initWithView:(UIView*)view waveFrame:(CGRect)frame wavePeriod:(double)period waveSpeed:(double)speed;

/**
 获取一点的波浪高度

 @param waveY callback
 @param waveX 高度所在x位置
 */
-(void)setWaveYCallback:(void(^)(double currentY))waveY atWaveX:(double)waveX ;

-(void)removeFromView;

- (void)start;
- (void)stop;

@end

@interface UIView (WaveAnimation)
@property (nonatomic, readonly) WaveAnimation *waveAnimation;
@end

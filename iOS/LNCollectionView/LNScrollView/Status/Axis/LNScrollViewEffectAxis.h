//
//  LNScrollViewEffectAxis.h
//  LNCollectionView
//
//  Created by Levison on 2025/12/11.
//

#import <Foundation/Foundation.h>
#import "LNScrollViewContextObject.h"

@class LNScrollViewRestStatusComponent;

NS_ASSUME_NONNULL_BEGIN

@interface LNScrollViewEffectAxis : NSObject

@property (nonatomic, weak, readonly) LNScrollViewContextObjectComponent *context;
@property (nonatomic, weak, readonly) LNScrollViewRestStatusComponent *restStatus;

//手势位移和offset的映射关系，对手势来说你只要给这一个映射关系就行了
//不需要记录任何值，全部动态计算
//可以从context中捕获到任何你需要的环境变量，如果他们不正确，可以不工作，直接返回gestureStartOffset
- (CGFloat)targetConvertedPositionFor:(CGFloat)gestureStartPosition
               gestureCurrentPosition:(CGFloat)gestureCurrentPosition
                   gestureStartOffset:(CGFloat)gestureStartOffset;

//开启自动响应
- (void)startAutoEffectIfNeeded:(BOOL)forcelyBounces;
//滚到某个位置
- (void)startScrollTo:(CGFloat)targetPosition;
//你一定需要一个累积时间的方法从而让你的响应不断进行下去直到结束
- (BOOL)accumulate:(NSTimeInterval)time;
//你需要提供一个强制停止自动响应的方法，通常他们在有新的手势开始的时候会需要你这么做
//记得将你所有可能影响下次响应的临时值reset掉
- (void)finishForcely;
//你需要提供一个标志函数来让外界感知到你是否已经结束了
//因为不可能永远把你放在时钟里
- (BOOL)isFinished;

@end

NS_ASSUME_NONNULL_END

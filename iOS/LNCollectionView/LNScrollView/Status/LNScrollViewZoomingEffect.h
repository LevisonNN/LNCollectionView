//
//  LNScrollViewZoomingEffect.h
//  LNCollectionView
//
//  Created by Levison on 12.12.25.
//

#import <Foundation/Foundation.h>
#import "LNScrollViewContextObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface LNScrollViewZoomingEffectStatus : NSObject

//起始的缩放比例
@property (nonatomic, assign, readonly) CGFloat originalScale;
//起始的偏移向量：从手势中心到targetView中心的向量
@property (nonatomic, assign, readonly) CGPoint offsetVector;
//中心点的位置，当前pinch手势中心点基于视窗口的真实位置
@property (nonatomic, assign, readonly) CGPoint realLocationForPinch;

//输出属性
@property (nonatomic, assign, readonly) CGPoint outputCenter;
@property (nonatomic, assign, readonly) CGSize outputContentSize;
@property (nonatomic, assign, readonly) CGPoint outputContentOffset;
@property (nonatomic, assign, readonly) CGAffineTransform outputTransform;

@end

@protocol LNScrollViewZoomingEffectDelegate <NSObject>

- (void)pinchEffectNeedSyncContentSize;
- (void)pinchEffectNeedSyncTransform;
- (void)pinchEffectNeedSyncTargetCenter;
- (void)pinchEffectNeedSyncContentOffset;

@end

@interface LNScrollViewZoomingEffect : NSObject

- (LNScrollViewZoomingEffectStatus *)getStatus;

@property (nonatomic, weak) NSObject<LNScrollViewZoomingEffectDelegate> *delegate;

- (instancetype)initWithContext:(LNScrollViewContextObject *)context;

- (void)startWithPinchCenter:(CGPoint)pinchCenter
        realLocationForPinch:(CGPoint)realLocationForPinch
                  pinchScale:(CGFloat)scale;
- (void)updateForPinch:(CGPoint)pinchCenter
  realLocationForPinch:(CGPoint)realLocationForPinch
            pinchScale:(CGFloat)scale
         numberOfPoint:(NSUInteger)numberOfPoint;
- (void)updateForFinishAnimation:(CGFloat)stableScale;
- (void)updateForAutoEffect:(CGFloat)stableScale;
- (void)finish;

@end

NS_ASSUME_NONNULL_END

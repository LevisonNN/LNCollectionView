//
//  LNScrollViewGestureEffect.h
//  LNCollectionView
//
//  Created by Levison on 9.11.24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class LNScrollViewGestureEffect;

typedef NS_ENUM(NSInteger, LNScrollViewGestureEffectBoundsType) {
    LNScrollViewGestureEffectBoundsVerticalLeading = 0,
    LNScrollViewGestureEffectBoundsHorizontalLeading = 1,
    LNScrollViewGestureEffectBoundsVerticalTrailing = 2,
    LNScrollViewGestureEffectBoundsHorizontalTrailing = 3,
};

@interface LNScrollViewGestureStatus: NSObject

@property (nonatomic, assign) CGPoint gestureStartPosition;
@property (nonatomic, assign) CGPoint startContentOffset;
@property (nonatomic, assign) CGPoint convertedOffset;

@end

@protocol LNScrollViewGestureEffectProtocol
- (void)gestureEffectStatusDidChange:(LNScrollViewGestureStatus *)status;
- (BOOL)gestureEffect:(LNScrollViewGestureEffect *)gestureEffect
     shouldOverBounds:(LNScrollViewGestureEffectBoundsType)boundsType;
@end

@interface LNScrollViewGestureEffect : NSObject

@property (nonatomic, weak) NSObject<LNScrollViewGestureEffectProtocol> *delegate;
 
- (void)startWithFrameSize:(CGSize)frameSize
               contentSize:(CGSize)contentSize
             currentOffset:(CGPoint)contentOffset
           gesturePosition:(CGPoint)gesturePosition;
- (void)updateGestureLocation:(CGPoint)location;
- (void)finish;

@end

NS_ASSUME_NONNULL_END

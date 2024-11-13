//
//  LNScrollViewGestureEffect.h
//  LNCollectionView
//
//  Created by Levison on 9.11.24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LNScrollViewGestureStatus: NSObject

@property (nonatomic, assign) CGPoint gestureStartPosition;
@property (nonatomic, assign) CGPoint startContentOffset;
@property (nonatomic, assign) CGPoint convertedOffset;

@end

@protocol LNScrollViewGestureEffectProtocol
- (void)gestureEffectStatusDidChange:(LNScrollViewGestureStatus *)status;
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

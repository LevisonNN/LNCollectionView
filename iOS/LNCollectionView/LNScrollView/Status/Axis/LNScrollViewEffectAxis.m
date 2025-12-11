//
//  LNScrollViewEffectAxis.m
//  LNCollectionView
//
//  Created by Levison on 2025/12/11.
//

#import "LNScrollViewEffectAxis.h"
#import "LNScrollViewAutoEffect.h"

@interface LNScrollViewEffectAxis()

@property (nonatomic, weak) LNScrollViewContextObjectComponent *context;
@property (nonatomic, weak) LNScrollViewRestStatusComponent *restStatus;

@end

@implementation LNScrollViewEffectAxis

- (CGFloat)targetConvertedPositionFor:(CGFloat)gestureStartPosition gestureCurrentPosition:(CGFloat)gestureCurrentPosition gestureStartOffset:(CGFloat)gestureStartOffset {
    return gestureStartOffset;
}

- (void)startAutoEffectIfNeeded {
    
}

- (void)startScrollTo:(CGFloat)targetPosition {
    
}

- (BOOL)accumulate:(NSTimeInterval)time {
    return NO;
}

- (void)finishForcely {
    
}

- (BOOL)isFinished {
    return YES;
}

@end

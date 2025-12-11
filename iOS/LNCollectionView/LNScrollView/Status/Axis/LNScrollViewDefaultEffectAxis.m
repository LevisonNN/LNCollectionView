//
//  LNScrollViewDefaultEffectAxis.m
//  LNCollectionView
//
//  Created by 李为 on 2025/12/11.
//

#import "LNScrollViewDefaultEffectAxis.h"
#import "LNScrollViewAutoEffect.h"
#import "LNScrollViewPageSimulator.h"
#import "LNScrollViewGestureConvertor.h"
#import "LNScrollViewScrollAnimationSimulator.h"

#define LNScrollViewDefaultEffectAxisTolerance 0.001f

@interface LNScrollViewDefaultEffectAxis()

@property (nonatomic, strong) LNScrollViewBounceSimulator *bounceSimulator;
@property (nonatomic, strong) LNScrollViewDecelerateSimulator *decelerateSimulator;
@property (nonatomic, strong) LNScrollViewPageSimulator *pageSimulator;
@property (nonatomic, strong) LNScrollViewScrollAnimationSimulator *scrollAnimationSimulator;

@property (nonatomic, assign) CGFloat pageDamping;

@property (nonatomic, strong) LNScrollViewGestureConvertor *gestureConvertor;

@end

@implementation LNScrollViewDefaultEffectAxis

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pageDamping = 20;
    }
    return self;
}

- (CGFloat)targetConvertedPositionFor:(CGFloat)gestureStartPosition
               gestureCurrentPosition:(CGFloat)gestureCurrentPosition gestureStartOffset:(CGFloat)gestureStartOffset {
    CGFloat leadingPoint = [self _leadingPoint];
    CGFloat trailingPoint = [self _trailingPoint];
    CGFloat convertedOffset = [self.gestureConvertor convertOffsetWith:gestureStartPosition
                                                gestureCurrentPosition:gestureCurrentPosition
                                                    gestureStartOffset:gestureStartOffset
                                                          leadingPoint:leadingPoint
                                                         trailingPoint:trailingPoint];
    if (convertedOffset < [self _leadingPoint] && [self _shouldOverBounds:NO] == false) {
        return [self _leadingPoint];
    } else if (convertedOffset > [self _trailingPoint] && [self _shouldOverBounds:YES] == false){
        return [self _trailingPoint];
    } else {
        return convertedOffset;
    }
}

- (void)startAutoEffectIfNeeded {
    [self _finish];
    [self _createSimulatorIfNeeded];
}

- (void)startScrollTo:(CGFloat)targetPosition {
    [self _finish];
    [self _createScrollAnimationSimulatorTo:targetPosition];
}

- (BOOL)accumulate:(NSTimeInterval)time {
    BOOL didStatusChange = NO;
    didStatusChange = [self _updateDecelerateSimulator:time] || didStatusChange;
    didStatusChange = [self _updateBounceSimulator:time] || didStatusChange;
    didStatusChange = [self _updatePageSimulator:time] || didStatusChange;
    didStatusChange = [self _updateScrollAnimationSimulator:time] || didStatusChange;
    [self _checkFinish];
    return didStatusChange;
}

- (void)finishForcely {
    [self _finish];
}

- (BOOL)isFinished {
    return [self _hasFinished];
}

//private
- (void)_createScrollAnimationSimulatorTo:(CGFloat)position {
    self.scrollAnimationSimulator = [[LNScrollViewScrollAnimationSimulator alloc] initWith:self.context.contentOffset endingPoint:position];
}

- (void)_createSimulatorIfNeeded
{
    if (self.restStatus.offset <= [self _leadingPoint] && self.restStatus.velocity < 0) {
        //超出前
        if ([self _shouldOverBounds:NO]) {
            [self _createBounceSimulator:NO];
        } else {
            self.restStatus.offset = [self _leadingPoint];
            if ([self _hasFeedBack:NO]) {
                CGFloat feedbackVelocity = [self.context.leadingGenerator generate:fabs(self.restStatus.velocity)];
                if (feedbackVelocity < -LNScrollViewDefaultEffectAxisTolerance) {
                    self.restStatus.velocity = -feedbackVelocity;
                    if (self.context.pageEnable) {
                        [self _createPageSimulator];
                    } else {
                        [self _createDecelerateSimulator];
                    }
                } else {
                    self.restStatus.velocity = 0;
                }
            } else {
                self.restStatus.velocity = 0;
            }
        }
        
    } else if (self.restStatus.offset >= [self _trailingPoint] && self.restStatus.velocity > 0) {
        if ([self _shouldOverBounds:YES]) {
            [self _createBounceSimulator:YES];
        } else {
            self.restStatus.offset = [self _trailingPoint];
            if ([self _hasFeedBack:YES]) {
                CGFloat feedbackVelocity = [self.context.trailingGenerator generate:fabs(self.restStatus.velocity)];
                if (feedbackVelocity < -LNScrollViewDefaultEffectAxisTolerance) {
                    self.restStatus.velocity = feedbackVelocity;
                    if (self.context.pageEnable) {
                        [self _createPageSimulator];
                    } else {
                        [self _createDecelerateSimulator];
                    }
                } else {
                    self.restStatus.velocity = 0;
                }
            } else {
                self.restStatus.velocity = 0;
            }
        }
    } else {
        if (self.context.pageEnable) {
            [self _createPageSimulator];
        } else {
            [self _createDecelerateSimulator];
        }
    }
}

- (void)_checkFinish
{
    if ([self _hasFinished]) {
        [self _finish];
    }
}

- (BOOL)_hasFinished
{
    if (self.decelerateSimulator &&
        !self.decelerateSimulator.isFinished) {
        return NO;
    }
    if (self.bounceSimulator &&
        !self.bounceSimulator.isFinished) {
        return NO;
    }
    if (self.pageSimulator &&
        !self.pageSimulator.isFinished) {
        return NO;
    }
    if (self.scrollAnimationSimulator &&
        !self.scrollAnimationSimulator.isFinished) {
        return NO;
    }
    return YES;
}

- (void)_finish
{
    self.bounceSimulator = nil;
    self.decelerateSimulator = nil;
    self.pageSimulator = nil;
    self.scrollAnimationSimulator = nil;
}

//Update simulators
- (BOOL)_updateDecelerateSimulator:(NSTimeInterval)time
{
    if (self.decelerateSimulator) {
        [self.decelerateSimulator accumulate:time];
        self.restStatus.velocity = self.decelerateSimulator.velocity;
        self.restStatus.offset = self.decelerateSimulator.position;
        if (self.restStatus.offset <= [self _leadingPoint]) {
            self.decelerateSimulator = nil;
            if ([self _shouldOverBounds:NO]) {
                [self _createBounceSimulator:NO];
            } else {
                self.restStatus.offset = [self _leadingPoint];
                if ([self _hasFeedBack:NO]) {
                    CGFloat feedbackVelocity = [self.context.leadingGenerator generate:fabs(self.restStatus.velocity)];
                    if (feedbackVelocity < -LNScrollViewDefaultEffectAxisTolerance) {
                        self.restStatus.velocity = -feedbackVelocity;
                        if (self.context.pageEnable) {
                            [self _createPageSimulator];
                        } else {
                            [self _createDecelerateSimulator];
                        }
                    } else {
                        self.restStatus.velocity = 0;
                    }
                } else {
                    self.restStatus.velocity = 0;
                }
            }
        } else if (self.restStatus.offset >= [self _trailingPoint]) {
            self.decelerateSimulator = nil;
            if ([self _shouldOverBounds:YES]) {
                [self _createBounceSimulator:YES];
            } else {
                self.restStatus.offset = [self _trailingPoint];
                if ([self _hasFeedBack:YES]) {
                    CGFloat feedbackVelocity = [self.context.trailingGenerator generate:fabs(self.restStatus.velocity)];
                    if (feedbackVelocity < -LNScrollViewDefaultEffectAxisTolerance) {
                        self.restStatus.velocity = feedbackVelocity;
                        if (self.context.pageEnable) {
                            [self _createPageSimulator];
                        } else {
                            [self _createDecelerateSimulator];
                        }
                    } else {
                        self.restStatus.velocity = 0;
                    }
                } else {
                    self.restStatus.velocity = 0;
                }
            }
        } else if (self.decelerateSimulator.isFinished) {
            self.decelerateSimulator = nil;
        }
        return YES;
    }
    return NO;
}

- (BOOL)_updateBounceSimulator:(NSTimeInterval)time
{
    if (self.bounceSimulator) {
        [self.bounceSimulator accumulate:time];
        self.restStatus.velocity = self.bounceSimulator.velocity;
        self.restStatus.offset = self.bounceSimulator.position;
        if (self.bounceSimulator.isFinished) {
            self.bounceSimulator = nil;
          }
        return YES;
    }
    return NO;
}

- (BOOL)_updatePageSimulator:(NSTimeInterval)time
{
    if (self.pageSimulator) {
        [self.pageSimulator accumulate:time];
        self.restStatus.velocity = self.pageSimulator.velocity;
        self.restStatus.offset = self.pageSimulator.position;
        if (self.pageSimulator.isFinished) {
            self.pageSimulator = nil;
          }
        return YES;
    }
    return NO;
}

- (BOOL)_updateScrollAnimationSimulator:(NSTimeInterval)time
{
    if (self.scrollAnimationSimulator) {
        [self.scrollAnimationSimulator accumulate:time];
        self.restStatus.offset = self.scrollAnimationSimulator.currentPosition;
        if (self.scrollAnimationSimulator.isFinished) {
            self.scrollAnimationSimulator = nil;
        }
        return YES;
    }
    return NO;
}

//Create simulators
- (void)_createBounceSimulator:(BOOL)isTrailing
{
    CGFloat targetPosition = isTrailing? self._trailingPoint : self._leadingPoint;
    self.bounceSimulator = [[LNScrollViewBounceSimulator alloc] initWithPosition:self.restStatus.offset
                                                                              velocity:self.restStatus.velocity
                                                                        targetPosition:targetPosition];
}

- (void)_createDecelerateSimulator {
    self.decelerateSimulator = [[LNScrollViewDecelerateSimulator alloc] initWithPosition:self.restStatus.offset
                                                         velocity:self.restStatus.velocity];
}

- (void)_createPageSimulator
{
    CGFloat pageSize = self.context.frameSize;
    NSInteger pageIndex = floor(self.restStatus.offset/pageSize);
    CGFloat restOffset = self.restStatus.offset - pageIndex * pageSize;
    if (restOffset < pageSize/2.f) {
        if (self.restStatus.velocity <= 0) {
            CGFloat targetPosition = [self _validPositionForHorizontalPage:pageIndex];
            [self _createPageSimulatorTo:targetPosition];
        } else {
            CGFloat targetOffset =
            [LNScrollViewPageSimulator targetOffsetWithVelocity:self.restStatus.velocity
                                                         offset:restOffset
                                                        damping:self.pageDamping];
            if (targetOffset > pageSize/2.f) {
                CGFloat targetPosition = [self _validPositionForHorizontalPage:pageIndex + 1];
                [self _createPageSimulatorTo:targetPosition];
            } else {
                CGFloat targetPosition = [self _validPositionForHorizontalPage:pageIndex];
                [self _createPageSimulatorTo:targetPosition];
            }
        }
    } else {
        if (self.restStatus.velocity >= 0) {
            CGFloat targetPosition = [self _validPositionForHorizontalPage:pageIndex + 1];
            [self _createPageSimulatorTo:targetPosition];
        } else {
            CGFloat targetOffset =
            [LNScrollViewPageSimulator targetOffsetWithVelocity:self.restStatus.velocity
                                                         offset:restOffset
                                                        damping:self.pageDamping];
            if (targetOffset < -pageSize/2.f) {
                CGFloat targetPosition = [self _validPositionForHorizontalPage:pageIndex];
                [self _createPageSimulatorTo:targetPosition];
            } else {
                CGFloat targetPosition = [self _validPositionForHorizontalPage:pageIndex + 1];
                [self _createPageSimulatorTo:targetPosition];
            }
        }
    }
}

- (CGFloat)_validPositionForHorizontalPage:(NSInteger)pageIndex
{
    CGFloat pageSize = self.context.frameSize;
    CGFloat targetPosition = MAX([self _leadingPoint], MIN(pageIndex * pageSize, [self _trailingPoint]));
    return targetPosition;
}

- (void)_createPageSimulatorTo:(CGFloat)targetPosition {
    self.pageSimulator =
    [[LNScrollViewPageSimulator alloc] initWithPosition:self.restStatus.offset
                                               velocity:self.restStatus.velocity
                                         targetPosition:targetPosition
                                                damping:self.pageDamping];
}

//Tools
- (CGFloat)_leadingPoint {
    return -self.context.leadingInset;
}

- (CGFloat)_trailingPoint {
    return MAX([self _leadingPoint], self.context.contentSize - self.context.frameSize + self.context.trailingInset) ;
}

- (BOOL)_shouldOverBounds:(BOOL)isTrailing {
    if (self.context.bounces == NO) {
        return NO;
    }
    if (self.context.contentSize <= self.context.frameSize) {
        return NO;
    }
    return ![self _hasFeedBack:isTrailing];
}

- (BOOL)_hasFeedBack:(BOOL)isTrailing {
    if (isTrailing) {
        if (self.context.trailingGenerator.isOpen) {
            return YES;
        } else {
            return NO;
        }
    } else {
        if (self.context.leadingGenerator.isOpen) {
            return YES;
        } else {
            return NO;
        }
    }
}

- (LNScrollViewGestureConvertor *)gestureConvertor {
    if (!_gestureConvertor) {
        _gestureConvertor = [[LNScrollViewGestureConvertor alloc] init];
    }
    return _gestureConvertor;
}

@end

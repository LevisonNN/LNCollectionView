//
//  LNScrollViewAutoEffect.m
//  LNCollectionView
//
//  Created by Levison on 9.11.24.
//

#import "LNScrollViewAutoEffect.h"
#import "LNScrollViewBounceSimulator.h"
#import "LNScrollViewDecelerateSimulator.h"
#import <UIKit/UIKit.h>
#import "LNScrollViewClock.h"
#import "LNScrollViewPageSimulator.h"

#define LNScrollViewAutoEffectCommonTolerance 0.001f

@interface LNScrollViewRestStatus()
@property (nonatomic, assign) CGPoint leadingPoint;
@property (nonatomic, assign) CGPoint trailingPoint;
@property (nonatomic, assign) CGPoint velocity;
@property (nonatomic, assign) CGPoint offset;

@property (nonatomic, assign) CGPoint startPosition;
@end

@implementation LNScrollViewRestStatus
@end

@interface LNScrollViewAutoEffect() <LNScrollViewClockProtocol>

@property (nonatomic, weak) LNScrollViewContextObject *context;

@property (nonatomic, strong) LNScrollViewBounceSimulator *horizontalBounceSimulator;
@property (nonatomic, strong) LNScrollViewBounceSimulator *verticalBounceSimulator;

@property (nonatomic, strong) LNScrollViewDecelerateSimulator *horizontalDecelerateSimulator;
@property (nonatomic, strong) LNScrollViewDecelerateSimulator *verticalDecelerateSimulator;

@property (nonatomic, strong) LNScrollViewPageSimulator *horizontalPageSimulator;
@property (nonatomic, strong) LNScrollViewPageSimulator *verticalPageSimulator;

@property (nonatomic, strong) LNScrollViewRestStatus *restStatus;

@end

@implementation LNScrollViewAutoEffect

- (instancetype)initWithContext:(LNScrollViewContextObject *)context
{
    self = [super init];
    if (self) {
        self.context = context;
        self.pageDamping = 20;
    }
    return self;
}

- (void)dealloc
{
}

- (BOOL)startWithVelocity:(CGPoint)velocity {
    [self finish];
    [LNScrollViewClock.shareInstance addObject:self];
    CGSize contentSize = self.context.contentSize;
    CGSize frameSize = self.context.frameSize;
    CGPoint contentOffset = self.context.contentOffset;
    self.restStatus = [[LNScrollViewRestStatus alloc] init];
    self.restStatus.velocity = velocity;
    self.restStatus.startPosition = contentOffset;
    CGFloat leadingX = 0;
    CGFloat trailingX = contentSize.width - frameSize.width;
    CGFloat leadingY = 0;
    CGFloat trailingY = contentSize.height - frameSize.height;
    self.restStatus.leadingPoint = CGPointMake(leadingX, leadingY);
    self.restStatus.trailingPoint = CGPointMake(trailingX, trailingY);
    self.restStatus.offset = contentOffset;

    [self createHorizontalSimulatorIfNeeded];
    [self createVerticalSimulatorIfNeeded];
    return NO;
}

- (BOOL)updateHorizontalDecelerateSimulator:(NSTimeInterval)time
{
    if (self.horizontalDecelerateSimulator) {
        [self.horizontalDecelerateSimulator accumulate:time];
        self.restStatus.velocity = CGPointMake(self.horizontalDecelerateSimulator.velocity, self.restStatus.velocity.y);
        self.restStatus.offset = CGPointMake(self.horizontalDecelerateSimulator.position, self.restStatus.offset.y);
        if (self.restStatus.offset.x <= self.restStatus.leadingPoint.x) {
            self.horizontalDecelerateSimulator = nil;
            if ([self shouldOverBounds:LNScrollViewGestureEffectBoundsHorizontalLeading]) {
                self.horizontalBounceSimulator =
                [[LNScrollViewBounceSimulator alloc] initWithPosition:self.restStatus.offset.x
                                                             velocity:self.restStatus.velocity.x
                                                       targetPosition:self.restStatus.leadingPoint.x];
            } else {
                self.restStatus.offset = CGPointMake(self.restStatus.leadingPoint.x, self.restStatus.offset.y);
                if ([self needFeedback:LNScrollViewGestureEffectBoundsHorizontalLeading]) {
                    CGFloat feedbackVelocity = [self.context.leftPulseGenerator generate:fabs(self.restStatus.velocity.x)];
                    if (feedbackVelocity < -LNScrollViewAutoEffectCommonTolerance) {
                        self.restStatus.velocity = CGPointMake(-feedbackVelocity, self.restStatus.velocity.y);
                        if (self.context.pageEnable) {
                            [self createHorizontalPageSimulator];
                        } else {
                            [self createHorizontalDecelerateSimulator];
                        }
                    } else {
                        self.restStatus.velocity = CGPointMake(0.f, self.restStatus.velocity.y);
                    }
                } else {
                    self.restStatus.velocity = CGPointMake(0.f, self.restStatus.velocity.y);
                }
            }
        } else if (self.restStatus.offset.x >= self.restStatus.trailingPoint.x) {
            self.horizontalDecelerateSimulator = nil;
            if ([self shouldOverBounds:LNScrollViewGestureEffectBoundsHorizontalTrailing]) {
                self.horizontalBounceSimulator =
                [[LNScrollViewBounceSimulator alloc] initWithPosition:self.restStatus.offset.x
                                                             velocity:self.restStatus.velocity.x
                                                       targetPosition:self.restStatus.trailingPoint.x];
            } else {
                self.restStatus.offset = CGPointMake(self.restStatus.trailingPoint.x, self.restStatus.offset.y);
                if ([self needFeedback:LNScrollViewGestureEffectBoundsHorizontalTrailing]) {
                    CGFloat feedbackVelocity = [self.context.rightPulseGenerator generate:fabs(self.restStatus.velocity.x)];
                    if (feedbackVelocity < -LNScrollViewAutoEffectCommonTolerance) {
                        self.restStatus.velocity = CGPointMake(feedbackVelocity, self.restStatus.velocity.y);
                        if (self.context.pageEnable) {
                            [self createHorizontalPageSimulator];
                        } else {
                            [self createHorizontalDecelerateSimulator];
                        }
                    } else {
                        self.restStatus.velocity = CGPointMake(0.f, self.restStatus.velocity.y);
                    }
                } else {
                    self.restStatus.velocity = CGPointMake(0.f, self.restStatus.velocity.y);
                }
            }
        } else if (self.horizontalDecelerateSimulator.isFinished) {
            self.horizontalDecelerateSimulator = nil;
        }
        return YES;
    }
    return NO;
}

- (BOOL)updateHorizontalBounceSimulator:(NSTimeInterval)time
{
    if (self.horizontalBounceSimulator) {
          [self.horizontalBounceSimulator accumulate:time];
          self.restStatus.velocity = CGPointMake(self.horizontalBounceSimulator.velocity, self.restStatus.velocity.y);
          self.restStatus.offset = CGPointMake(self.horizontalBounceSimulator.position, self.restStatus.offset.y);
          if (self.horizontalBounceSimulator.isFinished) {
              self.horizontalBounceSimulator = nil;
          }
        return YES;
    }
    return NO;
}

- (BOOL)updateHorizontalPageSimulator:(NSTimeInterval)time
{
    if (self.horizontalPageSimulator) {
          [self.horizontalPageSimulator accumulate:time];
          self.restStatus.velocity = CGPointMake(self.horizontalPageSimulator.velocity, self.restStatus.velocity.y);
          self.restStatus.offset = CGPointMake(self.horizontalPageSimulator.position, self.restStatus.offset.y);
          if (self.horizontalPageSimulator.isFinished) {
              self.horizontalPageSimulator = nil;
          }
        return YES;
    }
    return NO;
}

- (BOOL)updateVerticalDecelerateSimulator:(NSTimeInterval)time
{
    if (self.verticalDecelerateSimulator) {
        [self.verticalDecelerateSimulator accumulate:time];
        self.restStatus.offset = CGPointMake(self.restStatus.offset.x, self.verticalDecelerateSimulator.position);
        self.restStatus.velocity = CGPointMake(self.restStatus.velocity.x, self.verticalDecelerateSimulator.velocity);
        if (self.restStatus.offset.y <= self.restStatus.leadingPoint.y) {
            //减速到头了
            self.verticalDecelerateSimulator = nil;
            if ([self shouldOverBounds:LNScrollViewGestureEffectBoundsVerticalLeading]) {
                //可以越界，直接启用Bounces
                self.verticalBounceSimulator =
                [[LNScrollViewBounceSimulator alloc] initWithPosition:self.restStatus.offset.y
                                                             velocity:self.restStatus.velocity.x
                                                       targetPosition:self.restStatus.leadingPoint.y];
            } else {
                self.restStatus.offset = CGPointMake(self.restStatus.offset.x, self.restStatus.leadingPoint.y);
                if  ([self needFeedback:LNScrollViewGestureEffectBoundsVerticalLeading]) {
                    //如果pulser可以接收
                    CGFloat feedbackVelocity = [self.context.topPulseGenerator generate:fabs(self.restStatus.velocity.y)];
                    if (feedbackVelocity < -LNScrollViewAutoEffectCommonTolerance) {
                        self.restStatus.velocity = CGPointMake(self.restStatus.velocity.x, -feedbackVelocity);
                        if (self.context.pageEnable) {
                            [self createVerticalPageSimulator];
                        } else {
                            [self createVerticalDecelerateSimulator];
                        }
                    } else {
                        //静止在边界处
                        self.restStatus.velocity = CGPointMake(self.restStatus.velocity.x, 0);
                    }
                } else {
                    //静止在边界处
                    self.restStatus.velocity = CGPointMake(self.restStatus.velocity.x, 0);
                }
            }
        } else if (self.restStatus.offset.y >= self.restStatus.trailingPoint.y) {
            self.verticalDecelerateSimulator = nil;
            if ([self shouldOverBounds:LNScrollViewGestureEffectBoundsVerticalTrailing]) {
                self.verticalBounceSimulator =
                [[LNScrollViewBounceSimulator alloc] initWithPosition:self.restStatus.offset.y
                                                             velocity:self.restStatus.velocity.y
                                                       targetPosition:self.restStatus.trailingPoint.y];
            } else {
                self.restStatus.offset = CGPointMake(self.restStatus.offset.x, self.restStatus.trailingPoint.y);
                if ([self needFeedback:LNScrollViewGestureEffectBoundsVerticalTrailing]) {
                    CGFloat feedbackVelocity = [self.context.bottomPulseGenerator generate:fabs(self.restStatus.velocity.y)];
                    if (feedbackVelocity < -LNScrollViewAutoEffectCommonTolerance) {
                        self.restStatus.velocity = CGPointMake(self.restStatus.velocity.x, feedbackVelocity);
                        if (self.context.pageEnable) {
                            [self createVerticalPageSimulator];
                        } else {
                            [self createVerticalDecelerateSimulator];
                        }
                    } else {
                        self.restStatus.velocity = CGPointMake(self.restStatus.velocity.x, 0);
                    }
                } else {
                    self.restStatus.velocity = CGPointMake(self.restStatus.velocity.x, 0);
                }
            }
        } else if (self.verticalDecelerateSimulator.isFinished) {
            self.verticalDecelerateSimulator = nil;
        } else {
            //在中间继续走
        }
        return YES;
    }
    return NO;
}

- (BOOL)updateVerticalBounceSimulator:(NSTimeInterval)time
{
    if (self.verticalBounceSimulator) {
        [self.verticalBounceSimulator accumulate:time];
        self.restStatus.velocity = CGPointMake(self.restStatus.velocity.x, self.verticalBounceSimulator.velocity);
        self.restStatus.offset = CGPointMake(self.restStatus.offset.x, self.verticalBounceSimulator.position);
        if (self.verticalBounceSimulator.isFinished) {
            self.verticalBounceSimulator = nil;
        }
        return YES;
    }
    return NO;
}

- (BOOL)updateVerticalPageSimulator:(NSTimeInterval)time
{
    if (self.verticalPageSimulator) {
        [self.verticalPageSimulator accumulate:time];
        self.restStatus.velocity = CGPointMake(self.restStatus.velocity.x, self.verticalPageSimulator.velocity);
        self.restStatus.offset = CGPointMake(self.restStatus.offset.x, self.verticalPageSimulator.position);
        if (self.verticalPageSimulator.isFinished) {
            self.verticalPageSimulator = nil;
        }
        return YES;
    }
    return NO;
}

- (void)scrollViewClockUpdateTimeInterval:(NSTimeInterval)time
{
    BOOL didStatusChange = NO;
    didStatusChange = [self updateVerticalDecelerateSimulator:time] || didStatusChange;
    didStatusChange = [self updateVerticalBounceSimulator:time] || didStatusChange;
    didStatusChange = [self updateVerticalPageSimulator:time] || didStatusChange;
    didStatusChange = [self updateHorizontalDecelerateSimulator:time] || didStatusChange;
    didStatusChange = [self updateHorizontalBounceSimulator:time] || didStatusChange;
    didStatusChange = [self updateHorizontalPageSimulator:time] || didStatusChange;
   
    if (didStatusChange && self.delegate && [self.delegate respondsToSelector:@selector(autoEffectStatusDidChange:)]) {
        [self.delegate autoEffectStatusDidChange:self.restStatus];
    }
    [self checkFinished];
}

- (void)checkFinished
{
    if ([self hasFinished]) {
        [self finish];
        if (self.delegate && [self.delegate respondsToSelector:@selector(autoEffectStatusHasFinished:)]) {
            [self.delegate autoEffectStatusHasFinished:self];
        }
    }
}

- (BOOL)hasFinished
{
    if (self.horizontalDecelerateSimulator &&
        !self.horizontalDecelerateSimulator.isFinished) {
        return NO;
    }
    if (self.horizontalBounceSimulator &&
        !self.horizontalBounceSimulator.isFinished) {
        return NO;
    }
    if (self.verticalDecelerateSimulator &&
        !self.verticalDecelerateSimulator.isFinished) {
        return NO;
    }
    if (self.verticalBounceSimulator &&
        !self.verticalBounceSimulator.isFinished) {
        return NO;
    }
    if (self.verticalPageSimulator &&
        !self.verticalPageSimulator.isFinished) {
        return NO;
    }
    if (self.horizontalPageSimulator &&
        !self.horizontalPageSimulator.isFinished) {
        return NO;
    }
    return YES;
}
- (void)finishForcely
{
    [self finish];
}

- (void)finish
{
    self.horizontalBounceSimulator = nil;
    self.horizontalDecelerateSimulator = nil;
    self.horizontalPageSimulator = nil;
    self.verticalBounceSimulator = nil;
    self.verticalDecelerateSimulator = nil;
    self.verticalPageSimulator = nil;
    self.restStatus = nil;
    [LNScrollViewClock.shareInstance removeObject:self];
}

- (BOOL)isFinished {
    return [self hasFinished];
}

- (void)createHorizontalBounceSimulator:(BOOL)isTrailing
{
    CGFloat targetPosition = isTrailing? self.restStatus.trailingPoint.x : self.restStatus.leadingPoint.x;
    self.horizontalBounceSimulator =
    [[LNScrollViewBounceSimulator alloc] initWithPosition:self.restStatus.startPosition.x
                                                 velocity:self.restStatus.velocity.x
                                           targetPosition:targetPosition];
}

- (void)createHorizontalDecelerateSimulator
{
    self.horizontalDecelerateSimulator = [[LNScrollViewDecelerateSimulator alloc] initWithPosition:self.restStatus.startPosition.x
                                                         velocity:self.restStatus.velocity.x];
}

- (void)createHorizontalPageSimulatorTo:(CGFloat)targetPosition
{
    self.horizontalPageSimulator =
    [[LNScrollViewPageSimulator alloc] initWithPosition:self.restStatus.startPosition.x
                                               velocity:self.restStatus.velocity.x
                                         targetPosition:targetPosition
                                                damping:self.pageDamping];
}

- (CGFloat)validPositionForHorizontalPage:(NSInteger)pageIndex
{
    CGFloat pageSize = self.context.frameSize.width;
    CGFloat targetPosition = MAX(self.restStatus.leadingPoint.x, MIN(pageIndex * pageSize, self.restStatus.trailingPoint.x));
    return targetPosition;
}

- (void)createHorizontalPageSimulator
{
    CGFloat pageSize = self.context.frameSize.width;
    NSInteger pageIndex = floor(self.restStatus.startPosition.x/pageSize);
    CGFloat restOffset = self.restStatus.startPosition.x - pageIndex * pageSize;
    if (restOffset < pageSize/2.f) {
        if (self.restStatus.velocity.x <= 0) {
            CGFloat targetPosition = [self validPositionForHorizontalPage:pageIndex];
            [self createHorizontalPageSimulatorTo:targetPosition];
        } else {
            CGFloat targetOffset =
            [LNScrollViewPageSimulator targetOffsetWithVelocity:self.restStatus.velocity.x
                                                         offset:restOffset
                                                        damping:self.pageDamping];
            if (targetOffset > pageSize/2.f) {
                CGFloat targetPosition = [self validPositionForHorizontalPage:pageIndex + 1];
                [self createHorizontalPageSimulatorTo:targetPosition];
            } else {
                CGFloat targetPosition = [self validPositionForHorizontalPage:pageIndex];
                [self createHorizontalPageSimulatorTo:targetPosition];
            }
        }
    } else {
        if (self.restStatus.velocity.x >= 0) {
            CGFloat targetPosition = [self validPositionForHorizontalPage:pageIndex + 1];
            [self createHorizontalPageSimulatorTo:targetPosition];
        } else {
            CGFloat targetOffset =
            [LNScrollViewPageSimulator targetOffsetWithVelocity:self.restStatus.velocity.x
                                                         offset:restOffset
                                                        damping:self.pageDamping];
            if (targetOffset < -pageSize/2.f) {
                CGFloat targetPosition = [self validPositionForHorizontalPage:pageIndex];
                [self createHorizontalPageSimulatorTo:targetPosition];
            } else {
                CGFloat targetPosition = [self validPositionForHorizontalPage:pageIndex + 1];
                [self createHorizontalPageSimulatorTo:targetPosition];
            }
        }
    }
}


- (void)createVerticalBounceSimulator:(BOOL)isTrailing
{
    CGFloat targetPosition = isTrailing? self.restStatus.trailingPoint.y : self.restStatus.leadingPoint.y;
    self.verticalBounceSimulator = [[LNScrollViewBounceSimulator alloc] initWithPosition:self.restStatus.startPosition.y
                                                                              velocity:self.restStatus.velocity.y
                                                                        targetPosition:targetPosition];
}

- (void)createVerticalDecelerateSimulator
{
    self.verticalDecelerateSimulator = [[LNScrollViewDecelerateSimulator alloc] initWithPosition:self.restStatus.startPosition.y
                                                         velocity:self.restStatus.velocity.y];
}

- (void)createVerticalPageSimulatorTo:(CGFloat)targetPosition
{
    self.verticalPageSimulator =
    [[LNScrollViewPageSimulator alloc] initWithPosition:self.restStatus.startPosition.y
                                               velocity:self.restStatus.velocity.y
                                         targetPosition:targetPosition
                                                damping:self.pageDamping];
}


- (CGFloat)validPositionForVerticalPage:(NSInteger)pageIndex
{
    CGFloat pageSize = self.context.frameSize.height;
    CGFloat targetPosition = MAX(self.restStatus.leadingPoint.y, MIN(pageIndex *pageSize, self.restStatus.trailingPoint.y));
    return targetPosition;
}

- (void)createVerticalPageSimulator
{
    CGFloat pageSize = self.context.frameSize.height;
    NSInteger pageIndex = floor(self.restStatus.startPosition.y/pageSize);
    CGFloat restOffset = self.restStatus.startPosition.y - pageIndex * pageSize;
    if (restOffset < pageSize/2.f) {
        if (self.restStatus.velocity.y <= 0) {
            CGFloat targetPosition = [self validPositionForVerticalPage:pageIndex];
            [self createVerticalPageSimulatorTo:targetPosition];
        } else {
            CGFloat targetOffset =
            [LNScrollViewPageSimulator targetOffsetWithVelocity:self.restStatus.velocity.y
                                                         offset:restOffset
                                                        damping:self.pageDamping];
            if (targetOffset > pageSize/2.f) {
                CGFloat targetPosition = [self validPositionForVerticalPage:pageIndex + 1];
                [self createVerticalPageSimulatorTo:targetPosition];
            } else {
                CGFloat targetPosition = [self validPositionForVerticalPage:pageIndex];
                [self createVerticalPageSimulatorTo:targetPosition];
            }
        }
    } else {
        if (self.restStatus.velocity.y >= 0) {
            CGFloat targetPosition = [self validPositionForVerticalPage:pageIndex + 1];
            [self createVerticalPageSimulatorTo:targetPosition];
        } else {
            CGFloat targetOffset =
            [LNScrollViewPageSimulator targetOffsetWithVelocity:self.restStatus.velocity.y
                                                         offset:restOffset
                                                        damping:self.pageDamping];
            if (targetOffset < -pageSize/2.f) {
                CGFloat targetPosition = [self validPositionForVerticalPage:pageIndex];
                [self createVerticalPageSimulatorTo:targetPosition];
            } else {
                CGFloat targetPosition = [self validPositionForVerticalPage:pageIndex + 1];
                [self createVerticalPageSimulatorTo:targetPosition];
            }
        }
    }
}

- (void)createHorizontalSimulatorIfNeeded
{
    if (self.context.contentSize.width > self.context.frameSize.width + LNScrollViewAutoEffectCommonTolerance) {
        if (self.restStatus.startPosition.x <= self.restStatus.leadingPoint.x && self.restStatus.velocity.x < 0) {
            //超出左边界了
            if ([self shouldOverBounds:LNScrollViewGestureEffectBoundsHorizontalLeading]) {
                [self createHorizontalBounceSimulator:NO];
            } else {
                self.restStatus.offset = CGPointMake(self.restStatus.leadingPoint.x, self.restStatus.offset.y);
                if ([self needFeedback:LNScrollViewGestureEffectBoundsHorizontalLeading]) {
                    CGFloat feedbackVelocity = [self.context.leftPulseGenerator generate:fabs(self.restStatus.velocity.x)];
                    if (feedbackVelocity < -LNScrollViewAutoEffectCommonTolerance) {
                        self.restStatus.velocity = CGPointMake(-feedbackVelocity, self.restStatus.velocity.y);
                        if (self.context.pageEnable) {
                            [self createHorizontalPageSimulator];
                        } else {
                            [self createHorizontalDecelerateSimulator];
                        }
                    } else {
                        self.restStatus.velocity = CGPointMake(0, self.restStatus.velocity.y);
                    }
                } else {
                    self.restStatus.velocity = CGPointMake(0, self.restStatus.velocity.y);
                }
            }
            
        } else if (self.restStatus.startPosition.x >= self.restStatus.trailingPoint.x && self.restStatus.velocity.x > 0) {
            if ([self shouldOverBounds:LNScrollViewGestureEffectBoundsHorizontalTrailing]) {
                [self createHorizontalBounceSimulator:YES];
            } else {
                self.restStatus.offset = CGPointMake(self.restStatus.trailingPoint.x, self.restStatus.offset.y);
                if ([self needFeedback:LNScrollViewGestureEffectBoundsHorizontalTrailing]) {
                    CGFloat feedbackVelocity = [self.context.rightPulseGenerator generate:fabs(self.restStatus.velocity.x)];
                    if (feedbackVelocity < -LNScrollViewAutoEffectCommonTolerance) {
                        self.restStatus.velocity = CGPointMake(feedbackVelocity, self.restStatus.velocity.y);
                        if (self.context.pageEnable) {
                            [self createHorizontalPageSimulator];
                        } else {
                            [self createHorizontalDecelerateSimulator];
                        }
                    } else {
                        self.restStatus.velocity = CGPointMake(0, self.restStatus.velocity.y);
                    }
                } else {
                    self.restStatus.velocity = CGPointMake(0, self.restStatus.velocity.y);
                }
            }
        } else {
            if (self.pageEnable) {
                [self createHorizontalPageSimulator];
            } else {
                [self createHorizontalDecelerateSimulator];
            }
        }
    }
}

- (void)createVerticalSimulatorIfNeeded
{
    if (self.context.contentSize.height > self.context.frameSize.height + LNScrollViewAutoEffectCommonTolerance) {
        if (self.restStatus.startPosition.y <= self.restStatus.leadingPoint.y && self.restStatus.velocity.y < 0) {
            //超出了上边界
            if ([self shouldOverBounds:LNScrollViewGestureEffectBoundsVerticalLeading]) {
                [self createVerticalBounceSimulator:NO];
            } else {
                self.restStatus.offset = CGPointMake(self.restStatus.offset.x, self.restStatus.leadingPoint.y);
                if (self.restStatus.velocity.y < -LNScrollViewAutoEffectCommonTolerance && [self needFeedback:LNScrollViewGestureEffectBoundsVerticalLeading]) {
                    //如果有反馈，直接捕获反馈的速度，创建向下的减速
                    CGFloat feedbackVelocity = [self.context.topPulseGenerator generate:fabs(self.restStatus.velocity.y)];
                    if (feedbackVelocity < -LNScrollViewAutoEffectCommonTolerance) {
                        //有负反馈，返回必定靠decelerate
                        self.restStatus.velocity = CGPointMake(self.restStatus.velocity.x, -feedbackVelocity);
                        if (self.context.pageEnable) {
                            [self createVerticalPageSimulator];
                        } else {
                            [self createVerticalDecelerateSimulator];
                        }
                    } else {
                        //velocity降低为0，无动作
                        self.restStatus.velocity = CGPointMake(self.restStatus.velocity.x, 0);
                    }
                } else {
                    self.restStatus.velocity = CGPointMake(self.restStatus.velocity.x, 0);
                }
            }
        } else if (self.restStatus.startPosition.y >= self.restStatus.trailingPoint.y && self.restStatus.velocity.y > 0) {
            if ([self shouldOverBounds:LNScrollViewGestureEffectBoundsVerticalTrailing]) {
                [self createVerticalBounceSimulator:YES];
            } else {
                self.restStatus.offset = CGPointMake(self.restStatus.offset.x, self.restStatus.trailingPoint.y);
                if (self.restStatus.velocity.y > LNScrollViewAutoEffectCommonTolerance && [self needFeedback:LNScrollViewGestureEffectBoundsVerticalTrailing]) {
                    CGFloat feedbackVelocity = [self.context.bottomPulseGenerator generate:fabs(self.restStatus.velocity.y)];
                    if (feedbackVelocity < - LNScrollViewAutoEffectCommonTolerance) {
                        self.restStatus.velocity = CGPointMake(self.restStatus.velocity.x, feedbackVelocity);
                        if (self.context.pageEnable) {
                            [self createVerticalPageSimulator];
                        } else {
                            [self createVerticalDecelerateSimulator];
                        }
                    } else {
                        self.restStatus.velocity = CGPointMake(self.restStatus.velocity.x, 0);
                    }
                } else {
                    self.restStatus.velocity = CGPointMake(self.restStatus.velocity.x, 0);
                }
            }
        } else {
            //在中央，创建减速或分页
            if (self.pageEnable) {
                [self createVerticalPageSimulator];
            } else {
                [self createVerticalDecelerateSimulator];
            }
        }
    }
}

- (BOOL)needFeedback:(LNScrollViewGestureEffectBoundsType)boundsType {
    switch (boundsType) {
        case LNScrollViewGestureEffectBoundsVerticalLeading: {
            if (self.context.topPulseGenerator.isOpen) {
                return YES;
            } else {
                return NO;
            }
        } break;
        case LNScrollViewGestureEffectBoundsHorizontalLeading: {
            if (self.context.leftPulseGenerator.isOpen) {
                return YES;
            } else {
                return NO;
            }
        } break;
        case LNScrollViewGestureEffectBoundsVerticalTrailing: {
            if (self.context.bottomPulseGenerator.isOpen) {
                return YES;
            } else {
                return NO;
            }
        } break;
        case LNScrollViewGestureEffectBoundsHorizontalTrailing: {
            if (self.context.rightPulseGenerator.isOpen) {
                return YES;
            } else {
                return NO;
            }
        } break;
        default: {
            return NO;
        } break;
    }
}

- (BOOL)shouldOverBounds: (LNScrollViewGestureEffectBoundsType)boundsType {
    if (self.context.bounces == NO) {
        return NO;
    }
    
    BOOL hasFeedBack = [self needFeedback:boundsType];
    if (hasFeedBack) {
        return NO;
    } else {
        return YES;
    }
}


- (CGPoint)getVelocity {
    return self.restStatus.velocity;
}

@end

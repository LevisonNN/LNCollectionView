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
#import "LNScrollViewEffectAxis.h"

#define LNScrollViewAutoEffectCommonTolerance 0.001f

@interface LNScrollViewRestStatusComponent()

@property (nonatomic, weak) LNScrollViewRestStatus *status;

@end

@interface LNScrollViewRestStatus()

@property (nonatomic, assign) CGPoint velocity;
@property (nonatomic, assign) CGPoint offset;

@property (nonatomic, assign) CGPoint startPosition;

@property (nonatomic, strong) LNScrollViewRestStatusComponent *verticalComponent;
@property (nonatomic, strong) LNScrollViewRestStatusComponent *horizontalComponent;

@end

@implementation LNScrollViewRestStatusComponent {
    BOOL _isVertical;
}

- (instancetype)initWith:(LNScrollViewRestStatus *)status isVertical:(BOOL)isVertical {
    self = [super init];
    if (self) {
        self.status = status;
        _isVertical = isVertical;
    }
    return self;
}

- (void)setOffset:(CGFloat)offset {
    if (_isVertical) {
        self.status.offset = CGPointMake(self.status.offset.x, offset);
    } else {
        self.status.offset = CGPointMake(offset, self.status.offset.y);
    }
}

- (CGFloat)offset {
    if (_isVertical) {
        return self.status.offset.y;
    } else {
        return self.status.offset.x;
    }
}

- (void)setVelocity:(CGFloat)velocity {
    if (_isVertical) {
        self.status.velocity = CGPointMake(self.status.velocity.x, velocity);
    } else {
        self.status.velocity = CGPointMake(velocity, self.status.velocity.y);
    }
}

- (CGFloat)velocity {
    if (_isVertical) {
        return self.status.velocity.y;
    } else {
        return self.status.velocity.x;
    }
}

@end

@implementation LNScrollViewRestStatus

- (LNScrollViewRestStatusComponent *)verticalComponent {
    if (!_verticalComponent) {
        _verticalComponent = [[LNScrollViewRestStatusComponent alloc] initWith:self isVertical:YES];
    }
    return _verticalComponent;
}

- (LNScrollViewRestStatusComponent *)horizontalComponent {
    if (!_horizontalComponent) {
        _horizontalComponent = [[LNScrollViewRestStatusComponent alloc] initWith:self isVertical:NO];
    }
    return _horizontalComponent;
}

@end

//配置context和restStatus
@interface LNScrollViewEffectAxis(AutoEffectPrivate)

@property (nonatomic, weak) LNScrollViewContextObjectComponent *context;
@property (nonatomic, weak) LNScrollViewRestStatusComponent *restStatus;

@end

@interface LNScrollViewAutoEffect() <LNScrollViewClockProtocol>

@property (nonatomic, weak) LNScrollViewContextObject *context;
@property (nonatomic, strong) LNScrollViewRestStatus *restStatus;

@end

@implementation LNScrollViewAutoEffect

- (instancetype)initWithContext:(LNScrollViewContextObject *)context
{
    self = [super init];
    if (self) {
        self.context = context;
    }
    return self;
}

- (void)dealloc
{
}

- (BOOL)startWithVelocity:(CGPoint)velocity {
    [self finish];
    [LNScrollViewClock.shareInstance addObject:self];
    CGPoint contentOffset = self.context.contentOffset;
    self.restStatus = [[LNScrollViewRestStatus alloc] init];
    self.restStatus.velocity = velocity;
    self.restStatus.startPosition = contentOffset;
    self.restStatus.offset = contentOffset;

    [self _activeHorizontalAxisIfNeeded];
    [self _activeVerticalAxisIfNeeded];
    return NO;
}

- (void)scrollTo:(CGPoint)offset {
    [self finish];
    [LNScrollViewClock.shareInstance addObject:self];
    CGPoint contentOffset = self.context.contentOffset;
    self.restStatus = [[LNScrollViewRestStatus alloc] init];
    self.restStatus.velocity = CGPointZero;
    self.restStatus.startPosition = contentOffset;
    self.restStatus.offset = contentOffset;
    [self _horizontAxisScrollTo:offset.x];
    [self _verticalAxisScrollTo:offset.y];
}

- (void)_horizontAxisScrollTo:(CGFloat)offset {
    self.context.horizontalAxis.context = self.context.horizontalComponent;
    self.context.horizontalAxis.restStatus = self.restStatus.horizontalComponent;
    [self.context.horizontalAxis startScrollTo:offset];
}

- (void)_verticalAxisScrollTo:(CGFloat)offset {
    self.context.verticalAxis.context = self.context.verticalComponent;
    self.context.verticalAxis.restStatus = self.restStatus.verticalComponent;
    [self.context.verticalAxis startScrollTo:offset];
}

- (void)_activeHorizontalAxisIfNeeded {
    self.context.horizontalAxis.context = self.context.horizontalComponent;
    self.context.horizontalAxis.restStatus = self.restStatus.horizontalComponent;
    [self.context.horizontalAxis startAutoEffectIfNeeded];
}

- (void)_activeVerticalAxisIfNeeded {
    self.context.verticalAxis.context = self.context.verticalComponent;
    self.context.verticalAxis.restStatus = self.restStatus.verticalComponent;
    [self.context.verticalAxis startAutoEffectIfNeeded];
}

- (void)scrollViewClockUpdateTimeInterval:(NSTimeInterval)time
{
    BOOL didStatusChange = NO;
    
    didStatusChange = [self.context.horizontalAxis accumulate:time] || didStatusChange;
    didStatusChange = [self.context.verticalAxis accumulate:time] || didStatusChange;
   
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
    if (self.context.horizontalAxis &&
        !self.context.horizontalAxis.isFinished) {
        return NO;
    }
    if (self.context.verticalAxis &&
        !self.context.verticalAxis.isFinished) {
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
    [self.context.horizontalAxis finishForcely];
    [self.context.verticalAxis finishForcely];
    self.restStatus = nil;
    [LNScrollViewClock.shareInstance removeObject:self];
}

- (BOOL)isFinished {
    return [self hasFinished];
}

- (CGPoint)getVelocity {
    return self.restStatus.velocity;
}

@end

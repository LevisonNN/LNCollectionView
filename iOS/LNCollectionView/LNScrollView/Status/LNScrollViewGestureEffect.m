//
//  LNScrollViewGestureEffect.m
//  LNCollectionView
//
//  Created by Levison on 9.11.24.
//

#import "LNScrollViewGestureEffect.h"
#import "LNScrollViewContextObject.h"
#import "LNScrollViewEffectAxis.h"

@interface LNScrollViewEffectAxis(GestureEffectPrivate)

@property (nonatomic, weak) LNScrollViewContextObjectComponent *context;
@property (nonatomic, weak) LNScrollViewRestStatusComponent *restStatus;

@end

@implementation LNScrollViewGestureStatus
@end

@interface LNScrollViewGestureEffect ()

@property (nonatomic, strong) LNScrollViewGestureStatus *status;
@property (nonatomic, weak) LNScrollViewContextObject *context;

@end

@implementation LNScrollViewGestureEffect

- (instancetype)initWithContext:(nonnull LNScrollViewContextObject *)context {
    self = [super init];
    if (self) {
        self.context = context;
    }
    return self;
}

- (void)startWithGesturePosition:(CGPoint)gesturePosition {
    CGPoint contentOffset = self.context.contentOffset;
    self.status = [[LNScrollViewGestureStatus alloc] init];
    self.status.gestureStartPosition = gesturePosition;
    self.status.startContentOffset = contentOffset;
    self.status.convertedOffset = CGPointZero;
    [self _activeAxisIfNeeded];
}

- (void)_activeAxisIfNeeded {
    self.context.horizontalAxis.context = self.context.horizontalComponent;
    self.context.verticalAxis.context = self.context.verticalComponent;
}

- (void)updateGestureLocation:(CGPoint)location
{
    CGFloat horizontalGesturePosition = location.x;
    CGFloat verticalGesturePosition = location.y;
    CGFloat convertedOffsetX = [self.context.horizontalAxis targetConvertedPositionFor:self.status.gestureStartPosition.x
                                                                gestureCurrentPosition:horizontalGesturePosition
                                                                    gestureStartOffset:self.status.startContentOffset.x];
    CGFloat convertedOffsetY = [self.context.verticalAxis targetConvertedPositionFor:self.status.gestureStartPosition.y
                                                                gestureCurrentPosition:verticalGesturePosition
                                                                    gestureStartOffset:self.status.startContentOffset.y];
    self.status.convertedOffset = CGPointMake(convertedOffsetX, convertedOffsetY);
    if (self.delegate && [self.delegate respondsToSelector:@selector(gestureEffectStatusDidChange:)]) {
        [self.delegate gestureEffectStatusDidChange:self.status];
    }
}

- (void)finish {
    self.status = nil;
}

@end

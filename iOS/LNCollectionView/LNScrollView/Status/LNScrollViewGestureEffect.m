//
//  LNScrollViewGestureEffect.m
//  LNCollectionView
//
//  Created by Levison on 9.11.24.
//

#import "LNScrollViewGestureEffect.h"
#import "LNScrollViewDragSimulator.h"
#import "LNScrollViewContextObject.h"

@implementation LNScrollViewGestureStatus
@end

@interface LNScrollViewGestureEffect ()

@property (nonatomic, strong) LNScrollViewGestureStatus *status;

@property (nonatomic, strong) LNScrollViewDragSimulator *horizontalDragSimulator;
@property (nonatomic, strong) LNScrollViewDragSimulator *verticalDragSimulator;

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
    
    CGSize contentSize = self.context.contentSize;
    CGSize frameSize = self.context.frameSize;
    CGPoint contentOffset = self.context.contentOffset;
    
    self.status = [[LNScrollViewGestureStatus alloc] init];
    self.status.gestureStartPosition = gesturePosition;
    self.status.startContentOffset = contentOffset;
    self.status.convertedOffset = CGPointZero;

    if (contentSize.height > frameSize.height) {
        self.verticalDragSimulator =
        [[LNScrollViewDragSimulator alloc] initWithLeadingPoint:0
                                                  trailingPoint:contentSize.height - frameSize.height
                                                     startPoint:contentOffset.y];
    }
    
    if (contentSize.width > frameSize.width) {
        self.horizontalDragSimulator =
        [[LNScrollViewDragSimulator alloc] initWithLeadingPoint:0
                                                  trailingPoint:contentSize.width - frameSize.width
                                                     startPoint:contentOffset.x];
    }
    
}

- (BOOL)shouldOverBounds: (LNScrollViewBoundsType)boundsType {
    if (self.context.bounces == NO) {
        return NO;
    }
    switch (boundsType) {
        case LNScrollViewBoundsVerticalLeading: {
            if (self.context.topPulseGenerator.isOpen) {
                return NO;
            } else {
                return YES;
            }
        } break;
        case LNScrollViewBoundsHorizontalLeading: {
            if (self.context.leftPulseGenerator.isOpen) {
                return NO;
            } else {
                return YES;
            }
        } break;
        case LNScrollViewBoundsVerticalTrailing: {
            if (self.context.bottomPulseGenerator.isOpen) {
                return NO;
            } else {
                return YES;
            }
        } break;
        case LNScrollViewBoundsHorizontalTrailing: {
            if (self.context.rightPulseGenerator.isOpen) {
                return NO;
            } else {
                return YES;
            }
        } break;
        default: {
            return NO;
        } break;
    }
}

- (void)updateGestureLocation:(CGPoint)location
{
    BOOL didStatusChange = NO;
    if (self.horizontalDragSimulator) {
        CGFloat horizontalOffset = location.x - self.status.gestureStartPosition.x;
        [self.horizontalDragSimulator updateOffset:horizontalOffset];
        CGFloat resultOffset = self.horizontalDragSimulator.getResultOffset;
        if (resultOffset < self.horizontalDragSimulator.leadingPoint) {
            if ([self shouldOverBounds:LNScrollViewBoundsHorizontalLeading]) {
                self.status.convertedOffset = CGPointMake(resultOffset, self.status.convertedOffset.y);
            } else {
                self.status.convertedOffset = CGPointMake(self.horizontalDragSimulator.leadingPoint, self.status.convertedOffset.y);
            }
        } else if (resultOffset > self.horizontalDragSimulator.trailingPoint){
            if ([self shouldOverBounds:LNScrollViewBoundsHorizontalTrailing]) {
                self.status.convertedOffset = CGPointMake(resultOffset, self.status.convertedOffset.y);
            } else {
                self.status.convertedOffset = CGPointMake(self.horizontalDragSimulator.trailingPoint, self.status.convertedOffset.y);
            }
        } else {
            self.status.convertedOffset = CGPointMake(resultOffset, self.status.convertedOffset.y);
        }
        didStatusChange = YES;
    }
    if (self.verticalDragSimulator) {
        CGFloat verticalOffset = location.y - self.status.gestureStartPosition.y;
        [self.verticalDragSimulator updateOffset:verticalOffset];
        CGFloat resultOffset = self.verticalDragSimulator.getResultOffset;
        if (resultOffset < self.verticalDragSimulator.leadingPoint) {
            if ([self shouldOverBounds:LNScrollViewBoundsVerticalLeading]) {
                self.status.convertedOffset = CGPointMake(self.status.convertedOffset.x, resultOffset);
            } else {
                self.status.convertedOffset = CGPointMake(self.status.convertedOffset.x, self.verticalDragSimulator.leadingPoint);
            }
        } else if (resultOffset > self.verticalDragSimulator.trailingPoint) {
            if ([self shouldOverBounds:LNScrollViewBoundsVerticalTrailing]) {
                self.status.convertedOffset = CGPointMake(self.status.convertedOffset.x, resultOffset);
            } else {
                self.status.convertedOffset = CGPointMake(self.status.convertedOffset.x, self.verticalDragSimulator.trailingPoint);
            }
        } else {
            self.status.convertedOffset = CGPointMake(self.status.convertedOffset.x, resultOffset);
        }
        didStatusChange = YES;
    }
    
    if (didStatusChange && self.delegate && [self.delegate respondsToSelector:@selector(gestureEffectStatusDidChange:)]) {
        [self.delegate gestureEffectStatusDidChange:self.status];
    }
}

- (void)finish {
    self.status = nil;
    self.horizontalDragSimulator = nil;
    self.verticalDragSimulator = nil;
}

@end

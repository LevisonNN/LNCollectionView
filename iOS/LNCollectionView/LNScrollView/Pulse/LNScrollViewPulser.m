//
//  LNScrollViewPulseReceiver.m
//  LNCollectionView
//
//  Created by Levison on 27.11.24.
//

#import "LNScrollViewPulser.h"

@interface LNScrollViewPulser ()

@property (nonatomic, assign) BOOL isOpen;

@end

@implementation LNScrollViewPulser

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mass = 1.f;
        self.isOpen = NO;
    }
    return self;
}

- (LNScrollViewMomentum *)getCurrentMomentum
{
    LNScrollViewMomentum *currentMomentum = [[LNScrollViewMomentum alloc] init];
    currentMomentum.mass = self.mass;
    if (self.delegate && [self.delegate respondsToSelector:@selector(pulserGetVelocity:)]) {
        CGFloat velocity = [self.delegate pulserGetVelocity:self];
        currentMomentum.velocity = velocity;
    } else {
        currentMomentum.velocity = 0.f;
    }
    return currentMomentum;
}

- (void)updateMomentum:(LNScrollViewMomentum *)momentum
{
    if (!self.isOpen) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(pulser:updateVelocity:)]) {
        [self.delegate pulser:self updateVelocity:momentum.velocity];
    }
}

- (void)open
{
    self.isOpen = YES;
}

- (void)close
{
    self.isOpen = NO;
}

@end

//
//  LNScrollViewPulseGenerator.m
//  LNCollectionView
//
//  Created by Levison on 27.11.24.
//

#import "LNScrollViewPulseGenerator.h"

@interface LNScrollViewPulseGenerator ()

@property (nonatomic, assign) BOOL isOpen;

@end

@implementation LNScrollViewPulseGenerator

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mass = 1.f;
        self.isOpen = NO;
    }
    return self;
}

- (void)setMass:(CGFloat)mass
{
    _mass = MAX(1.0, mass);
}

- (CGFloat)generate:(CGFloat)velocity
{
    if (!self.isOpen) {
        return velocity;
    }
    
    if (velocity <= 0) {
        return velocity;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(generatorHasDetectedMomentum:)]) {
        LNScrollViewMomentum *momentum = [[LNScrollViewMomentum alloc] init];
        momentum.mass = self.mass;
        momentum.velocity = velocity;
        return [self.delegate generatorHasDetectedMomentum:momentum].velocity;
    }
    return velocity;
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

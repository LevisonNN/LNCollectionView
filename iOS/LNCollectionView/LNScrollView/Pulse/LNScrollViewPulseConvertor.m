//
//  LNScrollViewPulseConvertor.m
//  LNCollectionView
//
//  Created by Levison on 28.11.24.
//

#import "LNScrollViewPulseConvertor.h"

@interface LNScrollViewPulseConvertor()

@property (nonatomic, weak) LNScrollViewPulseGenerator *generator;
@property (nonatomic, weak) LNScrollViewPulser *pulser;

@end

@implementation LNScrollViewPulseConvertor

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isConversationOfEnergy = NO;
    }
    return self;
}

- (void)bindGenerator:(LNScrollViewPulseGenerator *)generator
{
    if (self.generator && self.generator.delegate == self) {
        self.generator.delegate = nil;
    }
    _generator = generator;
    generator.delegate = self;
}

- (void)bindPulser:(LNScrollViewPulser *)pulser
{
    self.pulser = pulser;
}

- (LNScrollViewMomentum *)generatorHasDetectedMomentum:(LNScrollViewMomentum *)momentum
{
    if (self.isConversationOfEnergy) {
        LNScrollViewMomentum *pulserMomentum = [self.pulser getCurrentMomentum];
        LNScrollViewMomentum *targetMomentum = [[LNScrollViewMomentum alloc] init];
        targetMomentum.mass = pulserMomentum.mass;
        targetMomentum.velocity = (2 * momentum.mass * momentum.velocity + pulserMomentum.mass * pulserMomentum.velocity - momentum.mass * pulserMomentum.velocity)/(momentum.mass + pulserMomentum.mass);
        [self.pulser updateMomentum:targetMomentum];
        LNScrollViewMomentum *feedbackMomentum = [[LNScrollViewMomentum alloc] init];
        feedbackMomentum.mass = momentum.mass;
        feedbackMomentum.velocity = (2 * pulserMomentum.mass * pulserMomentum.velocity + momentum.mass * momentum.velocity - pulserMomentum.mass * momentum.velocity)/(momentum.mass + pulserMomentum.mass);
        return feedbackMomentum;
    } else {
        LNScrollViewMomentum *pulserMomentum = [self.pulser getCurrentMomentum];
        LNScrollViewMomentum *targetMomentum = [[LNScrollViewMomentum alloc] init];
        targetMomentum.mass = pulserMomentum.mass;
        targetMomentum.velocity = (momentum.mass * momentum.velocity + pulserMomentum.mass * pulserMomentum.velocity)/pulserMomentum.mass;
        [self.pulser updateMomentum:targetMomentum];
        LNScrollViewMomentum *feedbackMomentum = [[LNScrollViewMomentum alloc] init];
        feedbackMomentum.mass = momentum.mass;
        feedbackMomentum.velocity = 0.f;
        return feedbackMomentum;
    }
}

@end

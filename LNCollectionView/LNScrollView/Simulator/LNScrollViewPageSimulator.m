//
//  LNScrollViewPageSimulator.m
//  LNCollectionView
//
//  Created by Levison on 12.11.24.
//

#import "LNScrollViewPageSimulator.h"

@interface LNScrollViewPageSimulator ()

@property (nonatomic, assign) CGFloat damping;
@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) CGFloat velocity_0;
@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, assign) CGFloat targetPosition;

@property (nonatomic, assign) CGFloat position;
@property (nonatomic, assign) CGFloat velocity;


@end

@implementation LNScrollViewPageSimulator

+ (CGFloat)targetOffsetWithVelocity:(CGFloat)velocity
                             offset:(CGFloat)offset
                            damping:(CGFloat)damping
{
    CGFloat currentTime = 1.f/(damping + velocity/offset);
    CGFloat v_0 = offset * exp(damping * currentTime)/currentTime;
    CGFloat maxPosition = v_0/(M_E * damping);
    return maxPosition;
}

- (instancetype)initWithPosition:(CGFloat)position
                        velocity:(CGFloat)velocity
                  targetPosition:(CGFloat)targetPosition
                         damping:(CGFloat)damping
{
    self = [super init];
    if (self) {
        self.damping = damping;
        self.targetPosition = targetPosition;
        self.offset = position - targetPosition;
        if (fabs(self.offset) < 1.f) {
            self.currentTime = 0.f;
            self.velocity_0 = velocity;
        } else {
            self.currentTime = 1.f/(self.damping + velocity/self.offset);
            self.velocity_0 = self.offset * exp(self.damping * self.currentTime)/self.currentTime;
        }
    }
    return self;
}

- (CGFloat)position {
    return self.targetPosition + self.offset;
}

- (void)accumulate:(NSTimeInterval)during {
    self.currentTime += during;
    self.offset = self.velocity_0 * self.currentTime * exp(- self.damping * self.currentTime);
    self.velocity = self.velocity_0 * exp(- self.damping * self.currentTime);
}

- (BOOL)isFinished
{
    return fabs(self.offset) < 0.1f && fabs(self.velocity) < 0.01;
}

@end

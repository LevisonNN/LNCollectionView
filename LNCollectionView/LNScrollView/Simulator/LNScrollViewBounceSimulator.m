//
//  LNScrollViewBounceSimulator.m
//  LNCollectionView
//
//  Created by Levison on 7.11.24.
//

#import "LNScrollViewBounceSimulator.h"

@interface LNScrollViewBounceSimulator ()

@property (nonatomic, assign) CGFloat damping;
@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) CGFloat velocity_0;
@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, assign) CGFloat targetPosition;

@property (nonatomic, assign) CGFloat position;
@property (nonatomic, assign) CGFloat velocity;

@end

@implementation LNScrollViewBounceSimulator

- (instancetype)initWithPosition:(CGFloat)position velocity:(CGFloat)velocity targetPosition:(CGFloat)targetPosition
{
    self = [super init];
    if (self) {
        self.damping = 10.9;
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

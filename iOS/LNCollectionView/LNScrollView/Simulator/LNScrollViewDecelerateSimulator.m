//
//  LNScrollViewDecelerateSimulator.m
//  LNCollectionView
//
//  Created by Levison on 7.11.24.
//

#import "LNScrollViewDecelerateSimulator.h"

@interface LNScrollViewDecelerateSimulator ()

@property (nonatomic, assign) CGFloat position;
@property (nonatomic, assign) CGFloat velocity;

@property (nonatomic, assign) CGFloat damping;
@property (nonatomic, assign) NSTimeInterval currentTime;

@end

@implementation LNScrollViewDecelerateSimulator

- (instancetype)initWithPosition:(CGFloat)position velocity:(CGFloat)velocity
{
    self = [super init];
    if (self) {
        self.damping = 2.f;
        self.position = position;
        self.velocity = velocity;
    }
    return self;
}

- (void)accumulate:(NSTimeInterval)during
{
    self.currentTime += during;
    CGFloat v = self.velocity * exp(- self.damping * during);
    CGFloat l = (-1.f/self.damping) * self.velocity * exp(- self.damping * during) - (-1.f/self.damping) * self.velocity;
    if (self.velocity < 0.01) {
        self.velocity = 0;
    }
    self.velocity = v;
    self.position = self.position + l;
}

- (BOOL)isFinished
{
    return fabs(self.velocity) < 0.01;
}

@end

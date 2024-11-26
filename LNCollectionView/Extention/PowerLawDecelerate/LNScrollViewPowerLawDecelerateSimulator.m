//
//  LNScrollViewPowerLawDecelerateSimulator.m
//  LNCollectionView
//
//  Created by Levison on 26.11.24.
//

#import "LNScrollViewPowerLawDecelerateSimulator.h"

@interface LNScrollViewPowerLawDecelerateSimulator()

@property (nonatomic, assign) CGFloat position;
@property (nonatomic, assign) CGFloat velocity;

//流动行为指数：
//n < 1 假塑性流体 牙膏
//n = 1 牛顿流体 水/空气
//n > 1 胀塑性流体 奶油
//n = 2需要特殊处理为对数形式。
//默认1
@property (nonatomic, assign) CGFloat n;
//粘度，默认2。
@property (nonatomic, assign) CGFloat k;

@property (nonatomic, assign) NSTimeInterval currentTime;

@end

@implementation LNScrollViewPowerLawDecelerateSimulator

- (instancetype)initWithPosition:(CGFloat)position
                        velocity:(CGFloat)velocity
                               k:(CGFloat)k
                               n:(CGFloat)n
{
    self = [super init];
    if (self) {
        self.position = position;
        self.velocity = velocity;
        self.k = k;
        self.n = n;
    }
    return self;
}

- (instancetype)initWithPosition:(CGFloat)position velocity:(CGFloat)velocity
{
    self = [super init];
    if (self) {
        self.position = position;
        self.velocity = velocity;
        self.k = 2.0;
        self.n = 1.0;
    }
    return self;
}

- (void)accumulate:(NSTimeInterval)during
{
    if (fabs(self.n - 1.f) < 0.000001) {
        [self accumulateNewtonian:during];
    } else if (fabs(self.n - 2.f) < 0.000001) {
        [self accumulateNonNewtonianLn:during];
    } else {
        [self accumulateNonNewtonian:during];
    }
}

- (void)accumulateNonNewtonianLn:(NSTimeInterval)during {
    self.currentTime += during;
    if (self.velocity == 0) {
        return ;
    } else if (self.velocity > 0) {
        CGFloat v = self.velocity/(1.0 + self.k * self.velocity * during);
        CGFloat l = (1.0/self.k)*log(1.0 + self.k * self.velocity * during);
        self.velocity = v;
        self.position = self.position + l;
    } else {
        CGFloat positiveVelocity = -self.velocity;
        CGFloat v = positiveVelocity/(1.0 + self.k * positiveVelocity * during);
        CGFloat l = (1.0/self.k)*log(1.0 + self.k * positiveVelocity * during);
        self.velocity = -v;
        self.position = self.position - l;
    }
}

- (void)accumulateNonNewtonian:(NSTimeInterval)during
{
    self.currentTime += during;
    if (self.velocity == 0) {
        return;
    } else if (self.velocity > 0) {
        CGFloat c = pow(self.velocity, 1.0 - self.n)/(1.0 - self.n);
        CGFloat vBase = (self.n - 1)*self.k*during - c*(self.n - 1);
        CGFloat vExp = 1.0/(1.0 - self.n);
        CGFloat v = pow(vBase, vExp);
        CGFloat l = (1.0/(self.k*(2.0 - self.n)))*(pow(self.velocity, 2.0 - self.n) - pow(v, 2.0 - self.n));
        self.velocity = v;
        self.position = self.position + l;
    } else {
        CGFloat positiveVelocity = -self.velocity;
        CGFloat c = pow(positiveVelocity, 1.0 - self.n)/(1.0 - self.n);
        CGFloat vBase = (self.n - 1)*self.k*during - c*(self.n - 1);
        CGFloat vExp = 1.0/(1.0 - self.n);
        CGFloat v = pow(vBase, vExp);
        CGFloat l = (1.0/self.k*(2.0 - self.n))*(pow(positiveVelocity, 2.0 - self.n) - pow(v, 2.0 - self.n));
        self.velocity = -v;
        self.position = self.position - l;
    }
}

- (void)accumulateNewtonian:(NSTimeInterval)during
{
    self.currentTime += during;
    CGFloat v = self.velocity * exp(- self.k * during);
    CGFloat l = (-1.f/self.k) * self.velocity * exp(- self.k * during) - (-1.f/self.k) * self.velocity;
    if (self.velocity < 0.01) {
        self.velocity = 0;
    }
    self.velocity = v;
    self.position = self.position + l;
}

- (BOOL)isFinished
{
    return fabs(self.velocity) < 1.0;
}

@end

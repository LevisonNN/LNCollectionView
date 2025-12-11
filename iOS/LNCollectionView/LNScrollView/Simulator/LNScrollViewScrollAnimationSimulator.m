//
//  LNScrollViewScrollAnimationSimulator.m
//  LNCollectionView
//
//  Created by Levison on 2025/12/11.
//

#import "LNScrollViewScrollAnimationSimulator.h"

@interface LNScrollViewScrollAnimationSimulator ()

//持续时长
@property (nonatomic, assign) NSTimeInterval during;

//控制点
@property (nonatomic, assign) CGFloat p1;
@property (nonatomic, assign) CGFloat p2;

//起始位置
@property (nonatomic, assign) CGFloat staringPoint;
@property (nonatomic, assign) CGFloat endingPoint;
@property (nonatomic, assign) CGFloat scale;


@property (nonatomic, assign) NSTimeInterval currentTime;

@end

@implementation LNScrollViewScrollAnimationSimulator

- (instancetype)initWith:(CGFloat)startingPoint endingPoint:(CGFloat)endingPoint {
    self = [self init];
    if (self) {
        self.during = 0.335;
        self.p1 = 0.1;
        self.p2 = 3.0;
        
        self.staringPoint = startingPoint;
        self.endingPoint = endingPoint;
        self.scale = 0;
    }
    return self;
}

- (CGFloat)currentPosition {
    return self.staringPoint + self.scale * [self totalOffset];
}

- (CGFloat)totalOffset {
    return self.endingPoint - self.staringPoint;
}

- (void)accumulate:(NSTimeInterval)during {
    self.currentTime = self.currentTime + during;
    self.scale = [self scaleFor:self.currentTime];
}

- (CGFloat)scaleFor:(NSTimeInterval)time {
    if (self.during <= 0.0167) {
        return 1;
    }
    CGFloat timeScale = MAX(0, MIN(time/self.during, 1));
    CGFloat newScale = self.p1*(1-timeScale)*(1-timeScale)*timeScale + self.p2*(1-timeScale)*timeScale*timeScale + 1*timeScale*timeScale*timeScale;
    return newScale;
}

- (BOOL)isFinished {
    if (self.currentTime > self.during) {
        return true;
    }
    return false;
}

@end

//
//  LNScrollViewPowerLawDecelerateSimulator.h
//  LNCollectionView
//
//  Created by Levison on 26.11.24.
//

#import <Foundation/Foundation.h>
#import "LNScrollViewDecelerateSimulator.h"

NS_ASSUME_NONNULL_BEGIN

@interface LNScrollViewPowerLawDecelerateSimulator : LNScrollViewDecelerateSimulator

@property (nonatomic, assign, readonly) CGFloat position;
@property (nonatomic, assign, readonly) CGFloat velocity;

- (instancetype)initWithPosition:(CGFloat)position
                        velocity:(CGFloat)velocity
                               k:(CGFloat)k
                               n:(CGFloat)n;
- (instancetype)initWithPosition:(CGFloat)position
                        velocity:(CGFloat)velocity;

- (void)accumulate:(NSTimeInterval)during;
- (BOOL)isFinished;

@end

NS_ASSUME_NONNULL_END

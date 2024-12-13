//
//  LNScrollViewPageSimulator.h
//  LNCollectionView
//
//  Created by Levison on 12.11.24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//这个page外面传吧
@interface LNScrollViewPageSimulator : NSObject

@property (nonatomic, assign, readonly) CGFloat velocity;
@property (nonatomic, assign, readonly) CGFloat position;

- (instancetype)initWithPosition:(CGFloat)position
                        velocity:(CGFloat)velocity
                  targetPosition:(CGFloat)targetPosition
                         damping:(CGFloat)damping;
- (void)accumulate:(NSTimeInterval)during;
- (BOOL)isFinished;

+ (CGFloat)targetOffsetWithVelocity:(CGFloat)velocity
                             offset:(CGFloat)offset
                            damping:(CGFloat)damping;

@end

NS_ASSUME_NONNULL_END

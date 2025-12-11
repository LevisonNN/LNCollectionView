//
//  LNScrollViewScrollAnimationSimulator.h
//  LNCollectionView
//
//  Created by Levison on 2025/12/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LNScrollViewScrollAnimationSimulator : NSObject

@property (nonatomic, assign, readonly) CGFloat currentPosition;
- (instancetype)initWith:(CGFloat)startingPoint endingPoint:(CGFloat)endingPoint;
- (void)accumulate:(NSTimeInterval)during;
- (BOOL)isFinished;

@end

NS_ASSUME_NONNULL_END

//
//  LNScrollViewBounceSimulator.h
//  LNCollectionView
//
//  Created by Levison on 7.11.24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LNScrollViewBounceSimulator : NSObject

@property (nonatomic, assign, readonly) CGFloat velocity;
@property (nonatomic, assign, readonly) CGFloat position;

- (instancetype)initWithPosition:(CGFloat)position velocity:(CGFloat)velocity targetPosition:(CGFloat)targetPosition;
- (void)accumulate:(NSTimeInterval)during;
- (BOOL)isFinished;

@end

NS_ASSUME_NONNULL_END

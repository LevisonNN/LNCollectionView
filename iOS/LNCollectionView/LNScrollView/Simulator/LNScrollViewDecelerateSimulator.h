//
//  LNScrollViewDecelerateSimulator.h
//  LNCollectionView
//
//  Created by Levison on 7.11.24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LNScrollViewDecelerateSimulator : NSObject

@property (nonatomic, assign, readonly) CGFloat position;
@property (nonatomic, assign, readonly) CGFloat velocity;

- (instancetype)initWithPosition:(CGFloat)position velocity:(CGFloat)velocity;

- (void)accumulate:(NSTimeInterval)during;
- (BOOL)isFinished;

@end

NS_ASSUME_NONNULL_END

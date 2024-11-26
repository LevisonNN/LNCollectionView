//
//  LNScrollViewAutoEffect.h
//  LNCollectionView
//
//  Created by Levison on 9.11.24.
//

#import <Foundation/Foundation.h>
#import "LNScrollViewBounceSimulator.h"
#import "LNScrollViewDecelerateSimulator.h"

NS_ASSUME_NONNULL_BEGIN

@class LNScrollViewAutoEffect;

@interface LNScrollViewRestStatus: NSObject
@property (nonatomic, assign, readonly) CGPoint leadingPoint;
@property (nonatomic, assign, readonly) CGPoint trailingPoint;
@property (nonatomic, assign, readonly) CGPoint velocity;
@property (nonatomic, assign, readonly) CGPoint offset;
@end

@protocol LNScrollViewAutoEffectDataSource <NSObject>


- (nullable LNScrollViewDecelerateSimulator *)autoEffect:(LNScrollViewAutoEffect *)effect
                        horizontalDecelerateWithPosition:(CGFloat)position
                                                velocity:(CGFloat)velocity;
- (nullable LNScrollViewDecelerateSimulator *)autoEffect:(LNScrollViewAutoEffect *)effect
                          verticalDecelerateWithPosition:(CGFloat)position
                                                velocity:(CGFloat)velocity;

@end

@protocol LNScrollViewAutoEffectProtocol
- (void)autoEffectStatusDidChange:(LNScrollViewRestStatus *)status;
- (void)autoEffectStatusHasFinished:(LNScrollViewAutoEffect *)effect;
@end

@interface LNScrollViewAutoEffect : NSObject

@property (nonatomic, assign) BOOL pageEnable;
@property (nonatomic, assign) CGFloat pageDamping;

@property (nonatomic, weak) NSObject<LNScrollViewAutoEffectProtocol> *delegate;
@property (nonatomic, weak) NSObject<LNScrollViewAutoEffectDataSource> *dataSource;

- (BOOL)startWithContentSize:(CGSize)contentSize
                   frameSize:(CGSize)frameSize
                    velocity:(CGPoint)velocity
                    position:(CGPoint)position;
- (BOOL)isFinished;
- (void)finishForcely;

@end

NS_ASSUME_NONNULL_END

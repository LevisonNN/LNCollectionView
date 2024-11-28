//
//  LNScrollViewAutoEffect.h
//  LNCollectionView
//
//  Created by Levison on 9.11.24.
//

#import <Foundation/Foundation.h>
#import "LNScrollViewBounceSimulator.h"
#import "LNScrollViewDecelerateSimulator.h"
#import "LNScrollViewPulser.h"
#import "LNScrollViewPulseGenerator.h"

NS_ASSUME_NONNULL_BEGIN

@class LNScrollViewAutoEffect;

@interface LNScrollViewRestStatus: NSObject
@property (nonatomic, assign, readonly) CGPoint leadingPoint;
@property (nonatomic, assign, readonly) CGPoint trailingPoint;
@property (nonatomic, assign, readonly) CGPoint velocity;
@property (nonatomic, assign, readonly) CGPoint offset;
@end

@protocol LNScrollViewAutoEffectDataSource <NSObject>

- (CGSize)autoEffectGetContentSize:(LNScrollViewAutoEffect *)effect;
- (CGSize)autoEffectGetFrameSize:(LNScrollViewAutoEffect *)effect;
- (CGPoint)autoEffectGetContentOffset:(LNScrollViewAutoEffect *)effect;

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

- (BOOL)startWithVelocity:(CGPoint)velocity;
- (BOOL)isFinished;
- (void)finishForcely;

@property (nonatomic, strong, readonly) LNScrollViewPulseGenerator *topPulseGenerator;
@property (nonatomic, strong, readonly) LNScrollViewPulseGenerator *leftPulseGenerator;
@property (nonatomic, strong, readonly) LNScrollViewPulseGenerator *bottomPulseGenerator;
@property (nonatomic, strong, readonly) LNScrollViewPulseGenerator *rightPulseGenerator;
@property (nonatomic, strong, readonly) LNScrollViewPulser *topPulser;
@property (nonatomic, strong, readonly) LNScrollViewPulser *leftPulser;
@property (nonatomic, strong, readonly) LNScrollViewPulser *bottomPulser;
@property (nonatomic, strong, readonly) LNScrollViewPulser *rightPulser;

@end

NS_ASSUME_NONNULL_END

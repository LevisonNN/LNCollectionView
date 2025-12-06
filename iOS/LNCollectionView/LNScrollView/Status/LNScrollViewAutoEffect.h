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
#import "LNScrollViewContextObject.h"

NS_ASSUME_NONNULL_BEGIN

@class LNScrollViewAutoEffect;

@interface LNScrollViewRestStatus: NSObject
@property (nonatomic, assign, readonly) CGPoint leadingPoint;
@property (nonatomic, assign, readonly) CGPoint trailingPoint;
@property (nonatomic, assign, readonly) CGPoint velocity;
@property (nonatomic, assign, readonly) CGPoint offset;
@end

@protocol LNScrollViewAutoEffectProtocol
- (void)autoEffectStatusDidChange:(LNScrollViewRestStatus *)status;
- (void)autoEffectStatusHasFinished:(LNScrollViewAutoEffect *)effect;
@end

@interface LNScrollViewAutoEffect : NSObject

- (instancetype)initWithContext:(nonnull LNScrollViewContextObject *)context;

@property (nonatomic, assign) BOOL pageEnable;
@property (nonatomic, assign) CGFloat pageDamping;

@property (nonatomic, weak) NSObject<LNScrollViewAutoEffectProtocol> *delegate;

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

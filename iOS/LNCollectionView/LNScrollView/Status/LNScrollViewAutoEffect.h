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

//tempProperty
- (CGPoint)getVelocity;

@end

NS_ASSUME_NONNULL_END

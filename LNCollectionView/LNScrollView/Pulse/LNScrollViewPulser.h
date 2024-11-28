//
//  LNScrollViewPulseReceiver.h
//  LNCollectionView
//
//  Created by Levison on 27.11.24.
//

#import <Foundation/Foundation.h>
#import "LNScrollViewPulseGenerator.h"

NS_ASSUME_NONNULL_BEGIN

@class LNScrollViewPulser;
@protocol LNScrollViewPulserDelegate

- (CGFloat)pulserGetVelocity:(LNScrollViewPulser *)pulser;
- (void)pulser:(LNScrollViewPulser *)pulser updateVelocity:(CGFloat)velocity;

@end

@interface LNScrollViewPulser : NSObject

@property (nonatomic, weak) NSObject<LNScrollViewPulserDelegate> *delegate;
@property (nonatomic, assign) CGFloat mass;
@property (nonatomic, assign, readonly) BOOL isOpen;

- (LNScrollViewMomentum *)getCurrentMomentum;
- (void)updateMomentum:(LNScrollViewMomentum *)momentum;

- (void)open;
- (void)close;

@end

NS_ASSUME_NONNULL_END

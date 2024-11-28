//
//  LNScrollViewPulseGenerator.h
//  LNCollectionView
//
//  Created by Levison on 27.11.24.
//

#import <Foundation/Foundation.h>
#import "LNScrollViewMomentum.h"

NS_ASSUME_NONNULL_BEGIN

@class LNScrollViewPulseGenerator;

@protocol LNScrollViewPulseGeneratorDelegate <NSObject>

- (LNScrollViewMomentum *)generatorHasDetectedMomentum:(LNScrollViewMomentum *)momentum;

@end

@interface LNScrollViewPulseGenerator : NSObject

@property (nonatomic, assign) CGFloat mass;
@property (nonatomic, assign, readonly) BOOL isOpen;
@property (nonatomic, weak) NSObject<LNScrollViewPulseGeneratorDelegate> *delegate;

- (CGFloat)generate:(CGFloat)velocity;
- (void)open;
- (void)close;

@end

NS_ASSUME_NONNULL_END

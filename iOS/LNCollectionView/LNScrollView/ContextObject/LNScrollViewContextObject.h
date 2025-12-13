//
//  LNScrollViewContextObject.h
//  LNCollectionView
//
//  Created by Levison on 6.12.25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LNScrollViewDecelerateSimulator.h"
#import "LNScrollViewPulseGenerator.h"

@class LNScrollViewEffectAxis;

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, LNScrollViewBoundsType) {
    LNScrollViewBoundsVerticalLeading = 0,
    LNScrollViewBoundsHorizontalLeading = 1,
    LNScrollViewBoundsVerticalTrailing = 2,
    LNScrollViewBoundsHorizontalTrailing = 3,
};

/**
 看成每个子组件都可以捕获到LNScrollView状态的固有属性
 */

@protocol LNScrollViewContextDelegate

@required
- (CGSize)contextGetContentSize;
- (CGSize)contextGetFrameSize;
- (CGPoint)contextGetContentOffset;
- (UIEdgeInsets)contextGetContentInset;

- (BOOL)contextGetBounces;
- (BOOL)contextGetAlwaysBouncesHorizontal;
- (BOOL)contextGetAlwaysBouncesVertical;
- (BOOL)contextGetPageEnable;

- (BOOL)contextGetZoomingBounces;
- (CGFloat)contextGetZoomingScale;
- (CGFloat)contextGetMaxZoomingScale;
- (CGFloat)contextGetMinZoomingScale;
- (CGSize)contextGetZoomingViewBoundSize;
- (CGPoint)contextGetZoomingViewCenterPoint;

@optional

- (LNScrollViewPulseGenerator *)contextGetTopPulseGenerator;
- (LNScrollViewPulseGenerator *)contextGetLeftPulseGenerator;
- (LNScrollViewPulseGenerator *)contextGetBottomPulseGenerator;
- (LNScrollViewPulseGenerator *)contextGetRightPulseGenerator;

- (LNScrollViewEffectAxis *)contextGetHorizontalAxis;
- (LNScrollViewEffectAxis *)contextGetVerticalAxis;

@end

@interface LNScrollViewContextObjectComponent : NSObject

- (CGFloat)contentSize;
- (CGFloat)frameSize;
- (CGFloat)contentOffset;

- (CGFloat)leadingInset;
- (CGFloat)trailingInset;

- (BOOL)bounces;
- (BOOL)alwaysBounces;
- (BOOL)pageEnable;

- (LNScrollViewPulseGenerator *)leadingGenerator;
- (LNScrollViewPulseGenerator *)trailingGenerator;

@end

@interface LNScrollViewContextObject : NSObject

@property (nonatomic, strong, readonly) LNScrollViewContextObjectComponent *verticalComponent;
@property (nonatomic, strong, readonly) LNScrollViewContextObjectComponent *horizontalComponent;

- (instancetype)initWithDelegate:(nonnull NSObject<LNScrollViewContextDelegate> *)delegate;

- (CGSize)contentSize;
- (CGSize)frameSize;
- (CGPoint)contentOffset;
- (UIEdgeInsets)contentInset;
- (BOOL)bounces;
- (BOOL)alwaysBouncesHorizontal;
- (BOOL)alwaysBouncesVertical;
- (BOOL)pageEnable;

- (LNScrollViewPulseGenerator *)topPulseGenerator;
- (LNScrollViewPulseGenerator *)leftPulseGenerator;
- (LNScrollViewPulseGenerator *)bottomPulseGenerator;
- (LNScrollViewPulseGenerator *)rightPulseGenerator;

- (LNScrollViewEffectAxis *)horizontalAxis;
- (LNScrollViewEffectAxis *)verticalAxis;

//zooming
- (BOOL)zoomingBounces;
- (CGFloat)maxZoomingScale;
- (CGFloat)minZoomingScale;
- (CGFloat)zoomingScale;
- (CGSize)zoomingViewBoundSize;
- (CGPoint)zoomingViewCenterPoint;

@end
NS_ASSUME_NONNULL_END

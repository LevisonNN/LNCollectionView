//
//  LNScrollView.h
//  LNCollectionView
//
//  Created by Levison on 9.11.24.
//

#import <UIKit/UIKit.h>
#import "LNScrollViewPulser.h"
#import "LNScrollViewPulseGenerator.h"

NS_ASSUME_NONNULL_BEGIN

@class LNScrollView;
@class LNScrollViewDecelerateSimulator;

@protocol LNScrollViewDelegate <NSObject>

@optional
//已实现
- (void)ln_scrollViewDidScroll:(LNScrollView *)scrollView;
- (void)ln_scrollViewWillBeginDragging:(LNScrollView *)scrollView;
- (void)ln_scrollViewWillEndDragging:(LNScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;
- (void)ln_scrollViewDidEndDragging:(LNScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)ln_scrollViewWillBeginDecelerating:(LNScrollView *)scrollView;
- (void)ln_scrollViewDidEndDecelerating:(LNScrollView *)scrollView;
//未实现
- (void)ln_scrollViewDidZoom:(LNScrollView *)scrollView;
- (void)ln_scrollViewDidEndScrollingAnimation:(LNScrollView *)scrollView;
- (nullable UIView *)ln_viewForZoomingInScrollView:(LNScrollView *)scrollView;
- (void)ln_scrollViewWillBeginZooming:(LNScrollView *)scrollView withView:(nullable UIView *)view;
- (void)ln_scrollViewDidEndZooming:(LNScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale;
- (BOOL)ln_scrollViewShouldScrollToTop:(LNScrollView *)scrollView;
- (void)ln_scrollViewDidScrollToTop:(LNScrollView *)scrollView;
- (void)ln_scrollViewDidChangeAdjustedContentInset:(LNScrollView *)scrollView;

@end

@interface LNScrollView : UIView

@property (nonatomic, weak) NSObject <LNScrollViewDelegate> *delegate;

@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, assign, readonly) CGPoint contentOffset;
- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated;

@property (nonatomic, assign) BOOL bounces;
@property (nonatomic, assign) BOOL pageEnable;

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

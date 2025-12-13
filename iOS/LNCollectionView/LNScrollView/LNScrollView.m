//
//  LNScrollView.m
//  LNCollectionView
//
//  Created by Levison on 9.11.24.
//

#import "LNScrollView.h"
#import "LNScrollViewAutoEffect.h"
#import "LNScrollViewGestureEffect.h"
#import "LNScrollViewZoomingEffect.h"
#import "LNScrollViewClock.h"
#import "LNScrollViewContextObject.h"
#import "LNScrollViewDefaultEffectAxis.h"

typedef NS_ENUM(NSInteger, LNScrollViewMode) {
    LNScrollViewModeDefault = 0,
    LNScrollViewModeTracking = 1,
    LNScrollViewModeAuto = 2,
};

@interface LNScrollView(Pulse) <LNScrollViewPulserDelegate>
- (CGFloat)pulserGetVelocity:(LNScrollViewPulser *)pulser;
- (void)pulser:(LNScrollViewPulser *)pulser updateVelocity:(CGFloat)velocity;
@end

@interface LNScrollView () <LNScrollViewAutoEffectProtocol, LNScrollViewGestureEffectProtocol, LNScrollViewContextDelegate, UIGestureRecognizerDelegate, LNScrollViewZoomingEffectDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;

@property (nonatomic, assign) LNScrollViewMode mode;

@property (nonatomic, strong) LNScrollViewGestureEffect *gestureEffect;
@property (nonatomic, strong) LNScrollViewAutoEffect *autoEffect;
@property (nonatomic, strong) LNScrollViewZoomingEffect *zoomingEffect;

@property (nonatomic, strong) LNScrollViewContextObject *context;

@property (nonatomic, strong) LNScrollViewPulseGenerator *topPulseGenerator;
@property (nonatomic, strong) LNScrollViewPulseGenerator *leftPulseGenerator;
@property (nonatomic, strong) LNScrollViewPulseGenerator *bottomPulseGenerator;
@property (nonatomic, strong) LNScrollViewPulseGenerator *rightPulseGenerator;
@property (nonatomic, strong) LNScrollViewPulser *topPulser;
@property (nonatomic, strong) LNScrollViewPulser *leftPulser;
@property (nonatomic, strong) LNScrollViewPulser *bottomPulser;
@property (nonatomic, strong) LNScrollViewPulser *rightPulser;

@property (nonatomic, strong) LNScrollViewDefaultEffectAxis *defaultHorizontalAxis;
@property (nonatomic, strong) LNScrollViewDefaultEffectAxis *defaultVerticalAxis;

@end

@implementation LNScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.bounces = YES;
        self.zoomingBounces = YES;
        self.maxZoomingScale = 1;
        self.minZoomingScale = 1;
        self.contentInset = UIEdgeInsetsZero;
        [self addGestureRecognizer:self.panGesture];
        [self addGestureRecognizer:self.pinchGesture];
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.pinchGesture) {
        if ([self _getCurrentZoomingView] && (self.mode == LNScrollViewModeDefault || self.mode == LNScrollViewModeAuto)) {
            return YES;
        } else {
            return NO;
        }
    } else if (gestureRecognizer == self.panGesture) {
        if (self.mode == LNScrollViewModeAuto || self.mode == LNScrollViewModeDefault) {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated {
    if (CGPointEqualToPoint(contentOffset, [self contentOffset])) {
        return;
    }
    if (animated) {
        [self.autoEffect scrollTo:contentOffset];
    } else {
        [self setContentOffset:contentOffset];
    }
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    if (CGPointEqualToPoint(contentOffset, [self contentOffset])) {
        return;
    }
    self.bounds = CGRectMake(contentOffset.x, contentOffset.y, self.bounds.size.width, self.bounds.size.height);
    if (self.delegate && [self.delegate respondsToSelector:@selector(ln_scrollViewDidScroll:)]) {
        [self.delegate ln_scrollViewDidScroll:self];
    }
}

- (CGPoint)contentOffset
{
    return self.bounds.origin;
}

- (void)setPageEnable:(BOOL)pageEnable
{
    _pageEnable = pageEnable;
}

- (CGFloat)zoomingScale {
    return [self _currentZoomingScale];
}

- (CGFloat)_currentZoomingScale {
    UIView *zoominView = [self _getCurrentZoomingView];
    if (zoominView) {
        return zoominView.transform.a;
    }
    return 1;
}

- (nullable UIView *)_getCurrentZoomingView{
    if ([self.delegate respondsToSelector:@selector(ln_viewForZoomingInScrollView:)]) {
        UIView *zoomingView = [self.delegate ln_viewForZoomingInScrollView:self];
        if (zoomingView) {
            return zoomingView;
        }
    }
    return nil;
}

- (UIPanGestureRecognizer *)panGesture
{
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dealWithPanGesture:)];
    }
    return _panGesture;
}

- (CGPoint)convertedRealLocation{
    CGPoint location = [self.panGesture locationInView:self];
    CGPoint realLocation = CGPointMake(location.x - self.bounds.origin.x,
                                       location.y - self.bounds.origin.y);
    return realLocation;
}

- (void)dealWithPanGesture:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        [self.autoEffect finishForcely];
        self.mode = LNScrollViewModeTracking;
        CGPoint location = [self convertedRealLocation];
        [self.gestureEffect startWithGesturePosition:location];
        if (self.delegate && [self.delegate respondsToSelector:@selector(ln_scrollViewWillBeginDragging:)]) {
            [self.delegate ln_scrollViewWillBeginDragging:self];
        }
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        [self.autoEffect finishForcely];
        CGPoint location = [self convertedRealLocation];
        [self.gestureEffect updateGestureLocation:location];
    } else {
        [self.gestureEffect finish];
        CGPoint gestureVelocity = [panGesture velocityInView:self];
        CGPoint viewVelocity = CGPointMake(-gestureVelocity.x, -gestureVelocity.y);
        if (self.delegate && [self.delegate respondsToSelector:@selector(ln_scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
            //TODO: 这个targetContentOffset一般不用，需要再处理，需要从Effect中拿到一个预估值，并支持修改这个预估值
            CGPoint targetViewOffset = CGPointZero;
            [self.delegate ln_scrollViewWillEndDragging:self withVelocity:viewVelocity targetContentOffset:&targetViewOffset];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(ln_scrollViewWillBeginDecelerating:)]) {
            [self.delegate ln_scrollViewWillBeginDecelerating:self];
        }
        if ([self.autoEffect startWithVelocity:viewVelocity]) {
            self.mode = LNScrollViewModeAuto;
        } else {
            self.mode = LNScrollViewModeDefault;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(ln_scrollViewDidEndDragging:willDecelerate:)]) {
            //TODO: 这个回调的特性需要确认一下是只有减速的时候有回调，还是page/bounce也有回调
            [self.delegate ln_scrollViewDidEndDragging:self willDecelerate:YES];
        }
    }
}

- (UIPinchGestureRecognizer *)pinchGesture {
    if (!_pinchGesture) {
        _pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(dealWithPinchGesture:)];
        _pinchGesture.delegate = self;
    }
    return _pinchGesture;
}

- (void)dealWithPinchGesture:(UIPinchGestureRecognizer *)pinchGesture {
    UIView *targetView = [self _getCurrentZoomingView];
    if (targetView == nil) {
        //强制结束
        [self.panGesture setEnabled:YES];
        [self.zoomingEffect finish];
        self.mode = LNScrollViewModeDefault;
        return;
    }
    switch (pinchGesture.state) {
        case UIGestureRecognizerStateBegan: {
            //此时个数必为2
            [self.panGesture setEnabled:NO];
            [self.autoEffect finishForcely];
            self.mode = LNScrollViewModeTracking;
            CGPoint pinchCenter = [pinchGesture locationInView:self];
            CGPoint realLocationForDoubleTouch = [self realLocationForPinch:pinchGesture];
            [self.zoomingEffect startWithPinchCenter:pinchCenter
                                 realLocationForPinch:realLocationForDoubleTouch
                                           pinchScale:pinchGesture.scale];
        } break;
        case UIGestureRecognizerStateChanged: {
            //此时个数为1或者2
            self.mode = LNScrollViewModeTracking;
            CGPoint pinchCenter = [pinchGesture locationInView:self];
            CGPoint realLocationForPinchTouch = [self realLocationForPinch:pinchGesture];
            [self.zoomingEffect updateForPinch:pinchCenter
                          realLocationForPinch:realLocationForPinchTouch
                                    pinchScale:pinchGesture.scale
                                 numberOfPoint:pinchGesture.numberOfTouches];
        } break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStatePossible: {
            //此时个数大概率为1，小概率为2
            CGPoint pinchCenter = [pinchGesture locationInView:self];
            CGPoint realLocationForPinchTouch = [self realLocationForPinch:pinchGesture];
            [self.zoomingEffect updateForPinch:pinchCenter
                          realLocationForPinch:realLocationForPinchTouch
                                    pinchScale:pinchGesture.scale numberOfPoint:pinchGesture.numberOfTouches];
            if (targetView.transform.a < self.minZoomingScale) {
                [UIView animateWithDuration:0.3 animations:^{
                    [self.zoomingEffect updateForFinishAnimation:self.minZoomingScale];
                } completion:^(BOOL finished) {
                    [self.zoomingEffect finish];
                    self.mode = LNScrollViewModeDefault;
                }];
                //这里有个轻微震动
                UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
                [generator prepare];
                [generator impactOccurred];
            } else if (targetView.transform.a > self.maxZoomingScale) {
                [UIView animateWithDuration:0.3 animations:^{
                    [self.zoomingEffect updateForFinishAnimation:self.maxZoomingScale];
                } completion:^(BOOL finished) {
                    [self.zoomingEffect finish];
                    self.mode = LNScrollViewModeDefault;
                }];
                UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
                [generator prepare];
                [generator impactOccurred];
            } else {
                [self.zoomingEffect updateForAutoEffect:targetView.transform.a];
                if ([self.autoEffect startWithVelocity:CGPointZero forcelyBounces:YES]) {
                    self.mode = LNScrollViewModeAuto;
                } else {
                    self.mode = LNScrollViewModeDefault;
                }
            }
            [self.panGesture setEnabled:YES];
        } break;
    }
}

- (CGPoint)realLocationForPinch:(UIPinchGestureRecognizer *)pinch {
    CGPoint location = [pinch locationInView:self];
    CGPoint realLocation = CGPointMake(location.x - self.bounds.origin.x,
                                       location.y - self.bounds.origin.y);
    return realLocation;
}

- (LNScrollViewGestureEffect *)gestureEffect
{
    if (!_gestureEffect) {
        _gestureEffect = [[LNScrollViewGestureEffect alloc] initWithContext:self.context];
        _gestureEffect.delegate = self;
    }
    return _gestureEffect;
}

- (void)gestureEffectStatusDidChange:(LNScrollViewGestureStatus *)status
{
    self.contentOffset = status.convertedOffset;
}

- (LNScrollViewZoomingEffect *)zoomingEffect {
    if (!_zoomingEffect) {
        _zoomingEffect = [[LNScrollViewZoomingEffect alloc] initWithContext:self.context];
        _zoomingEffect.delegate = self;
    }
    return _zoomingEffect;
}

- (void)pinchEffectNeedSyncTransform {
    [self _getCurrentZoomingView].transform = self.zoomingEffect.getStatus.outputTransform;
}

- (void)pinchEffectNeedSyncContentSize {
    self.contentSize = self.zoomingEffect.getStatus.outputContentSize;
}

- (void)pinchEffectNeedSyncTargetCenter {
    [self _getCurrentZoomingView].center = self.zoomingEffect.getStatus.outputCenter;
}

- (void)pinchEffectNeedSyncContentOffset {
    self.contentOffset = self.zoomingEffect.getStatus.outputContentOffset;
}

- (LNScrollViewAutoEffect *)autoEffect
{
    if (!_autoEffect) {
        _autoEffect = [[LNScrollViewAutoEffect alloc] initWithContext:self.context];
        _autoEffect.delegate = self;
    }
    return _autoEffect;
}

- (CGSize)autoEffectGetContentSize:(LNScrollViewAutoEffect *)effect {
    return self.contentSize;
}

- (CGSize)autoEffectGetFrameSize:(LNScrollViewAutoEffect *)effect {
    return self.bounds.size;
}

- (CGPoint)autoEffectGetContentOffset:(LNScrollViewAutoEffect *)effect
{
    return self.contentOffset;
}

- (void)autoEffectStatusDidChange:(LNScrollViewRestStatus *)status
{
    self.contentOffset = status.offset;
}

- (void)autoEffectStatusHasFinished:(LNScrollViewAutoEffect *)effect
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ln_scrollViewDidEndDecelerating:)]) {
        [self.delegate ln_scrollViewDidEndDecelerating:self];
    }
}

- (LNScrollViewPulseGenerator *)topPulseGenerator
{
    if (!_topPulseGenerator) {
        _topPulseGenerator = [[LNScrollViewPulseGenerator alloc] init];
    }
    return _topPulseGenerator;
}

- (LNScrollViewPulseGenerator *)leftPulseGenerator
{
    if (!_leftPulseGenerator) {
        _leftPulseGenerator = [[LNScrollViewPulseGenerator alloc] init];
    }
    return _leftPulseGenerator;
}

- (LNScrollViewPulseGenerator *)bottomPulseGenerator
{
    if (!_bottomPulseGenerator) {
        _bottomPulseGenerator = [[LNScrollViewPulseGenerator alloc] init];
    }
    return _bottomPulseGenerator;
}

- (LNScrollViewPulseGenerator *)rightPulseGenerator
{
    if (!_rightPulseGenerator) {
        _rightPulseGenerator = [[LNScrollViewPulseGenerator alloc] init];
    }
    return _rightPulseGenerator;
}

- (LNScrollViewPulser *)topPulser
{
    if (!_topPulser) {
        _topPulser = [[LNScrollViewPulser alloc] init];
        _topPulser.delegate = self;
    }
    return _topPulser;
}

- (LNScrollViewPulser *)leftPulser
{
    if (!_leftPulser) {
        _leftPulser = [[LNScrollViewPulser alloc] init];
        _leftPulser.delegate = self;
    }
    return _leftPulser;
}

- (LNScrollViewPulser *)bottomPulser
{
    if (!_bottomPulser) {
        _bottomPulser = [[LNScrollViewPulser alloc] init];
        _bottomPulser.delegate = self;
    }
    return _bottomPulser;
}

- (LNScrollViewPulser *)rightPulser
{
    if (!_rightPulser) {
        _rightPulser = [[LNScrollViewPulser alloc] init];
        _rightPulser.delegate = self;
    }
    return _rightPulser;
}

- (LNScrollViewDefaultEffectAxis *)defaultHorizontalAxis {
    if (!_defaultHorizontalAxis) {
        _defaultHorizontalAxis = [[LNScrollViewDefaultEffectAxis alloc] init];
    }
    return _defaultHorizontalAxis;
}

- (LNScrollViewDefaultEffectAxis *)defaultVerticalAxis {
    if (!_defaultVerticalAxis) {
        _defaultVerticalAxis = [[LNScrollViewDefaultEffectAxis alloc] init];
    }
    return _defaultVerticalAxis;
}

- (LNScrollViewContextObject *)context {
    if (!_context) {
        _context = [[LNScrollViewContextObject alloc] initWithDelegate:self];
    }
    return _context;
}

- (CGSize)contextGetContentSize {
    return self.contentSize;
}

- (CGSize)contextGetFrameSize {
    return self.bounds.size;
}

- (CGPoint)contextGetContentOffset {
    return self.contentOffset;
}

- (UIEdgeInsets)contextGetContentInset {
    return self.contentInset;
}

- (BOOL)contextGetZoomingBounces {
    return self.zoomingBounces;
}

- (BOOL)contextGetBounces {
    return self.bounces;
}

- (BOOL)contextGetAlwaysBouncesVertical {
    return self.alwaysBouncesVertical;
}

- (BOOL)contextGetAlwaysBouncesHorizontal {
    return self.alwaysBouncesHorizontal;
}

- (BOOL)contextGetPageEnable {
    return self.pageEnable;
}

- (CGFloat)contextGetZoomingScale {
    return [self _currentZoomingScale];
}

- (CGFloat)contextGetMinZoomingScale {
    return self.minZoomingScale;
}

- (CGFloat)contextGetMaxZoomingScale {
    return self.maxZoomingScale;
}

- (CGSize)contextGetZoomingViewBoundSize {
    return [self _getCurrentZoomingView].bounds.size;
}

- (CGPoint)contextGetZoomingViewCenterPoint {
    return [self _getCurrentZoomingView].center;
}

- (LNScrollViewPulseGenerator *)contextGetTopPulseGenerator {
    return self.topPulseGenerator;
}

- (LNScrollViewPulseGenerator *)contextGetLeftPulseGenerator {
    return self.leftPulseGenerator;
}

- (LNScrollViewPulseGenerator *)contextGetBottomPulseGenerator {
    return self.bottomPulseGenerator;
}

- (LNScrollViewPulseGenerator *)contextGetRightPulseGenerator {
    return self.rightPulseGenerator;
}

- (LNScrollViewEffectAxis *)contextGetHorizontalAxis {
    return self.defaultHorizontalAxis;
}

- (LNScrollViewEffectAxis *)contextGetVerticalAxis {
    return self.defaultVerticalAxis;
}

@end

@implementation LNScrollView(Pulse)

//pulser
- (CGFloat)pulserGetVelocity:(LNScrollViewPulser *)pulser
{
    if ([self.autoEffect isFinished]) {
        return 0.f;
    }
    if (pulser == self.topPulser) {
        return self.autoEffect.getVelocity.y;
    } else if (pulser == self.leftPulser) {
        return self.autoEffect.getVelocity.x;
    } else if (pulser == self.bottomPulser) {
        return -self.autoEffect.getVelocity.y;
    } else if (pulser == self.rightPulser) {
        return -self.autoEffect.getVelocity.x;
    }
    return 0.f;
}

- (void)pulser:(LNScrollViewPulser *)pulser updateVelocity:(CGFloat)velocity
{
    if (!pulser) {
        return ;
    }
    
    if (![self.autoEffect isFinished]) {
        if (pulser == self.topPulser) {
            [self.autoEffect startWithVelocity:CGPointMake(self.autoEffect.getVelocity.x, velocity)];
        } else if (pulser == self.leftPulser) {
            [self.autoEffect startWithVelocity:CGPointMake(velocity, self.autoEffect.getVelocity.y)];
        } else if (pulser == self.bottomPulser) {
            [self.autoEffect startWithVelocity:CGPointMake(self.autoEffect.getVelocity.x, -velocity)];
        } else if (pulser == self.rightPulser) {
            [self.autoEffect startWithVelocity:CGPointMake(-velocity, self.autoEffect.getVelocity.y)];
        }
    } else {
        if (pulser == self.topPulser) {
            [self.autoEffect startWithVelocity:CGPointMake(0, velocity)];
        } else if (pulser == self.leftPulser) {
            [self.autoEffect startWithVelocity:CGPointMake(velocity, 0)];
        } else if (pulser == self.bottomPulser) {
            [self.autoEffect startWithVelocity:CGPointMake(0, -velocity)];
        } else if (pulser == self.rightPulser) {
            [self.autoEffect startWithVelocity:CGPointMake(-velocity, 0)];
        }
    }
}

@end

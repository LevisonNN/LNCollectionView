//
//  LNScrollView.m
//  LNCollectionView
//
//  Created by Levison on 9.11.24.
//

#import "LNScrollView.h"
#import "LNScrollViewAutoEffect.h"
#import "LNScrollViewGestureEffect.h"
#import "LNScrollViewClock.h"

typedef NS_ENUM(NSInteger, LNScrollViewMode) {
    LNScrollViewModeDefault = 0,
    LNScrollViewModeTracking = 1,
    LNScrollViewModeAuto = 2,
};

@interface LNScrollView () <LNScrollViewAutoEffectProtocol, LNScrollViewGestureEffectProtocol>

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, assign) LNScrollViewMode mode;

@property (nonatomic, strong) LNScrollViewGestureEffect *gestureEffect;
@property (nonatomic, strong) LNScrollViewAutoEffect *autoEffect;

@end

@implementation LNScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addGestureRecognizer:self.panGesture];
    }
    return self;
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    if (self.bounds.origin.x != contentOffset.x || self.bounds.origin.y != contentOffset.y) {
        self.bounds = CGRectMake(contentOffset.x, contentOffset.y, self.bounds.size.width, self.bounds.size.height);
        if (self.delegate && [self.delegate respondsToSelector:@selector(ln_scrollViewDidScroll:)]) {
            [self.delegate ln_scrollViewDidScroll:self];
        }
    }
}

- (CGPoint)contentOffset
{
    return self.bounds.origin;
}

- (void)setPageEnable:(BOOL)pageEnable
{
    _pageEnable = pageEnable;
    self.autoEffect.pageEnable = pageEnable;
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
        [self.gestureEffect startWithFrameSize:self.bounds.size
                                                contentSize:self.contentSize
                                              currentOffset:self.bounds.origin
                                            gesturePosition:location];
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
        if ([self.autoEffect startWithContentSize:self.contentSize
                                        frameSize:self.bounds.size
                                         velocity:viewVelocity
                                         position:self.bounds.origin]) {
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

- (LNScrollViewGestureEffect *)gestureEffect
{
    if (!_gestureEffect) {
        _gestureEffect = [[LNScrollViewGestureEffect alloc] init];
        _gestureEffect.delegate = self;
    }
    return _gestureEffect;
}

- (void)gestureEffectStatusDidChange:(LNScrollViewGestureStatus *)status
{
    self.contentOffset = status.convertedOffset;
}

- (LNScrollViewAutoEffect *)autoEffect
{
    if (!_autoEffect) {
        _autoEffect = [[LNScrollViewAutoEffect alloc] init];
        _autoEffect.delegate = self;
    }
    return _autoEffect;
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

@end

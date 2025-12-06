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
#import "LNScrollViewContextObject.h"

typedef NS_ENUM(NSInteger, LNScrollViewMode) {
    LNScrollViewModeDefault = 0,
    LNScrollViewModeTracking = 1,
    LNScrollViewModeAuto = 2,
};

@interface LNScrollView(Pulse) <LNScrollViewPulserDelegate>
- (CGFloat)pulserGetVelocity:(LNScrollViewPulser *)pulser;
- (void)pulser:(LNScrollViewPulser *)pulser updateVelocity:(CGFloat)velocity;
@end

@interface LNScrollView () <LNScrollViewAutoEffectProtocol, LNScrollViewGestureEffectProtocol, LNScrollViewContextDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, assign) LNScrollViewMode mode;

@property (nonatomic, strong) LNScrollViewGestureEffect *gestureEffect;
@property (nonatomic, strong) LNScrollViewAutoEffect *autoEffect;

@property (nonatomic, strong) LNScrollViewContextObject *context;

@property (nonatomic, strong) LNScrollViewPulseGenerator *topPulseGenerator;
@property (nonatomic, strong) LNScrollViewPulseGenerator *leftPulseGenerator;
@property (nonatomic, strong) LNScrollViewPulseGenerator *bottomPulseGenerator;
@property (nonatomic, strong) LNScrollViewPulseGenerator *rightPulseGenerator;
@property (nonatomic, strong) LNScrollViewPulser *topPulser;
@property (nonatomic, strong) LNScrollViewPulser *leftPulser;
@property (nonatomic, strong) LNScrollViewPulser *bottomPulser;
@property (nonatomic, strong) LNScrollViewPulser *rightPulser;

@end

@implementation LNScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.bounces = YES;
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

- (BOOL)contextGetBounces {
    return self.bounces;
}

- (BOOL)contextGetPageEnable {
    return self.pageEnable;
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

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
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        [self.autoEffect finishForcely];
        CGPoint location = [self convertedRealLocation];
        [self.gestureEffect updateGestureLocation:location];
    } else {
        [self.gestureEffect finish];
        CGPoint gestureVelocity = [panGesture velocityInView:self];
        CGPoint viewVelocity = CGPointMake(-gestureVelocity.x, -gestureVelocity.y);
        if ([self.autoEffect startWithContentSize:self.contentSize
                                        frameSize:self.bounds.size
                                         velocity:viewVelocity
                                         position:self.bounds.origin]) {
            self.mode = LNScrollViewModeAuto;
        } else {
            self.mode = LNScrollViewModeDefault;
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
    self.bounds = CGRectMake(status.convertedOffset.x,
                             status.convertedOffset.y,
                             self.bounds.size.width,
                             self.bounds.size.height);
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
    self.bounds = CGRectMake(status.offset.x,
                             status.offset.y,
                             self.bounds.size.width,
                             self.bounds.size.height);
}

@end

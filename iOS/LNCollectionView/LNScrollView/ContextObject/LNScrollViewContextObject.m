//
//  LNScrollViewContextObject.m
//  LNCollectionView
//
//  Created by Levison on 6.12.25.
//

#import "LNScrollViewContextObject.h"

@interface LNScrollViewContextObjectComponent()

@property (nonatomic, assign) BOOL isVertical;
@property (nonatomic, weak) LNScrollViewContextObject *context;

@end

@implementation LNScrollViewContextObjectComponent

- (instancetype)initWithContext:(LNScrollViewContextObject *)context isVertical:(BOOL)isVertical {
    self = [super init];
    if (self) {
        self.context = context;
        self.isVertical = isVertical;
    }
    return self;
}

- (CGFloat)contentSize {
    if (self.isVertical) {
        return self.context.contentSize.height;
    } else {
        return self.context.contentSize.width;
    }
}

- (CGFloat)frameSize {
    if (self.isVertical) {
        return self.context.frameSize.height;
    } else {
        return self.context.frameSize.width;
    }
}

- (CGFloat)contentOffset {
    if (self.isVertical) {
        return self.context.contentOffset.y;
    } else {
        return self.context.contentOffset.x;
    }
}

- (CGFloat)leadingInset {
    if (self.isVertical) {
        return self.context.contentInset.top;
    } else {
        return self.context.contentInset.left;
    }
}

- (CGFloat)trailingInset {
    if (self.isVertical) {
        return self.context.contentInset.bottom;
    } else {
        return self.context.contentInset.right;
    }
}

- (BOOL)bounces {
    return self.context.bounces;
}

- (BOOL)alwaysBounces {
    if (self.isVertical) {
        return self.context.alwaysBouncesVertical;
    } else {
        return self.context.alwaysBouncesHorizontal;
    }
}

- (BOOL)pageEnable {
    return self.context.pageEnable;
}

- (LNScrollViewPulseGenerator *)leadingGenerator {
    if (self.isVertical) {
        return self.context.topPulseGenerator;
    } else {
        return self.context.leftPulseGenerator;
    }
}

- (LNScrollViewPulseGenerator *)trailingGenerator {
    if (self.isVertical) {
        return self.context.bottomPulseGenerator;
    } else {
        return self.context.rightPulseGenerator;
    }
}

@end

@interface LNScrollViewContextObject()

@property (nonatomic, weak) NSObject<LNScrollViewContextDelegate> *delegate;

@property (nonatomic, strong) LNScrollViewContextObjectComponent *verticalComponent;
@property (nonatomic, strong) LNScrollViewContextObjectComponent *horizontalComponent;

@end

@implementation LNScrollViewContextObject

- (instancetype)initWithDelegate:(NSObject<LNScrollViewContextDelegate> *)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (CGSize)contentSize {
    return self.delegate.contextGetContentSize;
}

- (CGPoint)contentOffset {
    return self.delegate.contextGetContentOffset;
}

- (UIEdgeInsets)contentInset {
    return self.delegate.contextGetContentInset;
}

- (CGSize)frameSize {
    return self.delegate.contextGetFrameSize;
}

- (BOOL)bounces {
    return self.delegate.contextGetBounces;
}

- (BOOL)alwaysBouncesVertical {
    return self.delegate.contextGetAlwaysBouncesVertical;
}

- (BOOL)alwaysBouncesHorizontal {
    return self.delegate.contextGetAlwaysBouncesHorizontal;
}

- (BOOL)pageEnable {
    return self.delegate.contextGetPageEnable;
}

- (BOOL)zoomingBounces {
    return self.delegate.contextGetZoomingBounces;
}

- (CGPoint)zoomingViewCenterPoint {
    return self.delegate.contextGetZoomingViewCenterPoint;
}

- (CGSize)zoomingViewBoundSize {
    return self.delegate.contextGetZoomingViewBoundSize;
}

- (CGFloat)zoomingScale {
    return self.delegate.contextGetZoomingScale;
}

- (CGFloat)maxZoomingScale {
    return MAX(self.delegate.contextGetMinZoomingScale, self.delegate.contextGetMaxZoomingScale);
}

- (CGFloat)minZoomingScale {
    return MAX(0, self.delegate.contextGetMinZoomingScale);
}

- (LNScrollViewPulseGenerator *)topPulseGenerator {
    return self.delegate.contextGetTopPulseGenerator;
}

- (LNScrollViewPulseGenerator *)leftPulseGenerator {
    return self.delegate.contextGetLeftPulseGenerator;
}

- (LNScrollViewPulseGenerator *)bottomPulseGenerator {
    return self.delegate.contextGetBottomPulseGenerator;
}

- (LNScrollViewPulseGenerator *)rightPulseGenerator {
    return  self.delegate.contextGetRightPulseGenerator;
}

- (LNScrollViewEffectAxis *)horizontalAxis {
    return self.delegate.contextGetHorizontalAxis;
}

- (LNScrollViewEffectAxis *)verticalAxis {
    return  self.delegate.contextGetVerticalAxis;
}

- (LNScrollViewContextObjectComponent *)verticalComponent {
    if (!_verticalComponent) {
        _verticalComponent = [[LNScrollViewContextObjectComponent alloc] initWithContext:self isVertical:YES];
    }
    return _verticalComponent;
}

- (LNScrollViewContextObjectComponent *)horizontalComponent {
    if (!_horizontalComponent) {
        _horizontalComponent = [[LNScrollViewContextObjectComponent alloc] initWithContext:self isVertical:NO];
    }
    return _horizontalComponent;
}

@end

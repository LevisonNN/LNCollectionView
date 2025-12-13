//
//  LNScrollViewZoomingEffect.m
//  LNCollectionView
//
//  Created by Levison on 12.12.25.
//

#import "LNScrollViewZoomingEffect.h"

@interface LNScrollViewZoomingEffectStatus ()

@property (nonatomic, assign) CGFloat originalScale;
@property (nonatomic, assign) CGPoint offsetVector;
@property (nonatomic, assign) CGPoint realLocationForPinch;
//这个目前没用到，debug的时候可能用到
@property (nonatomic, assign) CGPoint pinchCenter;

@property (nonatomic, assign) NSUInteger numberOfPoint;

@property (nonatomic, assign) CGPoint outputCenter;
@property (nonatomic, assign) CGSize outputContentSize;
@property (nonatomic, assign) CGPoint outputContentOffset;
@property (nonatomic, assign) CGAffineTransform outputTransform;

@end

@implementation LNScrollViewZoomingEffectStatus

- (instancetype)init {
    self = [super init];
    if (self) {
        self.numberOfPoint = 2;
    }
    return self;
}

@end

@interface LNScrollViewZoomingEffect()

@property (nonatomic, weak) LNScrollViewContextObject *context;

@property (nonatomic, strong) LNScrollViewZoomingEffectStatus *status;

@end

@implementation LNScrollViewZoomingEffect

- (instancetype)initWithContext:(LNScrollViewContextObject *)context {
    self = [super init];
    if (self) {
        self.context = context;
    }
    return self;
}

- (LNScrollViewZoomingEffectStatus *)getStatus {
    return self.status;
}

- (void)startWithPinchCenter:(CGPoint)pinchCenter
        realLocationForPinch:(CGPoint)realLocationForPinch
                  pinchScale:(CGFloat)scale {
    [self finish];
    //这里scale一般不是以1开始，忽略了
    CGPoint offsetVector = CGPointMake((self.context.zoomingViewCenterPoint.x - pinchCenter.x)/scale, (self.context.zoomingViewCenterPoint.y - pinchCenter.y)/scale);
    LNScrollViewZoomingEffectStatus *status = [[LNScrollViewZoomingEffectStatus alloc] init];
    status.pinchCenter = pinchCenter;
    status.originalScale = self.context.zoomingScale;
    status.offsetVector = offsetVector;
    status.realLocationForPinch = realLocationForPinch;
    self.status = status;
    [self _pinchUpdateContentSizeWithPinchScale:scale];
    [self _pinchUpdateCenterWithPinchScale:scale];
    [self _pinchUpdateContentOffsetWithPinchScale:scale];
}

- (void)updateForPinch:(CGPoint)pinchCenter
  realLocationForPinch:(CGPoint)realLocationForPinch
            pinchScale:(CGFloat)scale
         numberOfPoint:(NSUInteger)numberOfPoint {
    //根据我的观察pinch这里一般是1或者2，好像不存在2以上的情况，包括系统相册里面也是最多生效两根手指。
    //所以这里假设只存在1、2两种情况先
    CGFloat newScale = [self _zoomingScaleFilter:scale * self.status.originalScale];
    CGFloat validPinchScale = newScale/self.status.originalScale;
    NSUInteger validNumberOfPoint = MAX(1, MIN(numberOfPoint, 2));
    if (validNumberOfPoint == 1 && self.status.numberOfPoint == 1) {
        //1不变
    } else if (validNumberOfPoint == 1 && self.status.numberOfPoint == 2) {
        //2切1，加个补偿向量
        self.status.numberOfPoint = validNumberOfPoint;
        CGPoint scaledOffset = CGPointMake(self.status.offsetVector.x * validPinchScale, self.status.offsetVector.y * validPinchScale);
        CGPoint newScaleVector = CGPointMake(scaledOffset.x - (realLocationForPinch.x - self.status.realLocationForPinch.x), scaledOffset.y - (realLocationForPinch.y - self.status.realLocationForPinch.y));
        CGPoint newVector = CGPointMake(newScaleVector.x/validPinchScale, newScaleVector.y/validPinchScale);
        self.status.offsetVector = newVector;
        
    } else if (validNumberOfPoint == 2 && self.status.numberOfPoint == 1) {
        //1切2，消除补偿向量
        self.status.numberOfPoint = validNumberOfPoint;
        CGPoint scaledOffset = CGPointMake(self.status.offsetVector.x * validPinchScale, self.status.offsetVector.y * validPinchScale);
        CGPoint newScaleVector = CGPointMake(scaledOffset.x - (realLocationForPinch.x - self.status.realLocationForPinch.x), scaledOffset.y - (realLocationForPinch.y - self.status.realLocationForPinch.y));
        CGPoint newVector = CGPointMake(newScaleVector.x/validPinchScale, newScaleVector.y/validPinchScale);
        self.status.offsetVector = newVector;
    } else {
        //普通双指情况
    }
    self.status.pinchCenter = pinchCenter;
    self.status.realLocationForPinch = realLocationForPinch;
    [self _updateAllWithPinchScale:scale];
}

- (void)_updateAllWithPinchScale:(CGFloat)scale {
    [self _pinchUpdateContentSizeWithPinchScale:scale];
    [self _pinchUpdateCenterWithPinchScale:scale];
    [self _pinchUpdateContentOffsetWithPinchScale:scale];
}

- (void)updateForAutoEffect:(CGFloat)stableScale {
    [self __pinchUpdateContentSizeWithFilteredScale:stableScale];
}

- (void)updateForFinishAnimation:(CGFloat)stableScale {
    [self __pinchUpdateContentSizeWithFilteredScale:stableScale];
    [self __pinchUpdateCenterWithFilteredScale:stableScale];
    [self __pinchUpdateContentOffsetWithFilteredScale:stableScale considerBounces:NO];
}

- (void)finish {
    self.status = nil;
}

//private

- (void)_pinchUpdateContentOffsetWithPinchScale:(CGFloat)scale {
    CGFloat newScale = [self _zoomingScaleFilter:scale * self.status.originalScale];
    [self __pinchUpdateContentOffsetWithFilteredScale:newScale considerBounces:YES];
}

- (void)__pinchUpdateContentOffsetWithFilteredScale:(CGFloat)filteredScale considerBounces:(BOOL)considerBounces {
    if (self.status != nil && self.status.originalScale != 0) {
        CGFloat newScale = filteredScale/self.status.originalScale;
        CGPoint newVector = CGPointMake(self.status.offsetVector.x * newScale, self.status.offsetVector.y * newScale);
        CGPoint realLocation = self.status.realLocationForPinch;
        CGFloat contentOffsetX = self.context.zoomingViewCenterPoint.x - newVector.x - realLocation.x;
        CGFloat contentOffsetY = self.context.zoomingViewCenterPoint.y - newVector.y - realLocation.y;
        CGFloat maxX = MAX(0, self.context.contentSize.width - self.context.frameSize.width);
        CGFloat minX = 0;
        CGFloat maxY = MAX(0, self.context.contentSize.height - self.context.frameSize.height);
        CGFloat minY = 0;
        if (self.context.bounces == YES && considerBounces) {
            if (contentOffsetX < minX) {
                CGFloat delta = minX - contentOffsetX;
                contentOffsetX = minX - [self _zoomingScaleOverPart:delta];
            } else if (contentOffsetX > maxX) {
                CGFloat delta = contentOffsetX - maxX;
                contentOffsetX = maxX + [self _zoomingScaleOverPart:delta];
            }
            
            if (contentOffsetY < minY) {
                CGFloat delta = minY - contentOffsetY;
                contentOffsetY = minY - [self _zoomingScaleOverPart:delta];
            } else if (contentOffsetY > maxY) {
                CGFloat delta = contentOffsetY - maxY;
                contentOffsetY = maxY + [self _zoomingScaleOverPart:delta];
            }
        } else {
            contentOffsetX = MAX(minX, MIN(contentOffsetX, maxX));
            contentOffsetY = MAX(minY, MIN(contentOffsetY, maxY));
        }
        self.status.outputContentOffset = CGPointMake(contentOffsetX, contentOffsetY);
        [self.delegate pinchEffectNeedSyncContentOffset];
    }
}

- (void)_pinchUpdateCenterWithPinchScale:(CGFloat)scale {
    CGFloat newScale = [self _zoomingScaleFilter:scale * self.status.originalScale];
    [self __pinchUpdateCenterWithFilteredScale:newScale];
}

- (void)__pinchUpdateCenterWithFilteredScale:(CGFloat)filteredScale {
    CGFloat originalScale = self.context.zoomingScale;
    CGPoint originalCenter = self.context.zoomingViewCenterPoint;
    CGSize  originalSize = self.context.zoomingViewBoundSize;
    CGFloat originalScaledWidth = originalSize.width * originalScale;
    CGFloat originalScaledHeight = originalSize.height * originalScale;
    CGFloat originalScaledX = originalCenter.x - originalScaledWidth/2.0;
    CGFloat originalScaledY = originalCenter.y - originalScaledHeight/2.0;
    CGFloat newScaledWidth = originalSize.width * filteredScale;
    CGFloat newScaledHeight = originalSize.height * filteredScale;
    CGFloat newCenterX = originalScaledX + newScaledWidth/2.0;
    CGFloat newCenterY = originalScaledY + newScaledHeight/2.0;
    
    self.status.outputCenter = CGPointMake(newCenterX, newCenterY);
    [self.delegate pinchEffectNeedSyncTargetCenter];
    self.status.outputTransform = CGAffineTransformMakeScale(filteredScale, filteredScale);
    [self.delegate pinchEffectNeedSyncTransform];
}

- (void)_pinchUpdateContentSizeWithPinchScale:(CGFloat)scale {
    CGFloat newScale = [self _zoomingScaleFilter:scale * self.status.originalScale];
    [self __pinchUpdateContentSizeWithFilteredScale:newScale];
}

- (void)__pinchUpdateContentSizeWithFilteredScale:(CGFloat)filteredScale {
    CGFloat boundsWidth = self.context.zoomingViewBoundSize.width;
    CGFloat boundsHeight = self.context.zoomingViewBoundSize.height;
    
    CGFloat newVisibleBoundsWidth = boundsWidth * filteredScale;
    CGFloat newVisibleBoundsHeight = boundsHeight * filteredScale;
    
    self.status.outputContentSize = CGSizeMake(newVisibleBoundsWidth, newVisibleBoundsHeight);
    [self.delegate pinchEffectNeedSyncContentSize];
}

- (CGFloat)_zoomingScaleFilter:(CGFloat)zoomingScale {
    if (self.context.zoomingBounces) {
        if (zoomingScale < self.context.minZoomingScale) {
            CGFloat delta = self.context.minZoomingScale - zoomingScale;
            return MAX(0, self.context.minZoomingScale - [self _zoomingScaleOverPart:delta]);
        } else if (zoomingScale > self.context.maxZoomingScale) {
            CGFloat delta = zoomingScale - self.context.maxZoomingScale;
            return self.context.maxZoomingScale + [self _zoomingScaleOverPart:delta];
        } else {
            return zoomingScale;
        }
    } else {
        return MAX(self.context.minZoomingScale, MIN(zoomingScale, self.context.maxZoomingScale));
    }
}

- (CGFloat)_zoomingScaleOverPart:(CGFloat)overPart {
    return (0.5 * overPart)/(1 + 0.0001 * overPart);
    
}

@end


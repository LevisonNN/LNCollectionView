//
//  LNScrollViewGestureConvertor.m
//  LNCollectionView
//
//  Created by 李为 on 2025/12/11.
//

#import "LNScrollViewGestureConvertor.h"

@interface LNScrollViewGestureConvertor()

@property (nonatomic, assign) CGFloat k;
@property (nonatomic, assign) CGFloat b;

@end

@implementation LNScrollViewGestureConvertor

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.k = 0.0001;
        self.b = 0.5;
    }
    return self;
}

- (CGFloat)convertOffsetWith:(CGFloat)gestureStartPosition
      gestureCurrentPosition:(CGFloat)gestureCurrentPosition
          gestureStartOffset:(CGFloat)gestureStartOffset
                leadingPoint:(CGFloat)leadingPoint
               trailingPoint:(CGFloat)trailingPoint {
    CGFloat gestureOffset = gestureCurrentPosition - gestureStartPosition;
    CGFloat targetOffset = gestureStartOffset - gestureOffset;
    if (gestureStartOffset < leadingPoint) {
        CGFloat revertOutside = [self revertScaleOutsidePart:(leadingPoint - gestureStartOffset)];
        if (-gestureOffset > revertOutside) {
            return leadingPoint - gestureOffset - revertOutside;
        } else {
            CGFloat targetRevert = revertOutside + gestureOffset;
            CGFloat scaleTargetRevert = [self scaleOutsidePart:targetRevert];
            return leadingPoint - scaleTargetRevert;
        }
    } else if (gestureStartOffset > trailingPoint) {
        CGFloat revertOutside = [self revertScaleOutsidePart:gestureStartOffset - trailingPoint];
        if (gestureOffset > revertOutside) {
            return trailingPoint - gestureOffset + revertOutside;
        } else {
            CGFloat targetRevert = revertOutside - gestureOffset;
            CGFloat scaleTargetRevert = [self scaleOutsidePart:targetRevert];
            return trailingPoint + scaleTargetRevert;
        }
    } else {
        if (targetOffset < leadingPoint) {
            CGFloat outsidePart = leadingPoint - targetOffset;
            CGFloat scaleOutsidePart = [self scaleOutsidePart:outsidePart];
            return leadingPoint - scaleOutsidePart;
        } else if (targetOffset > trailingPoint) {
            CGFloat outsidePart = targetOffset - trailingPoint;
            CGFloat scaleOutsidePart = [self scaleOutsidePart:outsidePart];
            return trailingPoint + scaleOutsidePart;
        } else {
            return targetOffset;
        }
    }
}

- (CGFloat)revertScaleOutsidePart:(CGFloat)outsidePart {
    return outsidePart/(self.b - self.k * outsidePart);
}

- (CGFloat)scaleOutsidePart:(CGFloat)outsidePart {
    return (self.b * outsidePart)/(1 + self.k * outsidePart);
}

@end

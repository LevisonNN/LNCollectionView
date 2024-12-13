//
//  LNScrollViewDragSimulator.m
//  LNCollectionView
//
//  Created by Levison on 7.11.24.
//

#import "LNScrollViewDragSimulator.h"

@interface LNScrollViewDragSimulator()

@property (nonatomic, assign) CGFloat leadingPoint;
@property (nonatomic, assign) CGFloat trailingPoint;

@property (nonatomic, assign) CGFloat startPoint;
@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, assign) CGFloat resultOffset;

@property (nonatomic, assign) CGFloat k;
@property (nonatomic, assign) CGFloat b;

@end

@implementation LNScrollViewDragSimulator

- (instancetype)initWithLeadingPoint:(CGFloat)leadingPoint
                       trailingPoint:(CGFloat)trailingPoint
                          startPoint:(CGFloat)startPoint
{
    self = [super init];
    if (self) {
        self.leadingPoint = leadingPoint;
        self.trailingPoint = trailingPoint;
        self.startPoint = startPoint;
        self.offset = 0;
        self.b = 0.5;
        self.k = 0.0001;
    }
    return self;
}

- (void)updateOffset:(CGFloat)offset
{
    self.offset = offset;
    CGFloat targetPoint = self.startPoint - offset;
    //TODO：试下不定积分
    if (self.startPoint < self.leadingPoint) {
        CGFloat revertOutside = [self revertScaleOutsidePart:(self.leadingPoint - self.startPoint)];
        if (-offset > revertOutside) {
            self.resultOffset = self.leadingPoint - offset - revertOutside;
        } else {
            CGFloat targetRevert = revertOutside + offset;
            CGFloat scaleTargetRevert = [self scaleOutsidePart:targetRevert];
            self.resultOffset = self.leadingPoint - scaleTargetRevert;
        }
    } else if (self.startPoint > self.trailingPoint) {
        CGFloat revertOutside = [self revertScaleOutsidePart:self.startPoint - self.trailingPoint];
        if (offset > revertOutside) {
            self.resultOffset = self.trailingPoint - offset + revertOutside;
        } else {
            CGFloat targetRevert = revertOutside - offset;
            CGFloat scaleTargetRevert = [self scaleOutsidePart:targetRevert];
            self.resultOffset = self.trailingPoint + scaleTargetRevert;
        }
    } else {
        if (targetPoint < self.leadingPoint) {
            CGFloat outsidePart = self.leadingPoint - targetPoint;
            CGFloat scaleOutsidePart = [self scaleOutsidePart:outsidePart];
            self.resultOffset = self.leadingPoint - scaleOutsidePart;
        } else if (targetPoint > self.trailingPoint) {
            CGFloat outsidePart = targetPoint - self.trailingPoint;
            CGFloat scaleOutsidePart = [self scaleOutsidePart:outsidePart];
            self.resultOffset = self.trailingPoint + scaleOutsidePart;
        } else {
            self.resultOffset = targetPoint;
        }
    }
}

- (CGFloat)revertScaleOutsidePart:(CGFloat)outsidePart {
    return outsidePart/(self.b - self.k * outsidePart);
}

- (CGFloat)scaleOutsidePart:(CGFloat)outsidePart {
    return (self.b * outsidePart)/(1 + self.k * outsidePart);
}

- (CGFloat)getResultOffset
{
    return self.resultOffset;
}

@end

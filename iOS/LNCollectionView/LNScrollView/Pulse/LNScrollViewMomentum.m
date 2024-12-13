//
//  LNScrollViewMomentum.m
//  LNCollectionView
//
//  Created by Levison on 28.11.24.
//

#import "LNScrollViewMomentum.h"

@interface LNScrollViewMomentum()

@end

@implementation LNScrollViewMomentum

- (void)setMass:(CGFloat)mass
{
    _mass = MAX(1, mass);
}

@end

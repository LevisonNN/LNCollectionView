//
//  LNCollectionViewCell.m
//  LNCollectionView
//
//  Created by Levison on 14.11.24.
//

#import "LNCollectionViewCell.h"

@implementation LNCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:(random()%255)/255.f green:(random()%255)/255.f blue:(random()%255)/255.f alpha:(random()%255)/255.f];
    }
    return self;
}

@end

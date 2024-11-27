//
//  LNCollectionViewCell.m
//  LNCollectionView
//
//  Created by Levison on 14.11.24.
//

#import "LNCollectionViewCell.h"

@interface LNCollectionViewCell ()

@property (nonatomic, copy, nullable) NSString *identifier;
@property (nonatomic, strong, nonnull) UIView *contentView;

@end

@implementation LNCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.contentView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.contentView.frame = self.bounds;
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

@end

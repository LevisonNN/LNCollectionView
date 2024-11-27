//
//  MainItemCell.m
//  LNCollectionView
//
//  Created by Levison on 27.11.24.
//

#import "MainItemCell.h"

@interface MainItemCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation MainItemCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
        self.layer.cornerRadius = 8.f;
        self.layer.masksToBounds = YES;
        self.contentView.backgroundColor = [UIColor colorWithRed:(random()%255)/255.f green:(random()%255)/255.f blue:(random()%255)/255.f alpha:1.f];
    }
    return self;
}

- (void)addSubviews
{
    [self.contentView addSubview:self.titleLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleLabel.frame = self.contentView.bounds;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

@end

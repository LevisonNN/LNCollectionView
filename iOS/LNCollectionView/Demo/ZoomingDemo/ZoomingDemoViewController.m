//
//  ZoomingDemoViewController.m
//  LNCollectionView
//
//  Created by Levison on 12.12.25.
//

#import "ZoomingDemoViewController.h"
#import "LNScrollView.h"

@interface ZoomingDemoViewController () <LNScrollViewDelegate>

@property (nonatomic, strong) LNScrollView *scrollView;

@property (nonatomic, strong) UIImageView *targetImageView;

@end

@implementation ZoomingDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.scrollView];
    self.scrollView.frame = self.view.bounds;
    [self.scrollView addSubview:self.targetImageView];
    self.targetImageView.frame = self.view.bounds;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (LNScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[LNScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.minZoomingScale = 0.5;
        _scrollView.maxZoomingScale = 2;
    }
    return _scrollView;
}

- (UIImageView *)targetImageView {
    if (!_targetImageView) {
        _targetImageView = [[UIImageView alloc] init];
        _targetImageView.image = [UIImage imageNamed:@"TestImage"];
    }
    return _targetImageView;
}

- (UIView *)ln_viewForZoomingInScrollView:(LNScrollView *)scrollView {
    return self.targetImageView;
}

@end

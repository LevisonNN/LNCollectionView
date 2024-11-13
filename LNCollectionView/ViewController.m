//
//  ViewController.m
//  LNCollectionView
//
//  Created by Levison on 7.11.24.
//

#import "ViewController.h"
#import "LNScrollView.h"

@interface ViewController () <LNScrollViewDelegate>

@property (nonatomic, strong) LNScrollView *scrollView;
@property (nonatomic, strong) UIView *redView;
@property (nonatomic, strong) UIView *greenView;
@property (nonatomic, strong) UIView *blueView;

@property (nonatomic, strong) UIView *purpleView;
@property (nonatomic, strong) UIView *pinkView;
@property (nonatomic, strong) UIView *yellowView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.scrollView];
    self.scrollView.frame = self.view.bounds;
    [self.scrollView addSubview:self.redView];
    [self.scrollView addSubview:self.greenView];
    [self.scrollView addSubview:self.blueView];
    [self.scrollView addSubview:self.purpleView];
    [self.scrollView addSubview:self.pinkView];
    [self.scrollView addSubview:self.yellowView];
    self.redView.frame = CGRectMake(0,
                                    0,
                                    self.scrollView.bounds.size.width,
                                    self.scrollView.bounds.size.height - 100);
    self.greenView.frame = CGRectMake(0,
                                      self.scrollView.bounds.size.height - 100,
                                      self.scrollView.bounds.size.width,
                                      self.scrollView.bounds.size.height);
    self.blueView.frame = CGRectMake(0,
                                     self.scrollView.bounds.size.height * 2 - 100,
                                     self.scrollView.bounds.size.width,
                                     self.scrollView.bounds.size.height);
    
    self.purpleView.frame = CGRectMake(self.scrollView.bounds.size.width,
                                       0,
                                       self.scrollView.bounds.size.width,
                                       self.scrollView.bounds.size.height - 100);
    self.pinkView.frame = CGRectMake(self.scrollView.bounds.size.width,
                                     self.scrollView.bounds.size.height - 100,
                                     self.scrollView.bounds.size.width,
                                     self.scrollView.bounds.size.height);
    self.yellowView.frame = CGRectMake(self.scrollView.bounds.size.width,
                                       self.scrollView.bounds.size.height * 2 - 100,
                                       self.scrollView.bounds.size.width,
                                       self.scrollView.bounds.size.height);
    
}

- (void)ln_scrollViewDidScroll:(LNScrollView *)scrollView
{
    //NSLog(@"ln_scrollViewDidScroll: (%@, %@)", @(scrollView.contentOffset.x), @(scrollView.contentOffset.y));
}

- (void)ln_scrollViewWillEndDragging:(LNScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    NSLog(@"ln_scrollViewWillEndDragging: (%@, %@)", @(scrollView.contentOffset.x), @(scrollView.contentOffset.y));
}

- (void)ln_scrollViewDidEndDragging:(LNScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"ln_scrollViewDidEndDragging: (%@, %@)", @(scrollView.contentOffset.x), @(scrollView.contentOffset.y));
}

- (void)ln_scrollViewWillBeginDecelerating:(LNScrollView *)scrollView
{
    NSLog(@"ln_scrollViewWillBeginDecelerating: (%@, %@)", @(scrollView.contentOffset.x), @(scrollView.contentOffset.y));
}

- (void)ln_scrollViewDidEndDecelerating:(LNScrollView *)scrollView
{
    NSLog(@"ln_scrollViewDidEndDecelerating: (%@, %@)", @(scrollView.contentOffset.x), @(scrollView.contentOffset.y));
}

- (LNScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[LNScrollView alloc] init];
        _scrollView.contentSize = CGSizeMake(self.view.bounds.size.width * 2, self.view.bounds.size.height * 3);
        _scrollView.pageEnable = YES;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIView *)redView
{
    if (!_redView) {
        _redView = [[UIView alloc] init];
        _redView.backgroundColor = [UIColor redColor];
    }
    return _redView;
}

- (UIView *)greenView
{
    if (!_greenView) {
        _greenView = [[UIView alloc] init];
        _greenView.backgroundColor = [UIColor greenColor];
    }
    return _greenView;
}

- (UIView *)blueView
{
    if (!_blueView) {
        _blueView = [[UIView alloc] init];
        _blueView.backgroundColor = [UIColor blueColor];
    }
    return _blueView;
}

- (UIView *)purpleView
{
    if (!_purpleView) {
        _purpleView = [[UIView alloc] init];
        _purpleView.backgroundColor = [UIColor purpleColor];
    }
    return _purpleView;
}

- (UIView *)pinkView
{
    if (!_pinkView) {
        _pinkView = [[UIView alloc] init];
        _pinkView.backgroundColor = [UIColor systemPinkColor];
    }
    return _pinkView;
}

- (UIView *)yellowView
{
    if (!_yellowView) {
        _yellowView = [[UIView alloc] init];
        _yellowView.backgroundColor = [UIColor yellowColor];
    }
    return _yellowView;
}

@end

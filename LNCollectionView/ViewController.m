//
//  ViewController.m
//  LNCollectionView
//
//  Created by Levison on 7.11.24.
//

#import "ViewController.h"
#import "LNScrollView.h"
#import "LNCollectionView.h"
#import "LNCollectionViewLayout.h"
#import "LNCollectionViewFlowLayout.h"

@interface ViewController ()
<LNCollectionViewDelegate,
LNCollectionViewDataSource,
LNCollectionViewDelegateFlowLayout>

@property (nonatomic, strong) LNCollectionView *collectionView;
@property (nonatomic, strong) LNCollectionViewFlowLayout *layout;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
    self.collectionView.frame = self.view.bounds;
    
}

- (void)ln_scrollViewDidScroll:(LNScrollView *)scrollView
{
    //NSLog(@"ln_scrollViewDidScroll: (%@, %@)", @(scrollView.contentOffset.x), @(scrollView.contentOffset.y));
}

- (void)ln_scrollViewWillEndDragging:(LNScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    //NSLog(@"ln_scrollViewWillEndDragging: (%@, %@)", @(scrollView.contentOffset.x), @(scrollView.contentOffset.y));
}

- (void)ln_scrollViewDidEndDragging:(LNScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //NSLog(@"ln_scrollViewDidEndDragging: (%@, %@)", @(scrollView.contentOffset.x), @(scrollView.contentOffset.y));
}

- (void)ln_scrollViewWillBeginDecelerating:(LNScrollView *)scrollView
{
    //NSLog(@"ln_scrollViewWillBeginDecelerating: (%@, %@)", @(scrollView.contentOffset.x), @(scrollView.contentOffset.y));
}

- (void)ln_scrollViewDidEndDecelerating:(LNScrollView *)scrollView
{
    //NSLog(@"ln_scrollViewDidEndDecelerating: (%@, %@)", @(scrollView.contentOffset.x), @(scrollView.contentOffset.y));
}

- (NSInteger)ln_numberOfSectionsInCollectionView:(LNCollectionView *)collectionView
{
    return 1;
}

- (NSInteger)ln_collectionView:(LNCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 100;
}

- (__kindof LNCollectionViewCell *)ln_collectionView:(LNCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LNCollectionViewCell *cell = [[LNCollectionViewCell alloc] init];
    cell.backgroundColor = [UIColor colorWithRed:(random()%255)/255.f green:(random()%255)/255.f blue:(random()%255)/255.f alpha:1.f];
    return cell;
}

- (CGSize)ln_collectionView:(LNCollectionView *)collectionView layout:(LNCollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(100.f, 100.f);
}

- (LNCollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [[LNCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

- (LNCollectionViewFlowLayout *)layout
{
    if (!_layout) {
        _layout = [[LNCollectionViewFlowLayout alloc] init];
        _layout.scrollDirection = LNCollectionViewScrollDirectionVertical;
    }
    return _layout;
}

@end

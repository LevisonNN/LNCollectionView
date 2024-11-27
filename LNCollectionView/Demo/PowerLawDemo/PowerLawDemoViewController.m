//
//  PowerLawDemoViewController.m
//  LNCollectionView
//
//  Created by Levison on 27.11.24.
//

#import "PowerLawDemoViewController.h"
#import "LNScrollView.h"
#import "LNCollectionView.h"
#import "LNCollectionViewLayout.h"
#import "LNCollectionViewFlowLayout.h"
#import "LNScrollViewPowerLawDecelerateSimulator.h"

@interface PowerLawDemoCell : LNCollectionViewCell

@property (nonatomic, strong) UILabel *label;

@end

@implementation PowerLawDemoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.label];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.label.frame = self.bounds;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
    }
    return _label;
}

@end

@interface PowerLawDemoViewController ()
<LNCollectionViewDelegate,
LNCollectionViewDataSource,
LNCollectionViewDelegateFlowLayout>

@property (nonatomic, strong) LNCollectionView *collectionView;
@property (nonatomic, strong) LNCollectionViewFlowLayout *layout;
@property (nonatomic, strong) UIButton *reloadButton;

@property (nonatomic, assign) NSInteger sectionCount;
@property (nonatomic, assign) NSInteger itemCount;


@end

@implementation PowerLawDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sectionCount = 10;
    self.itemCount = 10;
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.reloadButton];
    self.reloadButton.frame = CGRectMake(0, 0, 100, 200);
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.collectionView.frame = self.view.bounds;
}

- (NSInteger)ln_numberOfSectionsInCollectionView:(LNCollectionView *)collectionView
{
    return self.sectionCount;
}

- (NSInteger)ln_collectionView:(LNCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.itemCount;
}

- (__kindof LNCollectionViewCell *)ln_collectionView:(LNCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PowerLawDemoCell *cell = (PowerLawDemoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"kPowerLawDemoCell" forIndexPath:indexPath];
    cell.label.text = [NSString stringWithFormat:@"%@-%@", @(indexPath.section), @(indexPath.item)];
    return cell;
}

- (CGSize)ln_collectionView:(LNCollectionView *)collectionView layout:(LNCollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(100.f, 100.f);
}

- (LNScrollViewDecelerateSimulator *)ln_scrollViewHorizontalDecelerateSimulatorForPosition:(CGFloat)position velocity:(CGFloat)velocity {
    LNScrollViewPowerLawDecelerateSimulator *simulator = [[LNScrollViewPowerLawDecelerateSimulator alloc] initWithPosition:position velocity:velocity k:2 n:1.2];
    return simulator;
}

- (LNScrollViewDecelerateSimulator *)ln_scrollViewVerticalDecelerateSimulatorForPosition:(CGFloat)position velocity:(CGFloat)velocity {
    LNScrollViewPowerLawDecelerateSimulator *simulator = [[LNScrollViewPowerLawDecelerateSimulator alloc] initWithPosition:position velocity:velocity k:2 n:1.2];
    return simulator;
}

- (LNCollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [[LNCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.layer.masksToBounds = YES;
        [_collectionView registerClass:PowerLawDemoCell.class forCellWithReuseIdentifier:@"kPowerLawDemoCell"];
    }
    return _collectionView;
}

- (UIButton *)reloadButton
{
    if (!_reloadButton) {
        _reloadButton = [[UIButton alloc] init];
        [_reloadButton addTarget:self action:@selector(reloadCollectionView) forControlEvents:UIControlEventTouchUpInside];
        _reloadButton.backgroundColor = [UIColor blackColor];
    }
    return _reloadButton;
}

- (void)reloadCollectionView
{
    self.sectionCount = random()%3 + 10;
    self.itemCount = random()%5 + 5;
    [self.collectionView reloadData];
}

- (LNCollectionViewFlowLayout *)layout
{
    if (!_layout) {
        _layout = [[LNCollectionViewFlowLayout alloc] init];
        _layout.scrollDirection = LNCollectionViewScrollDirectionVertical;
        _layout.minimumLineSpacing = 10.f;
        _layout.minimumInteritemSpacing = 8.f;
        _layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    }
    return _layout;
}

@end


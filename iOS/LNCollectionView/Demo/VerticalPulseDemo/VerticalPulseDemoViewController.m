//
//  VerticalPulseDemoViewController.m
//  LNCollectionView
//
//  Created by Levison on 29.11.24.
//

#import "VerticalPulseDemoViewController.h"
#import "LNCollectionView.h"
#import "LNCollectionViewFlowLayout.h"
#import "LNScrollViewPulseConvertor.h"

@interface VerticalPulseDemoCell : LNCollectionViewCell

@property (nonatomic, strong) UILabel *label;

@end

@implementation VerticalPulseDemoCell

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


@interface VerticalPulseDemoViewController ()
<
LNCollectionViewDataSource,
LNCollectionViewDelegate,
LNCollectionViewDelegateFlowLayout
>

@property (nonatomic, strong) LNCollectionView *collectionView1;
@property (nonatomic, strong) LNCollectionViewFlowLayout *flowLayout1;
@property (nonatomic, strong) LNCollectionView *collectionView2;
@property (nonatomic, strong) LNCollectionViewFlowLayout *flowLayout2;

@property (nonatomic, strong) LNScrollViewPulseConvertor *bottomToTopConvertor;
@property (nonatomic, strong) LNScrollViewPulseConvertor *topToButtomConvertor;


@end

@implementation VerticalPulseDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.collectionView1];
    [self.view addSubview:self.collectionView2];
    [self.bottomToTopConvertor bindGenerator:self.collectionView1.bottomPulseGenerator];
    [self.bottomToTopConvertor bindPulser:self.collectionView2.topPulser];
    self.bottomToTopConvertor.isConversationOfEnergy = YES;
    self.collectionView1.bottomPulseGenerator.mass = 1.f;
    [self.collectionView1.bottomPulseGenerator open];
    self.collectionView2.topPulser.mass = 1.f;
    [self.collectionView2.topPulser open];
    
    [self.topToButtomConvertor bindGenerator:self.collectionView2.topPulseGenerator];
    [self.topToButtomConvertor bindPulser:self.collectionView1.bottomPulser];
    self.topToButtomConvertor.isConversationOfEnergy = YES;
    self.collectionView1.bottomPulser.mass = 1.f;
    [self.collectionView1.bottomPulser open];
    self.collectionView2.topPulseGenerator.mass = 1.f;
    [self.collectionView2.topPulseGenerator open];
    
    // Do any additional setup after loading the view.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.collectionView1.frame = CGRectMake(0, 0, self.view.bounds.size.width/2.f, self.view.bounds.size.height);
    self.collectionView2.frame = CGRectMake(self.view.bounds.size.width/2.f, 0, self.view.bounds.size.width/2.f, self.view.bounds.size.height);
}

- (NSInteger)ln_numberOfSectionsInCollectionView:(LNCollectionView *)collectionView
{
    return 1;
}

- (NSInteger)ln_collectionView:(LNCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 100;
}

- (CGSize)ln_collectionView:(LNCollectionView *)collectionView layout:(LNCollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(88.f, 88.f);
}

- (__kindof LNCollectionViewCell *)ln_collectionView:(LNCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VerticalPulseDemoCell *cell = (VerticalPulseDemoCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"kVerticalPulseDemoCell" forIndexPath:indexPath];
    cell.label.text = [NSString stringWithFormat:@"%@-%@", @(indexPath.section), @(indexPath.item)];
    return cell;
}

- (LNCollectionView *)collectionView1
{
    if (!_collectionView1) {
        _collectionView1 = [[LNCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout1];
        _collectionView1.dataSource = self;
        _collectionView1.delegate = self;
        _collectionView1.tag = 1;
        _collectionView1.layer.masksToBounds = YES;
        [_collectionView1 registerClass:VerticalPulseDemoCell.class forCellWithReuseIdentifier:@"kVerticalPulseDemoCell"];
    }
    return _collectionView1;
}

- (LNCollectionViewFlowLayout *)flowLayout1
{
    if (!_flowLayout1) {
        _flowLayout1 = [[LNCollectionViewFlowLayout alloc] init];
        _flowLayout1.scrollDirection = LNCollectionViewScrollDirectionVertical;
    }
    return _flowLayout1;
}

- (LNCollectionView *)collectionView2
{
    if (!_collectionView2) {
        _collectionView2 = [[LNCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout2];
        _collectionView2.delegate = self;
        _collectionView2.dataSource = self;
        _collectionView2.tag = 2;
        _collectionView2.layer.masksToBounds = YES;
        [_collectionView2 registerClass:VerticalPulseDemoCell.class forCellWithReuseIdentifier:@"kVerticalPulseDemoCell"];
    }
    return _collectionView2;
}

- (LNCollectionViewFlowLayout *)flowLayout2
{
    if (!_flowLayout2) {
        _flowLayout2 = [[LNCollectionViewFlowLayout alloc] init];
        _flowLayout2.scrollDirection = LNCollectionViewScrollDirectionVertical;
    }
    return _flowLayout2;
}

- (LNScrollViewPulseConvertor *)bottomToTopConvertor
{
    if (!_bottomToTopConvertor) {
        _bottomToTopConvertor = [[LNScrollViewPulseConvertor alloc] init];
    }
    return _bottomToTopConvertor;
}

- (LNScrollViewPulseConvertor *)topToButtomConvertor
{
    if (!_topToButtomConvertor) {
        _topToButtomConvertor = [[LNScrollViewPulseConvertor alloc] init];
    }
    return _topToButtomConvertor;
}

@end

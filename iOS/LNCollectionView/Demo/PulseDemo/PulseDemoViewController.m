//
//  PulseDemoViewController.m
//  LNCollectionView
//
//  Created by Levison on 29.11.24.
//

#import "PulseDemoViewController.h"
#import "LNCollectionView.h"
#import "LNCollectionViewFlowLayout.h"
#import "LNScrollViewPulseConvertor.h"

@interface PulseDemoCell : LNCollectionViewCell

@property (nonatomic, strong) UILabel *label;

@end

@implementation PulseDemoCell

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


@interface PulseDemoViewController ()
<
LNCollectionViewDataSource,
LNCollectionViewDelegate,
LNCollectionViewDelegateFlowLayout
>

@property (nonatomic, strong) LNCollectionView *collectionView1;
@property (nonatomic, strong) LNCollectionViewFlowLayout *flowLayout1;
@property (nonatomic, strong) LNCollectionView *collectionView2;
@property (nonatomic, strong) LNCollectionViewFlowLayout *flowLayout2;

@property (nonatomic, strong) LNScrollViewPulseConvertor *rightToLeftConvertor;
@property (nonatomic, strong) LNScrollViewPulseConvertor *leftToRightConvertor;

@end

@implementation PulseDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.collectionView1];
    [self.view addSubview:self.collectionView2];
    [self.rightToLeftConvertor bindGenerator:self.collectionView1.rightPulseGenerator];
    [self.rightToLeftConvertor bindPulser:self.collectionView2.leftPulser];
    self.rightToLeftConvertor.isConversationOfEnergy = YES;
    self.collectionView1.rightPulseGenerator.mass = 1.f;
    self.collectionView2.leftPulser.mass = 1.f;
    
    [self.leftToRightConvertor bindGenerator:self.collectionView2.leftPulseGenerator];
    [self.leftToRightConvertor bindPulser:self.collectionView1.rightPulser];
    self.leftToRightConvertor.isConversationOfEnergy = YES;
    self.collectionView1.rightPulser.mass = 1.f;
    self.collectionView2.leftPulseGenerator.mass = 1.f;
    
    // Do any additional setup after loading the view.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.collectionView1.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height/2.f);
    self.collectionView2.frame = CGRectMake(0, self.view.bounds.size.height/2.f, self.view.bounds.size.width, self.view.bounds.size.height/2.f);
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
    PulseDemoCell *cell = (PulseDemoCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"kPulseDemoCell" forIndexPath:indexPath];
    cell.label.text = [NSString stringWithFormat:@"%@-%@", @(indexPath.section), @(indexPath.item)];
    return cell;
}

- (LNCollectionView *)collectionView1
{
    if (!_collectionView1) {
        _collectionView1 = [[LNCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout1];
        _collectionView1.dataSource = self;
        _collectionView1.delegate = self;
        [_collectionView1.rightPulseGenerator open];
        [_collectionView1.rightPulser open];
        _collectionView1.tag = 1;
        [_collectionView1 registerClass:PulseDemoCell.class forCellWithReuseIdentifier:@"kPulseDemoCell"];
    }
    return _collectionView1;
}

- (LNCollectionViewFlowLayout *)flowLayout1
{
    if (!_flowLayout1) {
        _flowLayout1 = [[LNCollectionViewFlowLayout alloc] init];
        _flowLayout1.scrollDirection = LNCollectionViewScrollDirectionHorizontal;
    }
    return _flowLayout1;
}

- (LNCollectionView *)collectionView2
{
    if (!_collectionView2) {
        _collectionView2 = [[LNCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout2];
        _collectionView2.delegate = self;
        _collectionView2.dataSource = self;
        [_collectionView2.leftPulser open];
        [_collectionView2.leftPulseGenerator open];
        _collectionView2.tag = 2;
        [_collectionView2 registerClass:PulseDemoCell.class forCellWithReuseIdentifier:@"kPulseDemoCell"];
    }
    return _collectionView2;
}

- (LNCollectionViewFlowLayout *)flowLayout2
{
    if (!_flowLayout2) {
        _flowLayout2 = [[LNCollectionViewFlowLayout alloc] init];
        _flowLayout2.scrollDirection = LNCollectionViewScrollDirectionHorizontal;
    }
    return _flowLayout2;
}

- (LNScrollViewPulseConvertor *)rightToLeftConvertor
{
    if (!_rightToLeftConvertor) {
        _rightToLeftConvertor = [[LNScrollViewPulseConvertor alloc] init];
    }
    return _rightToLeftConvertor;
}

- (LNScrollViewPulseConvertor *)leftToRightConvertor
{
    if (!_leftToRightConvertor) {
        _leftToRightConvertor = [[LNScrollViewPulseConvertor alloc] init];
    }
    return _leftToRightConvertor;
}

@end

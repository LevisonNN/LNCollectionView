//
//  MainViewController.m
//  LNCollectionView
//
//  Created by Levison on 27.11.24.
//

#import "MainViewController.h"
#import "MainItemCell.h"
#import "CommonDemoViewController.h"
#import "PowerLawDemoViewController.h"
#import "PulseDemoViewController.h"
#import "VerticalPulseDemoViewController.h"

@interface DemoObject : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) Class vcClass;

@end

@implementation DemoObject

@end

@interface MainViewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout
>

//系统的UICollectionView
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, copy) NSArray<DemoObject *> *modelList;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self buildDemoModels];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.collectionView];
    self.collectionView.frame = self.view.bounds;
}

- (void)buildDemoModels
{
    NSMutableArray<DemoObject *> *mArr = [[NSMutableArray alloc] init];

    DemoObject *commonObj = [[DemoObject alloc] init];
    commonObj.title = @"Common";
    commonObj.vcClass = CommonDemoViewController.class;
    [mArr addObject:commonObj];
    
    DemoObject *powerLawObj = [[DemoObject alloc] init];
    powerLawObj.title = @"PowerLaw";
    powerLawObj.vcClass = PowerLawDemoViewController.class;
    [mArr addObject:powerLawObj];
    
    DemoObject *pulseObj = [[DemoObject alloc] init];
    pulseObj.title = @"Pulse";
    pulseObj.vcClass = PulseDemoViewController.class;
    [mArr addObject:pulseObj];
    
    DemoObject *verticalPulseObj = [[DemoObject alloc] init];
    verticalPulseObj.title = @"verticalPulse";
    verticalPulseObj.vcClass = VerticalPulseDemoViewController.class;
    [mArr addObject:verticalPulseObj];
    
    self.modelList = [NSArray arrayWithArray:mArr];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.modelList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MainItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"kMainItemCell" forIndexPath:indexPath];
    cell.titleLabel.text = self.modelList[indexPath.item].title;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DemoObject *obj = self.modelList[indexPath.item];
    UIViewController *vc = [[[obj vcClass] alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((self.view.bounds.size.width - 8.f * 2 - 16.f * 2)/3.f - 1.f, 33.f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 8.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 8.f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(16.f, 16.f, 16.f, 16.f);
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:MainItemCell.class forCellWithReuseIdentifier:@"kMainItemCell"];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout
{
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _flowLayout;
}

@end

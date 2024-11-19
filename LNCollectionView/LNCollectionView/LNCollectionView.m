//
//  LNCollectionView.m
//  LNCollectionView
//
//  Created by Levison on 13.11.24.
//

#import "LNCollectionView.h"
#import "LNCollectionViewCell.h"
#import "LNCollectionViewReusePool.h"

@interface LNCollectionViewLayout (UICollectionViewNeed)

@property (nullable, nonatomic) LNCollectionView *collectionView;

@end

@interface LNCollectionView ()

@property (nonatomic, strong) LNCollectionViewLayout *collectionViewLayout;

@property (nonatomic, copy) NSArray<LNCollectionViewLayoutAttributes *> *currentAttributesArr;
@property (nonatomic, strong) NSMutableDictionary<NSIndexPath *, LNCollectionViewCell *> *currentCells;

@property (nonatomic, assign) BOOL hasInitialized;

@property (nonatomic, strong) LNCollectionViewReusePool *pool;

@end

@implementation LNCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(LNCollectionViewLayout *)layout
{
    self = [super initWithFrame:frame];
    if (self) {
        self.collectionViewLayout = layout;
        self.collectionViewLayout.collectionView = self;
    }
    return self;
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
    [self checkVisible];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //其他时机是reloadData
    if (!self.hasInitialized) {
        [self.collectionViewLayout prepareLayout];
        [self checkVisible];
        self.hasInitialized = YES;
    }
}

- (void)reloadData
{
    for (LNCollectionViewLayoutAttributes *attributes in self.currentAttributesArr) {
        LNCollectionViewCell *cell = [self.currentCells objectForKey:attributes.indexPath];
        [cell removeFromSuperview];
        [self.currentCells removeObjectForKey:attributes.indexPath];
        [self.pool addReusableCell:cell];
    }
    [self.currentCells removeAllObjects];
    self.currentAttributesArr = @[];
    [self.collectionViewLayout invalidateLayout];
    [self.collectionViewLayout prepareLayout];
    [self checkVisible];
}

- (void)checkVisible
{
    NSArray<LNCollectionViewLayoutAttributes *> *currentAttributesArr = [self.collectionViewLayout layoutAttributesForElementsInRect:self.bounds];
    NSSet<LNCollectionViewLayoutAttributes *> *visibleAttributesSet = [NSSet setWithArray:self.currentAttributesArr];
    NSSet<LNCollectionViewLayoutAttributes *> *newAttributesSet = [NSSet setWithArray:currentAttributesArr];
    NSMutableSet<LNCollectionViewLayoutAttributes *> *newlyVisibleAttributesMSet= [newAttributesSet mutableCopy];
    [newlyVisibleAttributesMSet minusSet:visibleAttributesSet];
    NSMutableSet<LNCollectionViewLayoutAttributes *> *disappearingAttributesMSet = [visibleAttributesSet mutableCopy];
    [disappearingAttributesMSet minusSet:newAttributesSet];
    for (LNCollectionViewLayoutAttributes *attributes in newlyVisibleAttributesMSet) {
        //willDisplay
        LNCollectionViewCell *cell = [self.dataSource ln_collectionView:self cellForItemAtIndexPath:attributes.indexPath];
        [self.currentCells setObject:cell forKey:attributes.indexPath];
        [self addSubview:cell];
        cell.frame = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:attributes.indexPath].frame;
    }

    for (LNCollectionViewLayoutAttributes *attributes in disappearingAttributesMSet) {
        //willDisappear
        LNCollectionViewCell *cell = [self.currentCells objectForKey:attributes.indexPath];
        [cell removeFromSuperview];
        [self.currentCells removeObjectForKey:attributes.indexPath];
        [self.pool addReusableCell:cell];
    }
    self.currentAttributesArr = newAttributesSet.allObjects;
    self.contentSize = self.collectionViewLayout.collectionViewContentSize;
}

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier
{
    [self.pool registerClass:cellClass forCellWithReuseIdentifier:identifier];
}

- (__kindof LNCollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath
{
    return [self.pool dequeueReusableCellWithIdentifier:identifier];
}

- (NSMutableDictionary<NSIndexPath *, LNCollectionViewCell *> *)currentCells
{
    if (!_currentCells) {
        _currentCells = [[NSMutableDictionary alloc] init];
    }
    return _currentCells;
}

- (LNCollectionViewReusePool *)pool
{
    if (!_pool) {
        _pool = [[LNCollectionViewReusePool alloc] init];
    }
    return _pool;
}

@end

//
//  LNCollectionViewLayout.m
//  LNCollectionView
//
//  Created by Levison on 13.11.24.
//

#import "LNCollectionViewLayout.h"
#import "LNCollectionView.h"

@interface LNCollectionViewLayout ()

@property (nullable, nonatomic) LNCollectionView *collectionView;


@end

@implementation LNCollectionViewLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)invalidateLayout
{
    
}

@end

@implementation LNCollectionViewLayout(SubclassingHooks)

- (void)prepareLayout
{
    
}

- (CGSize)collectionViewContentSize {
    return CGSizeZero;
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return @[];
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    return CGPointZero;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset;
{
    return CGPointZero;
}

@end

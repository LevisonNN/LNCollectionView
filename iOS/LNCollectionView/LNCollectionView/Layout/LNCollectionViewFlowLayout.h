//
//  LNCollectionViewFlowLayout.h
//  LNCollectionView
//
//  Created by Levison on 16.11.24.
//

#import "LNCollectionViewLayout.h"

NS_ASSUME_NONNULL_BEGIN

@class LNCollectionView;

typedef NS_ENUM(NSInteger, LNCollectionViewScrollDirection) {
    LNCollectionViewScrollDirectionVertical = 0,
    LNCollectionViewScrollDirectionHorizontal
};

@protocol LNCollectionViewDelegateFlowLayout
@optional
- (CGSize)ln_collectionView:(LNCollectionView *)collectionView layout:(LNCollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)ln_collectionView:(LNCollectionView *)collectionView layout:(LNCollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
- (CGFloat)ln_collectionView:(LNCollectionView *)collectionView layout:(LNCollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;

@end

@interface LNCollectionViewFlowLayout : LNCollectionViewLayout

@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) CGFloat minimumInteritemSpacing;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) UIEdgeInsets sectionInset;
@property (nonatomic) LNCollectionViewScrollDirection scrollDirection;

@end

NS_ASSUME_NONNULL_END

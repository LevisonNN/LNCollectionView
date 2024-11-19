//
//  LNCollectionView.h
//  LNCollectionView
//
//  Created by Levison on 13.11.24.
//

#import "LNScrollView.h"
#import "LNCollectionViewLayout.h"
#import "LNCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@class LNCollectionView;

@protocol LNCollectionViewDataSource
@required
- (NSInteger)ln_collectionView:(LNCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
- (__kindof LNCollectionViewCell *)ln_collectionView:(LNCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (NSInteger)ln_numberOfSectionsInCollectionView:(LNCollectionView *)collectionView;
@end

@protocol LNCollectionViewDelegate<LNScrollViewDelegate>
@optional
- (BOOL)ln_collectionView:(LNCollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)ln_collectionView:(LNCollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)ln_collectionView:(LNCollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)ln_collectionView:(LNCollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)ln_collectionView:(LNCollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)ln_collectionView:(LNCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)ln_collectionView:(LNCollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)ln_collectionView:(LNCollectionView *)collectionView canPerformPrimaryActionForItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)ln_collectionView:(LNCollectionView *)collectionView performPrimaryActionForItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)ln_collectionView:(LNCollectionView *)collectionView willDisplayCell:(LNCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)ln_collectionView:(LNCollectionView *)collectionView didEndDisplayingCell:(LNCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface LNCollectionView : LNScrollView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(LNCollectionViewLayout *)layout;
@property (nonatomic, strong, readonly) LNCollectionViewLayout *collectionViewLayout;
@property (nonatomic, weak, nullable) id <UICollectionViewDelegate> delegate;
@property (nonatomic, weak, nullable) id <LNCollectionViewDataSource> dataSource;

- (void)reloadData;

- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (__kindof LNCollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END

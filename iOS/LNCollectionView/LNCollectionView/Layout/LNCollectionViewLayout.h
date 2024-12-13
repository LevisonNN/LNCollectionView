//
//  LNCollectionViewLayout.h
//  LNCollectionView
//
//  Created by Levison on 13.11.24.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LNCollectionViewLayoutAttributes.h"

@class LNCollectionView;

NS_ASSUME_NONNULL_BEGIN

@interface LNCollectionViewLayout : NSObject

- (instancetype)init;
@property (nullable, nonatomic, readonly) LNCollectionView *collectionView;

- (void)invalidateLayout;

@end

//先实现这几个
@interface LNCollectionViewLayout (SubclassingHooks)

- (void)prepareLayout;
- (nullable NSArray<__kindof LNCollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect;
- (nullable LNCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity;
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset;
@property(nonatomic, readonly) CGSize collectionViewContentSize;

@end

NS_ASSUME_NONNULL_END

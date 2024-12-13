//
//  LNCollectionViewFlowLayout.m
//  LNCollectionView
//
//  Created by Levison on 16.11.24.
//

#import "LNCollectionViewFlowLayout.h"
#import "LNCollectionView.h"

@interface LNCollectionViewFlowLayout()

@property (nonatomic, assign) CGSize collectionViewContentSize;
@property (nonatomic, copy) NSArray<NSIndexPath *> *indexPathArr;
@property (nonatomic, copy) NSDictionary<NSIndexPath *, NSValue *> *frameDic;
@property (nonatomic, strong) NSMutableDictionary<NSIndexPath *, LNCollectionViewLayoutAttributes *> *attributesMDic;

@end

@implementation LNCollectionViewFlowLayout

- (NSDictionary *)_getSizingInfos
{
    if (self.scrollDirection == LNCollectionViewScrollDirectionHorizontal) {
        CGFloat height = self.collectionView.frame.size.height;
        NSInteger sectionCount = [self.collectionView.dataSource ln_numberOfSectionsInCollectionView:self.collectionView];
        CGFloat cursorY = 0;
        CGFloat cursorX = 0;
        CGFloat lineWidth = 0;
        NSMutableDictionary<NSIndexPath*, NSValue *> *mDic = [[NSMutableDictionary alloc] init];
        NSMutableArray<NSIndexPath *> *indexPathMArr = [[NSMutableArray alloc] init];
        for (int sectionIndex = 0 ; sectionIndex < sectionCount ; sectionIndex ++) {
            NSInteger itemCount = [self.collectionView.dataSource ln_collectionView:self.collectionView numberOfItemsInSection:sectionIndex];
            cursorX = cursorX + self.sectionInset.left;
            lineWidth = 0;
            cursorY = self.sectionInset.top;
            for (int itemIndex = 0; itemIndex < itemCount; itemIndex ++) {
                CGSize itemSize = [(id<LNCollectionViewDelegateFlowLayout>)self.collectionView.delegate ln_collectionView:self.collectionView layout:self sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex]];
                if (cursorY > 0 && cursorY + itemSize.height + self.sectionInset.bottom >= height) {
                    cursorX = cursorX + lineWidth + self.minimumLineSpacing;
                    lineWidth = 0;
                    cursorY = self.sectionInset.top;
                }
                if (lineWidth < itemSize.width) {
                    lineWidth = itemSize.width;
                }
                CGRect itemRect = CGRectMake(cursorX, cursorY, itemSize.width, itemSize.height);
                cursorY = CGRectGetMaxY(itemRect) + self.minimumInteritemSpacing;
                NSValue *value = [NSValue valueWithCGRect:itemRect];
                mDic[[NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex]] = value;
                [indexPathMArr addObject:[NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex]];
            }
            cursorX = cursorX + lineWidth + self.sectionInset.right;
        }
        self.indexPathArr = [NSArray arrayWithArray:indexPathMArr];
        self.collectionViewContentSize = CGSizeMake(cursorX, self.collectionView.bounds.size.height);
        return [NSDictionary dictionaryWithDictionary:mDic];
    } else {
        CGFloat width = self.collectionView.frame.size.width;
        NSInteger sectionCount = [self.collectionView.dataSource ln_numberOfSectionsInCollectionView:self.collectionView];
        CGFloat cursorX = 0;
        CGFloat cursorY = 0;
        CGFloat lineHeight = 0;
        NSMutableDictionary<NSIndexPath *, NSValue *> *mDic = [[NSMutableDictionary alloc] init];
        NSMutableArray<NSIndexPath *> *indexPathMArr = [[NSMutableArray alloc] init];
        for (int sectionIndex = 0 ; sectionIndex < sectionCount ; sectionIndex++) {
            NSInteger itemCount = [self.collectionView.dataSource ln_collectionView:self.collectionView numberOfItemsInSection:sectionIndex];
            cursorY = cursorY + self.sectionInset.top;
            lineHeight = 0;
            cursorX = self.sectionInset.left;
            for (int itemIndex = 0; itemIndex < itemCount ; itemIndex++) {
                CGSize itemSize = [(id<LNCollectionViewDelegateFlowLayout>)self.collectionView.delegate ln_collectionView:self.collectionView layout:self sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex]];
                if (cursorX > 0 && cursorX + itemSize.width + self.sectionInset.right >= width) {
                    cursorY = cursorY + lineHeight + self.minimumLineSpacing;
                    lineHeight = 0;
                    cursorX = self.sectionInset.left;
                }
                if (lineHeight < itemSize.height) {
                    lineHeight = itemSize.height;
                }
                CGRect itemRect = CGRectMake(cursorX, cursorY, itemSize.width, itemSize.height);
                cursorX = CGRectGetMaxX(itemRect) + self.minimumInteritemSpacing;
                NSValue *value = [NSValue valueWithCGRect:itemRect];
                mDic[[NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex]] = value;
                [indexPathMArr addObject:[NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex]];
            }
            cursorY = cursorY + lineHeight + self.sectionInset.bottom;
        }
        self.indexPathArr = [NSArray arrayWithArray:indexPathMArr];
        self.collectionViewContentSize = CGSizeMake(self.collectionView.bounds.size.width, cursorY);
        return [NSDictionary dictionaryWithDictionary:mDic];
    }
}

- (void)prepareLayout
{
    self.frameDic = [self _getSizingInfos];
}

- (void)invalidateLayout
{
    self.indexPathArr = nil;
    self.frameDic = nil;
    [self.attributesMDic removeAllObjects];
    self.collectionViewContentSize = CGSizeZero;
}

- (nullable NSArray<__kindof LNCollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSInteger targetIndex = [self binarySearchIndexPathInRect:rect];
    if (targetIndex < 0 || targetIndex >= self.indexPathArr.count) {
        return @[];
    }
    
    NSMutableArray<LNCollectionViewLayoutAttributes *> *result = [NSMutableArray array];
    NSIndexPath *targetIndexPath = self.indexPathArr[targetIndex];
    [result addObject:[self layoutAttributesForItemAtIndexPath:targetIndexPath]];
    
    for (NSInteger i = targetIndex - 1; i >= 0; i--) {
        NSIndexPath *indexPath = self.indexPathArr[i];
        CGRect frame = [self.frameDic[indexPath] CGRectValue];
        if (self.scrollDirection == LNCollectionViewScrollDirectionHorizontal) {
            if (CGRectGetMaxX(frame) < CGRectGetMinX(rect)) {
                break;
            }
        } else {
            if (CGRectGetMaxY(frame) < CGRectGetMinY(rect)) {
                break;
            }
        }
        if (CGRectIntersectsRect(frame, rect)) {
            LNCollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            if (attributes) {
                [result addObject:attributes];
            }
        }
    }

    for (NSUInteger i = targetIndex + 1; i < self.frameDic.allKeys.count; i++) {
        NSIndexPath *indexPath = self.indexPathArr[i];
        CGRect frame = [self.frameDic[indexPath] CGRectValue];
        if (self.scrollDirection == LNCollectionViewScrollDirectionHorizontal) {
            if (CGRectGetMinX(frame) > CGRectGetMaxX(rect)) {
                break;
            }
        } else {
            if (CGRectGetMinY(frame) > CGRectGetMaxY(rect)) {
                break;
            }
        }
        if (CGRectIntersectsRect(frame, rect)) {
            LNCollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            if (attributes) {
                [result addObject:attributes];
            }
        }
    }
    
    return result.copy;
}

- (NSInteger)binarySearchIndexPathInRect:(CGRect)rect {
    if (self.indexPathArr.count == 0) {
        return -1;
    }
    if (self.indexPathArr.count == 1) {
        NSIndexPath *singleKey = self.indexPathArr.firstObject;
        CGRect singleFrame = [self.frameDic[singleKey] CGRectValue];
        if (CGRectIntersectsRect(singleFrame, rect)) {
            return 0;
        } else {
            return -1;
        }
    }
    NSInteger left = 0;
    NSInteger right = self.indexPathArr.count - 1;
    while (left <= right) {
        NSInteger mid = left + (right - left) / 2;
        NSIndexPath *midIndexPath = self.indexPathArr[mid];
        CGRect midFrame = [self.frameDic[midIndexPath] CGRectValue];
        if (CGRectIntersectsRect(midFrame, rect)) {
            return mid;
        }
        if (self.scrollDirection == LNCollectionViewScrollDirectionHorizontal) {
            if (CGRectGetMaxY(midFrame) <= CGRectGetMinY(rect)) {
                left = mid + 1;
            } else if (CGRectGetMinY(midFrame) >= CGRectGetMaxY(rect)) {
                right = mid - 1;
            } else if (CGRectGetMaxX(midFrame) <= CGRectGetMinX(rect)) {
                left = mid + 1;
            } else if (CGRectGetMinX(midFrame) >= CGRectGetMaxX(rect)) {
                right = mid - 1;
            } else {
                left = mid + 1;
            }
        } else {
            if (CGRectGetMaxX(midFrame) <= CGRectGetMinX(rect)) {
                left = mid + 1;
            } else if (CGRectGetMinX(midFrame) >= CGRectGetMaxX(rect)) {
                right = mid - 1;
            } else if (CGRectGetMaxY(midFrame) <= CGRectGetMinY(rect)) {
                left = mid + 1;
            } else if (CGRectGetMinY(midFrame) >= CGRectGetMaxY(rect)) {
                right = mid - 1;
            } else {
                left = mid + 1;
            }
        }
    }
    return -1;
}

- (nullable LNCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.attributesMDic objectForKey:indexPath]) {
        return [self.attributesMDic objectForKey:indexPath];
    }
    LNCollectionViewLayoutAttributes *att = [LNCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    att.frame = [[self.frameDic objectForKey:indexPath] CGRectValue];
    [self.attributesMDic setObject:att forKey:indexPath];
    return att;
    
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    return CGPointZero;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset;
{
    return CGPointZero;
}

- (NSMutableDictionary<NSIndexPath *,LNCollectionViewLayoutAttributes *> *)attributesMDic
{
    if (!_attributesMDic) {
        _attributesMDic = [[NSMutableDictionary alloc] init];
    }
    return _attributesMDic;
}

@end

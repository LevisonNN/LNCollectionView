//
//  LNCollectionViewLayoutAttributes.m
//  LNCollectionView
//
//  Created by Levison on 14.11.24.
//

#import "LNCollectionViewLayoutAttributes.h"

@interface LNCollectionViewLayoutAttributes ()

@end

@implementation LNCollectionViewLayoutAttributes

+ (instancetype)layoutAttributesForCellWithIndexPath:(NSIndexPath *)indexPath {
    LNCollectionViewLayoutAttributes *attributes = [[LNCollectionViewLayoutAttributes alloc] init];
    attributes.indexPath = indexPath;
    return attributes;
}

@end

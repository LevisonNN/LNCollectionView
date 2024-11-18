//
//  LNCollectionViewReusePool.h
//  LNCollectionView
//
//  Created by Levison on 19.11.24.
//

#import <Foundation/Foundation.h>
#import "LNCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface LNCollectionViewReusePool : NSObject

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (__kindof LNCollectionViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (void)addReusableCell:(LNCollectionViewCell *)cell;
- (void)clearReusableViews;

@end

NS_ASSUME_NONNULL_END

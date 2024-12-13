//
//  LNCollectionViewLayoutAttributes.h
//  LNCollectionView
//
//  Created by Levison on 14.11.24.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LNCollectionViewLayoutAttributes : NSObject

@property (nonatomic) CGRect frame;
@property (nonatomic) CGPoint center;
@property (nonatomic) CGSize size;
@property (nonatomic) CATransform3D transform3D;
@property (nonatomic) CGRect bounds;
@property (nonatomic) CGAffineTransform transform;
@property (nonatomic) CGFloat alpha;
@property (nonatomic) NSInteger zIndex; 
@property (nonatomic, getter=isHidden) BOOL hidden;
@property (nonatomic, strong) NSIndexPath *indexPath;

+ (instancetype)layoutAttributesForCellWithIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END

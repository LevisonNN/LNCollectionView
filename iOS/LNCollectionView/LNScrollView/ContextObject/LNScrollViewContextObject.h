//
//  LNScrollViewContextObject.h
//  LNCollectionView
//
//  Created by Levison on 6.12.25.
//

#import <Foundation/Foundation.h>
#import "LNScrollViewDecelerateSimulator.h"

NS_ASSUME_NONNULL_BEGIN

/**
 看成每个子组件都可以捕获到LNScrollView状态的固有属性
 */

@protocol LNScrollViewContextDelegate

@required
- (CGSize)contextGetContentSize;
- (CGSize)contextGetFrameSize;
- (CGPoint)contextGetContentOffset;

- (BOOL)contextGetBounces;
- (BOOL)contextGetPageEnable;

@optional


@end

@interface LNScrollViewContextObject : NSObject

- (instancetype)initWithDelegate:(nonnull NSObject<LNScrollViewContextDelegate> *)delegate;

- (CGSize)contentSize;
- (CGSize)frameSize;
- (CGPoint)contentOffset;
- (BOOL)bounces;
- (BOOL)pageEnable;

@end
NS_ASSUME_NONNULL_END

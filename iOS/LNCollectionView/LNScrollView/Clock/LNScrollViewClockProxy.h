//
//  LNScrollViewClockProxy.h
//  LNCollectionView
//
//  Created by Levison on 7.11.24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LNScrollViewClockProxy : NSObject

@property (nullable, nonatomic, weak, readonly) id target;
- (instancetype)initWithTarget:(id)target;
+ (instancetype)proxyWithTarget:(id)target;

@end

NS_ASSUME_NONNULL_END

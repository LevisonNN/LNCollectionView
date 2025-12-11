//
//  LNScrollViewGestureConvertor.h
//  LNCollectionView
//
//  Created by 李为 on 2025/12/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LNScrollViewGestureConvertor : NSObject

- (CGFloat)convertOffsetWith:(CGFloat)gestureStartPosition
      gestureCurrentPosition:(CGFloat)gestureCurrentPosition
          gestureStartOffset:(CGFloat)gestureStartOffset
                leadingPoint:(CGFloat)leadingPoint
               trailingPoint:(CGFloat)trailingPoint;

@end

NS_ASSUME_NONNULL_END

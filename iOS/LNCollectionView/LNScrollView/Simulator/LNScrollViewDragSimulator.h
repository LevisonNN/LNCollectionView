//
//  LNScrollViewDragSimulator.h
//  LNCollectionView
//
//  Created by Levison on 7.11.24.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LNScrollViewDragSimulator : NSObject

@property (nonatomic, assign, readonly) CGFloat leadingPoint;
@property (nonatomic, assign, readonly) CGFloat trailingPoint;

@property (nonatomic, assign, readonly) CGFloat startPoint;
@property (nonatomic, assign, readonly) CGFloat offset;

- (instancetype)initWithLeadingPoint:(CGFloat)leadingPoint
                       trailingPoint:(CGFloat)trailingPoint
                          startPoint:(CGFloat)startPoint;
- (void)updateOffset:(CGFloat)offset;
- (CGFloat)getResultOffset;


@end

NS_ASSUME_NONNULL_END

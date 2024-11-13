//
//  LNScrollViewClock.h
//  LNCollectionView
//
//  Created by Levison on 7.11.24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LNScrollViewClockProtocol <NSObject>

- (void)scrollViewClockUpdateTimeInterval:(NSTimeInterval)time;

@end

@interface LNScrollViewClock : NSObject

+ (instancetype)shareInstance;
- (void)addObject:(id<LNScrollViewClockProtocol>)obj;
- (void)removeObject:(id<LNScrollViewClockProtocol>)obj;

@property (nonatomic, assign, readonly) BOOL isPaused;

- (void)startOrResume;
- (void)pause;
- (void)stop;

@end

NS_ASSUME_NONNULL_END

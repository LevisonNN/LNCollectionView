//
//  LNScrollViewClock.m
//  LNCollectionView
//
//  Created by Levison on 7.11.24.
//

#import "LNScrollViewClock.h"
#import <QuartzCore/QuartzCore.h>
#import "LNScrollViewClockProxy.h"

@interface LNScrollViewClock ()

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CFTimeInterval realWorldTime;
@property (nonatomic, assign) CGFloat scaleSpeed;
@property (nonatomic, assign) BOOL isPaused;
@property (nonatomic, assign) NSTimeInterval allTime;
@property (nonatomic, strong) NSHashTable<id <LNScrollViewClockProtocol>> *hashTable;

@end

@implementation LNScrollViewClock

- (instancetype)init {
    self = [super init];
    if (self) {
        _realWorldTime = CACurrentMediaTime();
        _scaleSpeed = 1.0;
        _isPaused = YES;
    }
    return self;
}

- (void)addObject:(id<LNScrollViewClockProtocol>)obj
{
    if (![self.hashTable containsObject:obj]) {
        [self.hashTable addObject:obj];
        [self checkNeedStartOrStop];
    }
}

- (void)removeObject:(id<LNScrollViewClockProtocol>)obj
{
    if ([self.hashTable containsObject:obj]) {
        [self.hashTable removeObject:obj];
        [self checkNeedStartOrStop];
    }
}

- (void)checkNeedStartOrStop
{
    if (self.hashTable.count > 0) {
        [self startOrResume];
    } else {
        [self stop];
    }
}

+ (instancetype)shareInstance
{
    static LNScrollViewClock *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(shareInstance == nil) {
            shareInstance = [[LNScrollViewClock alloc] init];
        }
    });
    return shareInstance;
}

- (void)dealloc
{
    [self stop];
}

- (void)resetClock
{
    [self stop];
    self.realWorldTime = CACurrentMediaTime();
    self.scaleSpeed = 1.0;
    self.isPaused = NO;
    _displayLink = [CADisplayLink displayLinkWithTarget:[LNScrollViewClockProxy proxyWithTarget:self] selector:@selector(callback)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)callback
{
    CFTimeInterval newRealWorldTime = CACurrentMediaTime();
    CFTimeInterval timeInterval = newRealWorldTime - self.realWorldTime;
    NSArray *objArr = [self.hashTable allObjects];
    for (id <LNScrollViewClockProtocol> obj in objArr) {
        if ([obj respondsToSelector:@selector(scrollViewClockUpdateTimeInterval:)]) {
            [obj scrollViewClockUpdateTimeInterval:timeInterval];
        }
    }
    self.realWorldTime = newRealWorldTime;
}

- (void)startOrResume
{
    if (!_displayLink) {
        [self resetClock];
    }
    if (self.isPaused) {
        self.isPaused = NO;
    }
}

- (void)pause {
    self.isPaused = YES;
}

- (void)stop
{
    self.isPaused = YES;
    [_displayLink invalidate];
    _displayLink = nil;
}

- (NSHashTable<id<LNScrollViewClockProtocol>> *)hashTable {
    if (!_hashTable) {
        _hashTable = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory capacity:2];
    }
    return _hashTable;
}

@end

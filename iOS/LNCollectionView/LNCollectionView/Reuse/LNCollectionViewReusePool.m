//
//  LNCollectionViewReusePool.m
//  LNCollectionView
//
//  Created by Levison on 19.11.24.
//

#import "LNCollectionViewReusePool.h"

@interface LNCollectionViewCell (Reuse)

@property (nonatomic, copy, nullable) NSString *identifier;

@end

@interface LNCollectionViewReusePool ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableSet<LNCollectionViewCell *> *> *reusePool;
@property (nonatomic, strong) NSMutableDictionary<NSString *, Class> *registeredClasses;

@end

@implementation LNCollectionViewReusePool

- (instancetype)init {
    self = [super init];
    if (self) {
        _reusePool = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    if (!identifier || !cellClass) {
        return;
    }
    self.registeredClasses[identifier] = cellClass;
}

- (__kindof LNCollectionViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    if (!identifier) {
        return nil;
    }
    
    NSMutableSet<LNCollectionViewCell *> *cells = self.reusePool[identifier];
    LNCollectionViewCell *cell = [cells anyObject];
    if (cell) {
        [cells removeObject:cell];
    } else {
        Class cellClass = self.registeredClasses[identifier];
        if (cellClass) {
            cell = [[cellClass alloc] init];
            cell.identifier = identifier;
            cell.backgroundColor = [UIColor colorWithRed:(random()%255)/255.f green:(random()%255)/255.f blue:(random()%255)/255.f alpha:1.f];
        } else {
            cell = [[LNCollectionViewCell alloc] init];
            cell.identifier = identifier;
        }
    }
    return cell;
}

- (void)addReusableCell:(LNCollectionViewCell *)cell {
    if (!cell || !cell.identifier) {
        return;
    }
    
    NSMutableSet<LNCollectionViewCell *> *cells = self.reusePool[cell.identifier];
    if (!cells) {
        cells = [NSMutableSet set];
        self.reusePool[cell.identifier] = cells;
    }
    [cells addObject:cell];
}

- (void)clearReusableViews {
    [self.reusePool removeAllObjects];
}

- (NSMutableDictionary<NSString *,NSMutableSet<LNCollectionViewCell *> *> *)reusePool
{
    if (!_reusePool) {
        _reusePool = [[NSMutableDictionary alloc] init];
    }
    return _reusePool;
}

- (NSMutableDictionary<NSString *,Class> *)registeredClasses
{
    if (!_registeredClasses) {
        _registeredClasses = [[NSMutableDictionary alloc] init];
    }
    return _registeredClasses;
}

@end

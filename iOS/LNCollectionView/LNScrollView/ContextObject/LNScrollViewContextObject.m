//
//  LNScrollViewContextObject.m
//  LNCollectionView
//
//  Created by Levison on 6.12.25.
//

#import "LNScrollViewContextObject.h"

@interface LNScrollViewContextObject()

@property (nonatomic, weak) NSObject<LNScrollViewContextDelegate> *delegate;

@end

@implementation LNScrollViewContextObject

- (instancetype)initWithDelegate:(NSObject<LNScrollViewContextDelegate> *)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (CGSize)contentSize {
    return self.delegate.contextGetContentSize;
}

- (CGPoint)contentOffset {
    return self.delegate.contextGetContentOffset;
}

- (UIEdgeInsets)contentInset {
    return self.delegate.contextGetContentInset;
}

- (CGSize)frameSize {
    return self.delegate.contextGetFrameSize;
}

- (BOOL)bounces {
    return self.delegate.contextGetBounces;
}

- (BOOL)pageEnable {
    return self.delegate.contextGetPageEnable;
}

- (LNScrollViewPulseGenerator *)topPulseGenerator {
    return self.delegate.contextGetTopPulseGenerator;
}

- (LNScrollViewPulseGenerator *)leftPulseGenerator {
    return self.delegate.contextGetLeftPulseGenerator;
}

- (LNScrollViewPulseGenerator *)bottomPulseGenerator {
    return self.delegate.contextGetBottomPulseGenerator;
}

- (LNScrollViewPulseGenerator *)rightPulseGenerator {
    return  self.delegate.contextGetRightPulseGenerator;
}

@end

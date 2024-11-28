//
//  LNScrollViewPulseConvertor.h
//  LNCollectionView
//
//  Created by Levison on 28.11.24.
//

#import <Foundation/Foundation.h>
#import "LNScrollViewPulseGenerator.h"
#import "LNScrollViewPulser.h"

NS_ASSUME_NONNULL_BEGIN

@interface LNScrollViewPulseConvertor : NSObject <LNScrollViewPulseGeneratorDelegate>

//是否能量守恒（仅考虑这两者构成的系统，有外力情况下视为不守恒）
//在质量不等情况下：
//1.能量守恒（无外部能量）：
//根据receiver质量，提供一个反推力。
//2.能量不守恒：（有外部能量）
//receiver结束时冲量总是0，均转化为generator的冲量。
//类似于：
//1.能量守恒：
//一个台球撞向另一个台球，无外力。
//2.能量不守恒：
//球杆撞向台球，球杆上有外力（你握住了球杆）。
//isConversationOfEnergy为YES时，台球撞台球；为NO时->球杆撞台球；
//默认NO，receiver发出的碰撞后不会对自己产生反向的冲量(反向的冲量作用到了地球上，被忽略了)。
//m相等时，均类似于球杆撞台球。
//这个标记的开启与否决定与你是否希望碰撞后，receiver有个反馈。
@property (nonatomic, assign) BOOL isConversationOfEnergy;

- (void)bindGenerator:(LNScrollViewPulseGenerator *)generator;
- (void)bindPulser:(LNScrollViewPulser *)pulser;

@end

NS_ASSUME_NONNULL_END

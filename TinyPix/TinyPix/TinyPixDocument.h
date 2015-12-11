//
//  TinyPixDocument.h
//  TinyPix
//
//  Created by shoron on 15/12/9.
//  Copyright © 2015年 com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TinyPixDocument : UIDocument

// 行和列的索引范围都是0-7
- (BOOL)stateAtRow:(NSUInteger)row column:(NSUInteger)column;
- (void)setState:(BOOL)state atRow:(NSUInteger)row column:(NSUInteger)column;
- (void)toggleStateAtRow:(NSUInteger)row column:(NSUInteger)column;

@end

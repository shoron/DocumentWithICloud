//
//  TinyPixView.m
//  TinyPix
//
//  Created by shoron on 15/12/9.
//  Copyright © 2015年 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TinyPixView.h"
#import "TinyPixDocument.h"

typedef struct {
    NSInteger row;
    NSInteger column;
}GridIndex;

static NSInteger numberOfCellPerRow = 8;

@interface TinyPixView ()

@property (assign, nonatomic) CGSize lastSize;
@property (assign, nonatomic) CGRect gridRect;
@property (assign, nonatomic) CGSize blockSize;
@property (assign, nonatomic) CGFloat gap;
@property (assign, nonatomic) GridIndex selectedBlockIndex;

@end

@implementation TinyPixView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [self caculateGridForSize:self.bounds.size];
    _selectedBlockIndex.row = NSNotFound;
    _selectedBlockIndex.column = NSNotFound;
}

// 每行放置8个小单元格，单元格的宽度是单元格之间的间隙的6倍
// 所以一共有 6x8+9 = 57 个单元格间隙
- (void)caculateGridForSize:(CGSize)size {
    CGFloat space = MIN(size.width, size.height);
    self.gap = space/57;
    CGFloat cellSide = self.gap * 6;
    self.blockSize = CGSizeMake(cellSide, cellSide);
    self.gridRect = CGRectMake((size.width - space) / 2, (size.height - space) / 2, space, space);
}

#pragma mark - Draw

// 除非进行自定义绘图，否则不要重写drawRect:方法
- (void)drawRect:(CGRect)rect {
    if (!self.document) {
        return;
    }
    
    CGSize size = self.bounds.size;
    if (!CGSizeEqualToSize(size, self.lastSize)) {
        self.lastSize = size;
        [self caculateGridForSize:size];
    }
    
    for (NSUInteger row = 0; row < numberOfCellPerRow; row++) {
        for (NSUInteger column = 0; column < numberOfCellPerRow; column++) {
            [self drawBlockAtRow:row column:column];
        }
    }
}

- (void)drawBlockAtRow:(NSUInteger)row column:(NSUInteger)column {
    CGFloat startX = self.gridRect.origin.x + self.gap + (self.blockSize.width + self.gap) * (numberOfCellPerRow - 1 - column) + 1;
    CGFloat startY = self.gridRect.origin.y + self.gap + (self.blockSize.height + self.gap) * row + 1;
    CGRect blockFrame = CGRectMake(startX, startY, self.blockSize.width, self.blockSize.height);
    UIColor *color = [self.document stateAtRow:row column:column] ? [UIColor blackColor] : [UIColor whiteColor];
    [color setFill];
    [self.tintColor setStroke];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:blockFrame];
    [path fill];
    [path stroke];
}

- (GridIndex)touchedGridIndexFromTouches:(NSSet *)touches {
    GridIndex gridIndex;
    gridIndex.row = -1;
    gridIndex.column = -1;
    
    UITouch *touch = touches.anyObject;
    CGPoint location = [touch locationInView:self];
    if (CGRectContainsPoint(self.gridRect, location)) {
        location.x -= self.gridRect.origin.x;
        location.y -= self.gridRect.origin.y;
        gridIndex.row = location.y * numberOfCellPerRow / self.gridRect.size.height;
        gridIndex.column = 8 - location.x * numberOfCellPerRow / self.gridRect.size.width;
    }
    return gridIndex;
}

- (void)toggleSelectedBlock {
    if (self.selectedBlockIndex.row != -1 && self.selectedBlockIndex.column != -1) {
        [self.document toggleStateAtRow:self.selectedBlockIndex.row
                                 column:self.selectedBlockIndex.column];
        [[self.document.undoManager prepareWithInvocationTarget:self.document] toggleStateAtRow:self.selectedBlockIndex.row
                                                                                         column:self.selectedBlockIndex.column];
        [self setNeedsDisplay];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.selectedBlockIndex = [self touchedGridIndexFromTouches:touches];
    [self toggleSelectedBlock];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    GridIndex touchedGridIndex = [self touchedGridIndexFromTouches:touches];
    if (touchedGridIndex.row != self.selectedBlockIndex.row || touchedGridIndex.column != self.selectedBlockIndex.column) {
        self.selectedBlockIndex = touchedGridIndex;
        [self toggleSelectedBlock];
    }
}



@end

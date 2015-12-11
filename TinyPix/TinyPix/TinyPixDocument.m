//
//  TinyPixDocument.m
//  TinyPix
//
//  Created by shoron on 15/12/9.
//  Copyright © 2015年 com. All rights reserved.
//

#import "TinyPixDocument.h"

@interface TinyPixDocument ()

@property (strong, nonatomic) NSMutableData *bitmap;

@end

@implementation TinyPixDocument

- (instancetype)initWithFileURL:(NSURL *)url {
    self = [super initWithFileURL:url];
    if (self) {
        unsigned char startPattern[] = {0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80};
        self.bitmap = [NSMutableData dataWithBytes:startPattern length:8];
    }
    return self;
}

- (BOOL)stateAtRow:(NSUInteger)row column:(NSUInteger)column {
    const char *bitmapBytes = [self.bitmap bytes];
    char rowByte = bitmapBytes[row];
    char result = (1 << column) & rowByte;
    if (result != 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)setState:(BOOL)state atRow:(NSUInteger)row column:(NSUInteger)column {
    char *bitmapBytes = [self.bitmap mutableBytes];
    char *rowByte = &bitmapBytes[row];
    if (state) {
        *rowByte = *rowByte | (1 << column);
    } else {
        *rowByte = *rowByte & ~(1 << column);
    }
}

- (void)toggleStateAtRow:(NSUInteger)row column:(NSUInteger)column {
    BOOL state = [self stateAtRow:row column:column];
    [self setState:!state atRow:row column:column];
}

// 保存文档时，调用此方法
-(id)contentsForType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError {
    NSLog(@"save document to URL %@ success ",self.fileURL);
    return [self.bitmap copy];
}

// 加载文档数据时，调用此方法
- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError {
    NSLog(@"loading document from URL %@ success ", self.fileURL);
    self.bitmap = [contents mutableCopy];
    return YES;
}

@end

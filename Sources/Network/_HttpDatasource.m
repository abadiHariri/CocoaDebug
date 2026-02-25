//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

#import "_HttpDatasource.h"
#import "_NetworkHelper.h"

static const NSUInteger kDefaultMemoryBudget = 50 * 1024 * 1024; // 50 MB

@interface _HttpDatasource ()
@property (nonatomic, assign, readwrite) NSUInteger totalDataSize;
@end

@implementation _HttpDatasource

+ (instancetype)shared
{
    static id sharedInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.httpModels = [NSMutableArray arrayWithCapacity:1000 + 100];
        self.totalDataSize = 0;
        // Clear leftover disk cache from previous app session
        [_HttpModel clearDiskCache];
    }
    return self;
}

- (NSUInteger)estimatedSizeOfModel:(_HttpModel *)model
{
    // Use cached sizes - data is on disk, don't load it just to check length
    NSUInteger size = 0;
    size += model.requestDataSize;
    size += model.responseDataSize;
    size += 1024; // overhead for URL, headers, strings, etc.
    return size;
}

- (BOOL)addHttpRequset:(_HttpModel*)model
{
    if ([model.url.absoluteString isEqualToString:@""]) {
        return NO;
    }

    //url Filter, ignore case
    for (NSString *urlString in [[_NetworkHelper shared] ignoredURLs]) {
        if ([[model.url.absoluteString lowercaseString] containsString:[urlString lowercaseString]]) {
            return NO;
        }
    }

    // All mutations to httpModels must be synchronized - stopLoading is called
    // from different protocol instance threads concurrently.
    @synchronized (self) {
        //Maximum number limit
        if (self.httpModels.count >= 1000) {
            if ([self.httpModels count] > 0) {
                _HttpModel *oldest = self.httpModels[0];
                self.totalDataSize -= [self estimatedSizeOfModel:oldest];
                [self.httpModels removeObjectAtIndex:0];
            }
        }

        //detect repeated
        __block BOOL isExist = NO;
        [self.httpModels enumerateObjectsUsingBlock:^(_HttpModel *obj, NSUInteger index, BOOL *stop) {
            if ([obj.requestId isEqualToString:model.requestId]) {
                isExist = YES;
                *stop = YES;
            }
        }];
        if (isExist) {
            return NO;
        }

        // Enforce disk budget: evict oldest models until we have room
        NSUInteger modelSize = [self estimatedSizeOfModel:model];
        while (self.totalDataSize + modelSize > kDefaultMemoryBudget && self.httpModels.count > 0) {
            _HttpModel *oldest = self.httpModels[0];
            self.totalDataSize -= [self estimatedSizeOfModel:oldest];
            [self.httpModels removeObjectAtIndex:0];
            // Note: model's dealloc deletes its disk files automatically
        }

        [self.httpModels addObject:model];
        self.totalDataSize += modelSize;
    }

    return YES;
}

- (void)reset
{
    @synchronized (self) {
        [self.httpModels removeAllObjects];
        self.totalDataSize = 0;
        // Clear all disk files
        [_HttpModel clearDiskCache];
    }
}

- (void)remove:(_HttpModel *)model
{
    @synchronized (self) {
        [self.httpModels enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(_HttpModel *obj, NSUInteger index, BOOL *stop) {
            if ([obj.requestId isEqualToString:model.requestId]) {
                self.totalDataSize -= [self estimatedSizeOfModel:obj];
                [self.httpModels removeObjectAtIndex:index];
                // Note: model's dealloc deletes its disk files automatically
            }
        }];
    }
}

@end

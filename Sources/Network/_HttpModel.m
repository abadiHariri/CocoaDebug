//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

#import "_HttpModel.h"

@implementation _HttpModel {
    NSString *_requestDataFilePath;
    NSString *_responseDataFilePath;
}

// Synthesize because we provide custom getter/setter for these properties
@synthesize requestData = _requestData_unused;
@synthesize responseData = _responseData_unused;

+ (NSString *)diskCacheDirectory {
    static NSString *dir = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *caches = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        dir = [caches stringByAppendingPathComponent:@"CocoaDebug/NetworkData"];
    });
    [[NSFileManager defaultManager] createDirectoryAtPath:dir
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    return dir;
}

+ (void)clearDiskCache {
    NSString *caches = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *dir = [caches stringByAppendingPathComponent:@"CocoaDebug/NetworkData"];
    [[NSFileManager defaultManager] removeItemAtPath:dir error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:dir
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
}

//default value for @property
- (id)init {
    if (self = [super init])  {
        self.statusCode = @"0";
        self.url = [[NSURL alloc] initWithString:@""];
    }
    return self;
}

- (void)dealloc {
    // Clean up disk files when model is evicted from _HttpDatasource
    if (_requestDataFilePath) {
        [[NSFileManager defaultManager] removeItemAtPath:_requestDataFilePath error:nil];
    }
    if (_responseDataFilePath) {
        [[NSFileManager defaultManager] removeItemAtPath:_responseDataFilePath error:nil];
    }
}

#pragma mark - Disk-backed requestData

- (void)setRequestData:(NSData *)requestData {
    // Remove old file if exists
    if (_requestDataFilePath) {
        [[NSFileManager defaultManager] removeItemAtPath:_requestDataFilePath error:nil];
        _requestDataFilePath = nil;
    }

    self.requestDataSize = requestData.length;

    if (requestData.length == 0) {
        return;
    }

    NSString *fileName = [NSString stringWithFormat:@"req_%@", [[NSUUID UUID] UUIDString]];
    NSString *filePath = [[_HttpModel diskCacheDirectory] stringByAppendingPathComponent:fileName];
    [requestData writeToFile:filePath atomically:NO];
    _requestDataFilePath = filePath;
}

- (NSData *)requestData {
    if (_requestDataFilePath == nil) return nil;
    return [NSData dataWithContentsOfFile:_requestDataFilePath];
}

#pragma mark - Disk-backed responseData

- (void)setResponseData:(NSData *)responseData {
    // Remove old file if exists
    if (_responseDataFilePath) {
        [[NSFileManager defaultManager] removeItemAtPath:_responseDataFilePath error:nil];
        _responseDataFilePath = nil;
    }

    self.responseDataSize = responseData.length;

    if (responseData.length == 0) {
        return;
    }

    NSString *fileName = [NSString stringWithFormat:@"res_%@", [[NSUUID UUID] UUIDString]];
    NSString *filePath = [[_HttpModel diskCacheDirectory] stringByAppendingPathComponent:fileName];
    [responseData writeToFile:filePath atomically:NO];
    _responseDataFilePath = filePath;
}

- (NSData *)responseData {
    if (_responseDataFilePath == nil) return nil;
    return [NSData dataWithContentsOfFile:_responseDataFilePath];
}

@end

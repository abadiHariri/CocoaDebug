//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

#import "_NetworkHelper.h"
#import "_CustomHTTPProtocol.h"
#import "NSObject+CocoaDebug.h"

@interface _NetworkHelper()

@end

@implementation _NetworkHelper

+ (instancetype)shared
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

//default value for @property
- (id)init {
    if (self = [super init])  {
        self.mainColor = [UIColor colorFromHexString:@"#42d459"];
        self.isNetworkEnable = YES;
        self.maxResponseSize = 2 * 1024 * 1024;    // 2 MB (was 10 MB - reduced to lower memory pressure)
        self.maxRequestBodySize = 512 * 1024;       // 512 KB
    }
    return self;
}

- (void)enable {
    if (self.isNetworkEnable) {
        return;
    }
    self.isNetworkEnable = YES;
    [_CustomHTTPProtocol start];
}

- (void)disable {
    if (!self.isNetworkEnable) {
        return;
    }
    self.isNetworkEnable = NO;
    [_CustomHTTPProtocol stop];
}

@end

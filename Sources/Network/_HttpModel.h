//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RequestSerializer) {
    RequestSerializerJSON = 0,  //JSON format
    RequestSerializerForm       //Form format
};

@interface _HttpModel : NSObject

@property (nonatomic,strong)NSURL   *url;
/// Request/response data is stored on disk. These getters load from disk on demand.
/// Use requestDataSize/responseDataSize to check sizes without loading into memory.
@property (nonatomic,copy)NSData    *requestData;
@property (nonatomic,copy)NSData    *responseData;
/// Cached sizes so _HttpDatasource can estimate without loading data from disk.
@property (nonatomic,assign)NSUInteger requestDataSize;
@property (nonatomic,assign)NSUInteger responseDataSize;
@property (nonatomic,copy)NSString  *requestId;
@property (nonatomic,copy)NSString  *method;
@property (nonatomic,copy)NSString  *statusCode;
@property (nonatomic,copy)NSString  *mineType;
@property (nonatomic,copy)NSString  *startTime;
@property (nonatomic,copy)NSString  *endTime;
@property (nonatomic,copy)NSString  *totalDuration;
@property (nonatomic,assign)BOOL    isImage;
@property (nonatomic,assign)BOOL    isResponseTruncated;
@property (nonatomic,assign)BOOL    isRequestBodyTruncated;
@property (nonatomic,assign)BOOL    isWebViewRequest;

@property (nonatomic,copy)NSDictionary<NSString*, id>           *requestHeaderFields;
@property (nonatomic,copy)NSDictionary<NSString*, id>           *responseHeaderFields;
@property (nonatomic,assign)BOOL                                isTag;
@property (nonatomic,assign)BOOL                                isSelected;
@property (nonatomic,assign)BOOL                                isViewed;
@property (nonatomic,assign)RequestSerializer                   requestSerializer;//default JSON format
@property (nonatomic,copy)NSString                              *errorDescription;
@property (nonatomic,copy)NSString                              *errorLocalizedDescription;
@property (nonatomic,copy)NSString                              *size;

+ (NSString *)diskCacheDirectory;
+ (void)clearDiskCache;

@end

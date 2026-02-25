//
//  WKWebView+Swizzling.m
//  1233213
//
//  Created by man 2019/1/8.
//  Copyright © 2020 man. All rights reserved.
//

#import <WebKit/WebKit.h>
#import <objc/runtime.h>
#import "_ObjcLog.h"
#import "_NetworkHelper.h"
#import "_HttpModel.h"
#import "_HttpDatasource.h"

#pragma mark - Script Message Proxy

/// Wraps an app-registered WKScriptMessageHandler so CocoaDebug can log the
/// message before forwarding it to the original handler.
@interface _WKScriptMessageProxy : NSObject <WKScriptMessageHandler>
@property (nonatomic, strong) id<WKScriptMessageHandler> originalHandler;
- (instancetype)initWithOriginalHandler:(id<WKScriptMessageHandler>)handler;
@end

@implementation _WKScriptMessageProxy

- (instancetype)initWithOriginalHandler:(id<WKScriptMessageHandler>)handler {
    if (self = [super init]) {
        _originalHandler = handler;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    // Log to CocoaDebug Logs tab (Web section)
    [_ObjcLog logWithFile:"[WKWebView]"
                 function:[message.name UTF8String]
                     line:0
                    color:[UIColor cyanColor]
                  message:message.body];

    // Forward to original handler
    if (self.originalHandler &&
        [self.originalHandler respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
        [self.originalHandler userContentController:userContentController
                            didReceiveScriptMessage:message];
    }
}

@end

#pragma mark - WKUserContentController swizzling

@implementation WKUserContentController (_CocoaDebugSwizzling)

- (void)replaced_addScriptMessageHandler:(id<WKScriptMessageHandler>)handler name:(NSString *)name {
    // Don't wrap CocoaDebug's own handlers (registered with WKWebView as handler)
    if ([handler isKindOfClass:[WKWebView class]] ||
        [handler isKindOfClass:[_WKScriptMessageProxy class]]) {
        [self replaced_addScriptMessageHandler:handler name:name];
        return;
    }

    _WKScriptMessageProxy *proxy = [[_WKScriptMessageProxy alloc] initWithOriginalHandler:handler];
    [self replaced_addScriptMessageHandler:proxy name:name];
}

@end

#pragma mark - WKWebView swizzling

@interface WKWebView () <WKScriptMessageHandler>

@end

@implementation WKWebView (_Swizzling)

#pragma mark - life
+ (void)load {

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"enableWKWebViewMonitoring_CocoaDebug"]) {

        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{

            // Swizzle WKWebView initWithFrame:configuration:
            SEL original_sel = @selector(initWithFrame:configuration:);
            SEL replaced_sel = @selector(replaced_initWithFrame:configuration:);
            Method original_method = class_getInstanceMethod([self class], original_sel);
            Method replaced_method = class_getInstanceMethod([self class], replaced_sel);
            if (!class_addMethod([self class], original_sel, method_getImplementation(replaced_method), method_getTypeEncoding(replaced_method))) {
                method_exchangeImplementations(original_method, replaced_method);
            }

            /*********************************************************************************************************************************/

            // Swizzle WKWebView dealloc
            SEL original_sel2 = NSSelectorFromString(@"dealloc");
            SEL replaced_sel2 = @selector(replaced_dealloc);
            Method original_method2 = class_getInstanceMethod([self class], original_sel2);
            Method replaced_method2 = class_getInstanceMethod([self class], replaced_sel2);
            if (!class_addMethod([self class], original_sel2, method_getImplementation(replaced_method2), method_getTypeEncoding(replaced_method2))) {
                method_exchangeImplementations(original_method2, replaced_method2);
            }

            SEL original_sel3 = NSSelectorFromString(@"willDealloc");
            SEL replaced_sel3 = @selector(replaced_willDealloc);
            Method replaced_method3 = class_getInstanceMethod([self class], replaced_sel3);
            class_addMethod([self class], original_sel3, method_getImplementation(replaced_method3), method_getTypeEncoding(replaced_method3));

            /*********************************************************************************************************************************/

            // Swizzle WKUserContentController addScriptMessageHandler:name:
            // to intercept ALL script message handler registrations
            SEL uc_original = @selector(addScriptMessageHandler:name:);
            SEL uc_replaced = @selector(replaced_addScriptMessageHandler:name:);
            Method uc_orig_method = class_getInstanceMethod([WKUserContentController class], uc_original);
            Method uc_repl_method = class_getInstanceMethod([WKUserContentController class], uc_replaced);
            if (!class_addMethod([WKUserContentController class], uc_original, method_getImplementation(uc_repl_method), method_getTypeEncoding(uc_repl_method))) {
                method_exchangeImplementations(uc_orig_method, uc_repl_method);
            }
        });
    }
}

#pragma mark - replaced method

- (BOOL)replaced_willDealloc {
    // removeScriptMessageHandlerForName
    [self.configuration.userContentController removeScriptMessageHandlerForName:@"log"];
    [self.configuration.userContentController removeScriptMessageHandlerForName:@"error"];
    [self.configuration.userContentController removeScriptMessageHandlerForName:@"warn"];
    [self.configuration.userContentController removeScriptMessageHandlerForName:@"debug"];
    [self.configuration.userContentController removeScriptMessageHandlerForName:@"info"];
    [self.configuration.userContentController removeScriptMessageHandlerForName:@"networkCapture"];

    return true;
}

- (void)replaced_dealloc {
    //WKWebView
    [_ObjcLog logWithFile:"[WKWebView]" function:"" line:0 color:[UIColor redColor] message:@"-------------------------------- dealloc --------------------------------"];
}

- (instancetype)replaced_initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    //WKWebView
    [_ObjcLog logWithFile:"[WKWebView]" function:"" line:0 color:[_NetworkHelper shared].mainColor message:@"----------------------------------- init -----------------------------------"];

    [self log:configuration];
    [self error:configuration];
    [self warn:configuration];
    [self debug:configuration];
    [self info:configuration];
    [self networkCapture:configuration];

    return [self replaced_initWithFrame:frame configuration:configuration];
}

#pragma mark - private
- (void)log:(WKWebViewConfiguration *)configuration {
    [configuration.userContentController removeScriptMessageHandlerForName:@"log"];
    [configuration.userContentController addScriptMessageHandler:self name:@"log"];
    //rewrite the method of console.log
    NSString *jsCode = @"console.log = (function(oriLogFunc){\
    return function(str)\
    {\
    window.webkit.messageHandlers.log.postMessage(str);\
    oriLogFunc.call(console,str);\
    }\
    })(console.log);";
    //injected the method when H5 starts to create the DOM tree
    [configuration.userContentController addUserScript:[[WKUserScript alloc] initWithSource:jsCode injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];
}

- (void)error:(WKWebViewConfiguration *)configuration {
    [configuration.userContentController removeScriptMessageHandlerForName:@"error"];
    [configuration.userContentController addScriptMessageHandler:self name:@"error"];
    //rewrite the method of console.error
    NSString *jsCode = @"console.error = (function(oriLogFunc){\
    return function(str)\
    {\
    window.webkit.messageHandlers.error.postMessage(str);\
    oriLogFunc.call(console,str);\
    }\
    })(console.error);";
    //injected the method when H5 starts to create the DOM tree
    [configuration.userContentController addUserScript:[[WKUserScript alloc] initWithSource:jsCode injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];
}

- (void)warn:(WKWebViewConfiguration *)configuration {
    [configuration.userContentController removeScriptMessageHandlerForName:@"warn"];
    [configuration.userContentController addScriptMessageHandler:self name:@"warn"];
    //rewrite the method of console.warn
    NSString *jsCode = @"console.warn = (function(oriLogFunc){\
    return function(str)\
    {\
    window.webkit.messageHandlers.warn.postMessage(str);\
    oriLogFunc.call(console,str);\
    }\
    })(console.warn);";
    //injected the method when H5 starts to create the DOM tree
    [configuration.userContentController addUserScript:[[WKUserScript alloc] initWithSource:jsCode injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];
}

- (void)debug:(WKWebViewConfiguration *)configuration {
    [configuration.userContentController removeScriptMessageHandlerForName:@"debug"];
    [configuration.userContentController addScriptMessageHandler:self name:@"debug"];
    //rewrite the method of console.debug
    NSString *jsCode = @"console.debug = (function(oriLogFunc){\
    return function(str)\
    {\
    window.webkit.messageHandlers.debug.postMessage(str);\
    oriLogFunc.call(console,str);\
    }\
    })(console.debug);";
    //injected the method when H5 starts to create the DOM tree
    [configuration.userContentController addUserScript:[[WKUserScript alloc] initWithSource:jsCode injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];
}

- (void)info:(WKWebViewConfiguration *)configuration {
    [configuration.userContentController removeScriptMessageHandlerForName:@"info"];
    [configuration.userContentController addScriptMessageHandler:self name:@"info"];
    //rewrite the method of console.info
    NSString *jsCode = @"console.info = (function(oriLogFunc){\
    return function(str)\
    {\
    window.webkit.messageHandlers.info.postMessage(str);\
    oriLogFunc.call(console,str);\
    }\
    })(console.info);";
    //injected the method when H5 starts to create the DOM tree
    [configuration.userContentController addUserScript:[[WKUserScript alloc] initWithSource:jsCode injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];
}

#pragma mark - Network Capture (XMLHttpRequest + fetch)

- (void)networkCapture:(WKWebViewConfiguration *)configuration {
    [configuration.userContentController removeScriptMessageHandlerForName:@"networkCapture"];
    [configuration.userContentController addScriptMessageHandler:self name:@"networkCapture"];

    NSString *jsCode =
    @"(function(){"
    @"if(window.__cd_net_hooked)return;"
    @"window.__cd_net_hooked=true;"
    @"var MAX_BODY=524288;"
    @"function trunc(s){if(typeof s==='string'&&s.length>MAX_BODY)return s.substring(0,MAX_BODY);return s;}"
    @"function post(d){try{window.webkit.messageHandlers.networkCapture.postMessage(JSON.stringify(d));}catch(e){}}"
    @"function parseH(raw){var h={};if(!raw)return h;var lines=raw.trim().split('\\r\\n');"
    @"for(var i=0;i<lines.length;i++){var idx=lines[i].indexOf(':');"
    @"if(idx>0)h[lines[i].substring(0,idx).trim()]=lines[i].substring(idx+1).trim();}return h;}"

    // XMLHttpRequest interception
    @"var origOpen=XMLHttpRequest.prototype.open;"
    @"var origSend=XMLHttpRequest.prototype.send;"
    @"var origSetH=XMLHttpRequest.prototype.setRequestHeader;"
    @"XMLHttpRequest.prototype.open=function(method,url){"
    @"this._cd={method:method,url:String(url),headers:{},startTime:Date.now()};"
    @"return origOpen.apply(this,arguments);};"
    @"XMLHttpRequest.prototype.setRequestHeader=function(k,v){"
    @"if(this._cd)this._cd.headers[k]=v;"
    @"return origSetH.apply(this,arguments);};"
    @"XMLHttpRequest.prototype.send=function(body){"
    @"if(this._cd){"
    @"this._cd.body=(typeof body==='string')?trunc(body):null;"
    @"var xhr=this;"
    @"this.addEventListener('loadend',function(){"
    @"var d=xhr._cd;if(!d)return;"
    @"d.url=xhr.responseURL||d.url;"
    @"d.status=xhr.status;"
    @"d.statusText=xhr.statusText||'';"
    @"d.responseHeaders=parseH(xhr.getAllResponseHeaders());"
    @"d.endTime=Date.now();"
    @"try{d.responseBody=trunc(xhr.responseText);}catch(e){d.responseBody=null;}"
    @"d.type='xhr';post(d);});}"
    @"return origSend.apply(this,arguments);};"

    // fetch interception
    @"if(window.fetch){"
    @"var origFetch=window.fetch;"
    @"window.fetch=function(input,init){"
    @"var url,method,headers={},body=null;"
    @"if(typeof input==='string'){url=input;}"
    @"else if(input instanceof Request){url=input.url;method=input.method;"
    @"try{input.headers.forEach(function(v,k){headers[k]=v;});}catch(e){}}"
    @"else{url=String(input);}"
    @"if(init){"
    @"if(init.method)method=init.method;"
    @"if(init.headers){"
    @"if(init.headers instanceof Headers){try{init.headers.forEach(function(v,k){headers[k]=v;});}catch(e){}}"
    @"else if(typeof init.headers==='object'){var ks=Object.keys(init.headers);"
    @"for(var i=0;i<ks.length;i++)headers[ks[i]]=init.headers[ks[i]];}}"
    @"if(init.body&&typeof init.body==='string')body=trunc(init.body);}"
    @"method=method||'GET';"
    @"var startTime=Date.now();"
    @"return origFetch.apply(this,arguments).then(function(response){"
    @"var rh={};try{response.headers.forEach(function(v,k){rh[k]=v;});}catch(e){}"
    @"var cloned=response.clone();"
    @"cloned.text().then(function(text){"
    @"post({type:'fetch',url:response.url||url,method:method.toUpperCase(),"
    @"requestHeaders:headers,body:body,status:response.status,"
    @"statusText:response.statusText||'',responseHeaders:rh,"
    @"responseBody:trunc(text),startTime:startTime,endTime:Date.now()});}).catch(function(){});"
    @"return response;}).catch(function(err){"
    @"post({type:'fetch',url:url,method:method.toUpperCase(),"
    @"requestHeaders:headers,body:body,status:0,"
    @"statusText:err.message||'Network Error',responseHeaders:{},"
    @"responseBody:null,startTime:startTime,endTime:Date.now()});"
    @"throw err;});};}"

    @"})();";

    [configuration.userContentController addUserScript:[[WKUserScript alloc] initWithSource:jsCode injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO]];
}

#pragma mark - Network Capture handler

- (void)handleNetworkCaptureMessage:(WKScriptMessage *)message {
    NSString *jsonString = nil;
    if ([message.body isKindOfClass:[NSString class]]) {
        jsonString = message.body;
    } else {
        return;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (!jsonData) return;

    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    if (![data isKindOfClass:[NSDictionary class]]) return;

    dispatch_async(dispatch_get_main_queue(), ^{
        _HttpModel *model = [[_HttpModel alloc] init];

        // URL
        NSString *urlString = data[@"url"] ?: @"";
        model.url = [NSURL URLWithString:urlString] ?: [NSURL URLWithString:@""];

        // Method
        NSString *method = data[@"method"] ?: @"GET";
        model.method = [method uppercaseString];

        // Request ID
        model.requestId = [[NSUUID UUID] UUIDString];

        // Status code
        NSNumber *status = data[@"status"];
        model.statusCode = [NSString stringWithFormat:@"%d", [status intValue]];

        // Timing
        double startMs = [data[@"startTime"] doubleValue];
        double endMs = [data[@"endTime"] doubleValue];
        model.startTime = [NSString stringWithFormat:@"%f", startMs / 1000.0];
        model.endTime = [NSString stringWithFormat:@"%f", endMs / 1000.0];
        model.totalDuration = [NSString stringWithFormat:@"%0.f ms", endMs - startMs];

        // Request headers
        NSDictionary *reqHeaders = data[@"requestHeaders"];
        if ([reqHeaders isKindOfClass:[NSDictionary class]]) {
            model.requestHeaderFields = reqHeaders;
        }

        // Request body
        NSString *reqBody = data[@"body"];
        if ([reqBody isKindOfClass:[NSString class]] && reqBody.length > 0) {
            model.requestData = [reqBody dataUsingEncoding:NSUTF8StringEncoding];
        }

        // Response headers
        NSDictionary *respHeaders = data[@"responseHeaders"];
        if ([respHeaders isKindOfClass:[NSDictionary class]]) {
            model.responseHeaderFields = respHeaders;
        }

        // Response body
        NSString *respBody = data[@"responseBody"];
        if ([respBody isKindOfClass:[NSString class]] && respBody.length > 0) {
            model.responseData = [respBody dataUsingEncoding:NSUTF8StringEncoding];
        }

        // MIME type from response headers
        NSString *contentType = respHeaders[@"content-type"] ?: respHeaders[@"Content-Type"] ?: @"";
        model.mineType = contentType;

        // Mark as WebView request
        model.isWebViewRequest = YES;

        // Size
        // Use cached sizes - don't load data back from disk just to get length
        NSUInteger size = model.requestDataSize + model.responseDataSize;
        if (size > 1024 * 1024) {
            model.size = [NSString stringWithFormat:@"%.1f MB", (double)size / (1024.0 * 1024.0)];
        } else if (size > 1024) {
            model.size = [NSString stringWithFormat:@"%.1f KB", (double)size / 1024.0];
        } else {
            model.size = [NSString stringWithFormat:@"%lu B", (unsigned long)size];
        }

        // Add to datasource
        [[_HttpDatasource shared] addHttpRequset:model];

        // Notify UI
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHttp_CocoaDebug" object:nil userInfo:nil];
    });
}

#pragma mark - WKScriptMessageHandler
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"networkCapture"]) {
        [self handleNetworkCaptureMessage:message];
        return;
    }
    [_ObjcLog logWithFile:"[WKWebView]" function:[message.name UTF8String] line:0 color:[UIColor whiteColor] message:message.body];
}
#pragma clang diagnostic pop

@end

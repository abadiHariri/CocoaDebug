//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import Foundation
import UIKit

@objc class _NetworkHelper: NSObject {

    /// color for objc
    @objc var mainColor: UIColor?

    /// Set domain names not to be crawled, ignore case, and crawl all by default
    @objc var ignoredURLs: [String]?

    /// Set only the domain name to be crawled, ignore case, and crawl all by default
    @objc var onlyURLs: [String]?

    /// Set the log prefix not to be crawled, ignore case, and crawl all by default
    @objc var ignoredPrefixLogs: [String]?

    /// Set the log prefix to be crawled, ignore case, and crawl all by default
    @objc var onlyPrefixLogs: [String]?

    /// protobuf
    @objc var protobufTransferMap: [String: [String]]?

    /// Maximum response body size (bytes) to capture. Default 10 MB.
    @objc var maxResponseSize: UInt = 0

    /// Maximum request body size (bytes) to capture from streams. Default 512 KB.
    @objc var maxRequestBodySize: UInt = 0

    @objc var isNetworkEnable: Bool = false

    @objc static let shared = _NetworkHelper()

    private override init() {
        super.init()
        mainColor = "#42d459".hexColor
        // In ObjC, +load ran swizzleSessionConfiguration() before main(), so
        // isNetworkEnable=YES was safe — all sessions already had the protocol.
        // In Swift there is no +load, so we must leave isNetworkEnable=false here
        // so that enable() actually calls _CustomHTTPProtocol.start() (registerClass),
        // which covers URLSession.shared and sessions created before the swizzle.
        isNetworkEnable = false
        maxResponseSize = 10 * 1024 * 1024      // 10 MB (data is stored on disk, not in memory)
        maxRequestBodySize = 512 * 1024          // 512 KB
    }

    @objc func enable() {
        if isNetworkEnable {
            return
        }
        isNetworkEnable = true
        _CustomHTTPProtocol.start()
    }

    @objc func disable() {
        if !isNetworkEnable {
            return
        }
        isNetworkEnable = false
        _CustomHTTPProtocol.stop()
    }
}

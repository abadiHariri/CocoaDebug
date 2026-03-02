//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import Foundation
import UIKit

@objc enum RequestSerializer: UInt {
    case json = 0   // JSON format
    case form       // Form format
}

@objc class _HttpModel: NSObject {

    @objc var url: NSURL?
    @objc var requestDataSize: UInt = 0
    @objc var responseDataSize: UInt = 0
    @objc var requestId: String?
    @objc var method: String?
    @objc var statusCode: String?
    @objc var mineType: String?
    @objc var startTime: String?
    @objc var endTime: String?
    @objc var totalDuration: String?
    @objc var isImage: Bool = false
    @objc var isResponseTruncated: Bool = false
    @objc var isRequestBodyTruncated: Bool = false
    @objc var isWebViewRequest: Bool = false
    @objc var requestHeaderFields: NSDictionary?
    @objc var responseHeaderFields: NSDictionary?
    @objc var isTag: Bool = false
    @objc var isSelected: Bool = false
    @objc var isViewed: Bool = false
    @objc var requestSerializer: RequestSerializer = .json
    @objc var errorDescription: String?
    @objc var errorLocalizedDescription: String?
    @objc var size: String?

    private var _requestDataFilePath: String?
    private var _responseDataFilePath: String?

    // MARK: - Disk Cache Directory

    // Thread-safe lazy init (equivalent to ObjC dispatch_once)
    private static let _diskCacheDirectoryValue: String = {
        let caches = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        return (caches as NSString).appendingPathComponent("CocoaDebug/NetworkData")
    }()

    @objc static func diskCacheDirectory() -> String {
        let dir = _diskCacheDirectoryValue
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
        return dir
    }

    @objc static func clearDiskCache() {
        let caches = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let dir = (caches as NSString).appendingPathComponent("CocoaDebug/NetworkData")
        try? FileManager.default.removeItem(atPath: dir)
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
    }

    // MARK: - Init / Deinit

    override init() {
        super.init()
        self.statusCode = "0"
        self.url = NSURL(string: "")
    }

    deinit {
        // Clean up disk files when model is evicted from _HttpDatasource
        if let path = _requestDataFilePath {
            try? FileManager.default.removeItem(atPath: path)
        }
        if let path = _responseDataFilePath {
            try? FileManager.default.removeItem(atPath: path)
        }
    }

    // MARK: - Disk-backed requestData

    @objc var requestData: Data? {
        get {
            guard let path = _requestDataFilePath else { return nil }
            return try? Data(contentsOf: URL(fileURLWithPath: path))
        }
        set {
            // Remove old file if exists
            if let oldPath = _requestDataFilePath {
                try? FileManager.default.removeItem(atPath: oldPath)
                _requestDataFilePath = nil
            }

            requestDataSize = UInt(newValue?.count ?? 0)

            guard let data = newValue, data.count > 0 else {
                return
            }

            let fileName = "req_\(UUID().uuidString)"
            let filePath = (_HttpModel.diskCacheDirectory() as NSString).appendingPathComponent(fileName)
            try? data.write(to: URL(fileURLWithPath: filePath))
            _requestDataFilePath = filePath
        }
    }

    // MARK: - Disk-backed responseData

    @objc var responseData: Data? {
        get {
            guard let path = _responseDataFilePath else { return nil }
            return try? Data(contentsOf: URL(fileURLWithPath: path))
        }
        set {
            // Remove old file if exists
            if let oldPath = _responseDataFilePath {
                try? FileManager.default.removeItem(atPath: oldPath)
                _responseDataFilePath = nil
            }

            responseDataSize = UInt(newValue?.count ?? 0)

            guard let data = newValue, data.count > 0 else {
                return
            }

            let fileName = "res_\(UUID().uuidString)"
            let filePath = (_HttpModel.diskCacheDirectory() as NSString).appendingPathComponent(fileName)
            try? data.write(to: URL(fileURLWithPath: filePath))
            _responseDataFilePath = filePath
        }
    }
}

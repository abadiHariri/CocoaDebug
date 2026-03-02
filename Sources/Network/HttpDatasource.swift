//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import Foundation

private let kDefaultMemoryBudget: UInt = 50 * 1024 * 1024 // 50 MB

@objc class _HttpDatasource: NSObject {

    @objc var httpModels: NSMutableArray
    @objc private(set) var totalDataSize: UInt = 0

    @objc static let shared = _HttpDatasource()

    private override init() {
        httpModels = NSMutableArray(capacity: 1000 + 100)
        totalDataSize = 0
        super.init()
        // Clear leftover disk cache from previous app session
        _HttpModel.clearDiskCache()
    }

    private func estimatedSizeOfModel(_ model: _HttpModel) -> UInt {
        // Use cached sizes - data is on disk, don't load it just to check length
        var size: UInt = 0
        size += UInt(model.requestDataSize)
        size += UInt(model.responseDataSize)
        size += 1024 // overhead for URL, headers, strings, etc.
        return size
    }

    /// NOTE: Keeping the typo "Requset" in the method name for compatibility
    @objc func addHttpRequset(_ model: _HttpModel) -> Bool {
        if model.url?.absoluteString == "" {
            return false
        }

        // url Filter, ignore case
        for urlString in _NetworkHelper.shared.ignoredURLs ?? [] {
            if model.url?.absoluteString?.lowercased().contains(urlString.lowercased()) ?? false {
                return false
            }
        }

        // All mutations to httpModels must be synchronized - stopLoading is called
        // from different protocol instance threads concurrently.
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        // Maximum number limit
        if httpModels.count >= 1000 {
            if httpModels.count > 0 {
                if let oldest = httpModels[0] as? _HttpModel {
                    let sizeToRemove = estimatedSizeOfModel(oldest)
                    totalDataSize = totalDataSize > sizeToRemove ? totalDataSize - sizeToRemove : 0
                }
                httpModels.removeObject(at: 0)
            }
        }

        // detect repeated (guard against nil — in ObjC [nil isEqualToString:nil] returns NO)
        var isExist = false
        for i in 0..<httpModels.count {
            if let obj = httpModels[i] as? _HttpModel {
                if let rid = obj.requestId, let mrid = model.requestId, rid == mrid {
                    isExist = true
                    break
                }
            }
        }
        if isExist {
            return false
        }

        // Enforce disk budget: evict oldest models until we have room
        let modelSize = estimatedSizeOfModel(model)
        while totalDataSize + modelSize > kDefaultMemoryBudget && httpModels.count > 0 {
            if let oldest = httpModels[0] as? _HttpModel {
                let sizeToRemove = estimatedSizeOfModel(oldest)
                totalDataSize = totalDataSize > sizeToRemove ? totalDataSize - sizeToRemove : 0
            }
            httpModels.removeObject(at: 0)
            // Note: model's dealloc deletes its disk files automatically
        }

        httpModels.add(model)
        totalDataSize += modelSize

        return true
    }

    @objc func reset() {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        httpModels.removeAllObjects()
        totalDataSize = 0
        // Clear all disk files
        _HttpModel.clearDiskCache()
    }

    @objc func remove(_ model: _HttpModel) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        // Enumerate in reverse to safely remove while iterating
        for i in stride(from: httpModels.count - 1, through: 0, by: -1) {
            if let obj = httpModels[i] as? _HttpModel {
                if let rid = obj.requestId, let mrid = model.requestId, rid == mrid {
                    let sizeToRemove = estimatedSizeOfModel(obj)
                    totalDataSize = totalDataSize > sizeToRemove ? totalDataSize - sizeToRemove : 0
                    httpModels.removeObject(at: i)
                    // Note: model's dealloc deletes its disk files automatically
                }
            }
        }
    }
}

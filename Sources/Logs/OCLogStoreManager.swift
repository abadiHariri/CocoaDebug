//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import Foundation

@objc class _OCLogStoreManager: NSObject {

    @objc var normalLogArray: NSMutableArray
    @objc var rnLogArray: NSMutableArray
    @objc var webLogArray: NSMutableArray

    @objc static let shared = _OCLogStoreManager()

    private override init() {
        normalLogArray = NSMutableArray(capacity: 1000 + 100)
        rnLogArray = NSMutableArray(capacity: 1000 + 100)
        webLogArray = NSMutableArray(capacity: 1000 + 100)
        super.init()
    }

    @objc func addLog(_ log: _OCLogModel) {
        guard log.content is String else { return }

        // log filter
        for prefixStr in _NetworkHelper.shared.onlyPrefixLogs ?? [] {
            if !(log.content?.hasPrefix(prefixStr) ?? false) {
                return
            }
        }
        // log filter
        for prefixStr in _NetworkHelper.shared.ignoredPrefixLogs ?? [] {
            if log.content?.hasPrefix(prefixStr) ?? false {
                return
            }
        }

        if log.logType == .normal {
            // normal
            if normalLogArray.count >= 1000 {
                if normalLogArray.count > 0 {
                    normalLogArray.removeObject(at: 0)
                }
            }
            normalLogArray.add(log)
        } else if log.logType == .rn {
            // rn
            if rnLogArray.count >= 1000 {
                if rnLogArray.count > 0 {
                    rnLogArray.removeObject(at: 0)
                }
            }
            rnLogArray.add(log)
        } else {
            // web
            if webLogArray.count >= 1000 {
                if webLogArray.count > 0 {
                    webLogArray.removeObject(at: 0)
                }
            }
            webLogArray.add(log)
        }
    }

    @objc func removeLog(_ log: _OCLogModel) {
        if log.logType == .normal {
            // normal
            normalLogArray.remove(log)
        } else if log.logType == .rn {
            // rn
            rnLogArray.remove(log)
        } else {
            // web
            webLogArray.remove(log)
        }
    }

    @objc func resetNormalLogs() {
        normalLogArray.removeAllObjects()
    }

    @objc func resetRNLogs() {
        rnLogArray.removeAllObjects()
    }

    @objc func resetWebLogs() {
        webLogArray.removeAllObjects()
    }
}

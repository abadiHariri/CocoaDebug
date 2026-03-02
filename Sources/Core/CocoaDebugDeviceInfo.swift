//
//  CocoaDebug
//  liman
//
//  Created by liman 02/02/2023.
//  Copyright © 2023 liman. All rights reserved.
//

import Foundation
import UIKit

@objc class CocoaDebugDeviceInfo: NSObject {

    @objc static let sharedInstance = CocoaDebugDeviceInfo()

    private override init() {
        super.init()
    }

    @objc var resolution: CGSize {
        let screen = UIScreen.main
        return CGSize(width: screen.bounds.size.width * screen.scale,
                      height: screen.bounds.size.height * screen.scale)
    }

    @objc var systemType: String {
        return UIDevice.current.systemName
    }

    @objc var userName: String {
        return UIDevice.current.name
    }

    @objc var systemVersion: String {
        return UIDevice.current.systemVersion
    }

    @objc var deviceModel: String {
        return UIDevice.current.model
    }

    @objc var deviceUUID: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }

    @objc var userPhoneName: String {
        return UIDevice.current.name
    }

    @objc var deviceName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machine = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(cString: $0)
            }
        }
        return machine
    }

    @objc var getPlatformString: String {
        return _DeviceUtil().hardwareSimpleDescription() ?? "Unknown"
    }

    @objc var localizedModel: String {
        return UIDevice.current.localizedModel
    }

    @objc var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    @objc var appBuiltVersion: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    }

    @objc var appBundleID: String {
        return Bundle.main.bundleIdentifier ?? ""
    }

    @objc var appBundleName: String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String ?? ""
    }
}

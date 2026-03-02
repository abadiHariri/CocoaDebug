//
//  CocoaDebug
//  liman
//
//  Created by liman 02/02/2023.
//  Copyright © 2023 liman. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Hardware Enum

@objc enum Hardware: UInt {
    case IPHONE_2G
    case IPHONE_3G
    case IPHONE_3GS
    case IPHONE_4
    case IPHONE_4_CDMA
    case IPHONE_4S
    case IPHONE_5
    case IPHONE_5_CDMA_GSM
    case IPHONE_5C
    case IPHONE_5C_CDMA_GSM
    case IPHONE_5S
    case IPHONE_5S_CDMA_GSM
    case IPHONE_6_PLUS
    case IPHONE_6
    case IPHONE_6S
    case IPHONE_6S_PLUS
    case IPHONE_SE
    case IPHONE_7
    case IPHONE_7_PLUS
    case IPHONE_7_GSM
    case IPHONE_7_PLUS_GSM
    case IPHONE_8_CN
    case IPHONE_8_PLUS_CN
    case IPHONE_X_CN
    case IPHONE_8
    case IPHONE_8_PLUS
    case IPHONE_X
    case IPHONE_XS
    case IPHONE_XS_MAX
    case IPHONE_XS_MAX_CN
    case IPHONE_XR
    case IPHONE_11
    case IPHONE_11_PRO
    case IPHONE_11_PRO_MAX
    case IPHONE_SE_2G
    case IPHONE_12_MINI
    case IPHONE_12
    case IPHONE_12_PRO
    case IPHONE_12_PRO_MAX
    case IPHONE_13_PRO
    case IPHONE_13_PRO_MAX
    case IPHONE_13_MINI
    case IPHONE_13
    case IPHONE_SE_3G
    case IPHONE_14
    case IPHONE_14_PLUS
    case IPHONE_14_PRO
    case IPHONE_14_PRO_MAX

    case IPOD_TOUCH_1G
    case IPOD_TOUCH_2G
    case IPOD_TOUCH_3G
    case IPOD_TOUCH_4G
    case IPOD_TOUCH_5G
    case IPOD_TOUCH_6G
    case IPOD_TOUCH_7G

    case IPAD
    case IPAD_3G
    case IPAD_2_WIFI
    case IPAD_2
    case IPAD_2_CDMA
    case IPAD_MINI_WIFI
    case IPAD_MINI
    case IPAD_MINI_WIFI_CDMA
    case IPAD_3_WIFI
    case IPAD_3_WIFI_CDMA
    case IPAD_3
    case IPAD_4_WIFI
    case IPAD_4
    case IPAD_4_GSM_CDMA
    case IPAD_AIR_WIFI
    case IPAD_AIR_WIFI_GSM
    case IPAD_AIR_WIFI_CDMA
    case IPAD_MINI_RETINA_WIFI
    case IPAD_MINI_RETINA_WIFI_CDMA
    case IPAD_MINI_RETINA_WIFI_CELLULAR_CN
    case IPAD_MINI_3_WIFI
    case IPAD_MINI_3_WIFI_CELLULAR
    case IPAD_MINI_3_WIFI_CELLULAR_CN
    case IPAD_MINI_4_WIFI
    case IPAD_MINI_4_WIFI_CELLULAR
    case IPAD_AIR_2_WIFI
    case IPAD_AIR_2_WIFI_CELLULAR
    case IPAD_5_WIFI
    case IPAD_5_WIFI_CELLULAR
    case IPAD_PRO_97_WIFI
    case IPAD_PRO_97_WIFI_CELLULAR
    case IPAD_PRO_WIFI
    case IPAD_PRO_WIFI_CELLULAR
    case IPAD_PRO_2G_WIFI
    case IPAD_7_WIFI
    case IPAD_7_WIFI_CELLULAR
    case IPAD_PRO_2G_WIFI_CELLULAR
    case IPAD_PRO_105_WIFI
    case IPAD_PRO_105_WIFI_CELLULAR
    case IPAD_6_WIFI
    case IPAD_6_WIFI_CELLULAR
    case IPAD_PRO_11_2G_WIFI_CELLULAR
    case IPAD_PRO_11_WIFI
    case IPAD_PRO_4G_WIFI
    case IPAD_PRO_11_1TB_WIFI
    case IPAD_PRO_11_WIFI_CELLULAR
    case IPAD_PRO_11_1TB_WIFI_CELLULAR
    case IPAD_PRO_3G_WIFI
    case IPAD_PRO_3G_1TB_WIFI
    case IPAD_PRO_3G_WIFI_CELLULAR
    case IPAD_PRO_4G_WIFI_CELLULAR
    case IPAD_PRO_3G_1TB_WIFI_CELLULAR
    case IPAD_PRO_11_2G_WIFI
    case IPAD_MINI_5_WIFI
    case IPAD_MINI_5_WIFI_CELLULAR
    case IPAD_AIR_3_WIFI
    case IPAD_AIR_3_WIFI_CELLULAR
    case IPAD_9_WIFI
    case IPAD_9_WIFI_CELLULAR
    case IPAD_PRO_5_WIFI_CELLULAR
    case IPAD_AIR_4_WIFI
    case IPAD_AIR_5_WIFI
    case IPAD_AIR_5_WIFI_CELLULAR
    case IPAD_AIR_4_WIFI_CELLULAR
    case IPAD_PRO_11_3_WIFI
    case IPAD_PRO_11_3_WIFI_CELLULAR
    case IPAD_PRO_5_WIFI
    case IPAD_MINI_6_WIFI
    case IPAD_MINI_6_WIFI_CELLULAR

    case APPLE_WATCH_38
    case APPLE_WATCH_42
    case APPLE_WATCH_SERIES_2_38
    case APPLE_WATCH_SERIES_2_42
    case APPLE_WATCH_SERIES_1_38
    case APPLE_WATCH_SERIES_1_42
    case APPLE_WATCH_SERIES_3_38_CELLULAR
    case APPLE_WATCH_SERIES_3_42_CELLULAR
    case APPLE_WATCH_SERIES_3_38
    case APPLE_WATCH_SERIES_3_42
    case APPLE_WATCH_SERIES_4_40
    case APPLE_WATCH_SERIES_4_44
    case APPLE_WATCH_SERIES_4_40_CELLULAR
    case APPLE_WATCH_SERIES_4_44_CELLULAR
    case APPLE_WATCH_SERIES_5_40
    case APPLE_WATCH_SERIES_5_44
    case APPLE_WATCH_SERIES_5_40_CELLULAR
    case APPLE_WATCH_SERIES_5_44_CELLULAR

    case APPLE_TV_1G
    case APPLE_TV_2G
    case APPLE_TV_3G
    case APPLE_TV_3_2G
    case APPLE_TV_4G
    case APPLE_TV_4K

    case SIMULATOR
    case UNKNOWN
}

// MARK: - Platform Enum

@objc enum Platform: UInt {
    case iPhone
    case iPodTouch
    case iPad
    case appleTV
    case appleWatch
    case unknown
}

// MARK: - _DeviceUtil

@objc class _DeviceUtil: NSObject {

    // MARK: - Hardware String Constants

    static let i386_Simulator = "i386"
    static let x86_64_Simulator = "x86_64"

    static let AppleTV1_1 = "AppleTV1,1"
    static let AppleTV2_1 = "AppleTV2,1"
    static let AppleTV3_1 = "AppleTV3,1"
    static let AppleTV3_2 = "AppleTV3,2"
    static let AppleTV5_3 = "AppleTV5,3"
    static let AppleTV6_2 = "AppleTV6,2"

    static let Watch1_1 = "Watch1,1"
    static let Watch1_2 = "Watch1,2"
    static let Watch2_3 = "Watch2,3"
    static let Watch2_4 = "Watch2,4"
    static let Watch2_6 = "Watch2,6"
    static let Watch2_7 = "Watch2,7"
    static let Watch3_1 = "Watch3,1"
    static let Watch3_2 = "Watch3,2"
    static let Watch3_3 = "Watch3,3"
    static let Watch3_4 = "Watch3,4"
    static let Watch4_1 = "Watch4,1"
    static let Watch4_2 = "Watch4,2"
    static let Watch4_3 = "Watch4,3"
    static let Watch4_4 = "Watch4,4"
    static let Watch5_1 = "Watch5,1"
    static let Watch5_2 = "Watch5,2"
    static let Watch5_3 = "Watch5,3"
    static let Watch5_4 = "Watch5,4"

    static let iPhone1_1 = "iPhone1,1"
    static let iPhone1_2 = "iPhone1,2"
    static let iPhone2_1 = "iPhone2,1"
    static let iPhone3_1 = "iPhone3,1"
    static let iPhone3_2 = "iPhone3,2"
    static let iPhone3_3 = "iPhone3,3"
    static let iPhone4_1 = "iPhone4,1"
    static let iPhone5_1 = "iPhone5,1"
    static let iPhone5_2 = "iPhone5,2"
    static let iPhone5_3 = "iPhone5,3"
    static let iPhone5_4 = "iPhone5,4"
    static let iPhone6_1 = "iPhone6,1"
    static let iPhone6_2 = "iPhone6,2"
    static let iPhone7_1 = "iPhone7,1"
    static let iPhone7_2 = "iPhone7,2"
    static let iPhone8_1 = "iPhone8,1"
    static let iPhone8_2 = "iPhone8,2"
    static let iPhone8_4 = "iPhone8,4"
    static let iPhone9_1 = "iPhone9,1"
    static let iPhone9_2 = "iPhone9,2"
    static let iPhone9_3 = "iPhone9,3"
    static let iPhone9_4 = "iPhone9,4"
    static let iPhone10_1 = "iPhone10,1"
    static let iPhone10_2 = "iPhone10,2"
    static let iPhone10_3 = "iPhone10,3"
    static let iPhone10_4 = "iPhone10,4"
    static let iPhone10_5 = "iPhone10,5"
    static let iPhone10_6 = "iPhone10,6"
    static let iPhone11_2 = "iPhone11,2"
    static let iPhone11_4 = "iPhone11,4"
    static let iPhone11_6 = "iPhone11,6"
    static let iPhone11_8 = "iPhone11,8"
    static let iPhone12_1 = "iPhone12,1"
    static let iPhone12_3 = "iPhone12,3"
    static let iPhone12_5 = "iPhone12,5"
    static let iPhone12_8 = "iPhone12,8"
    static let iPhone13_1 = "iPhone13,1"
    static let iPhone13_2 = "iPhone13,2"
    static let iPhone13_3 = "iPhone13,3"
    static let iPhone13_4 = "iPhone13,4"
    static let iPhone14_2 = "iPhone14,2"
    static let iPhone14_3 = "iPhone14,3"
    static let iPhone14_4 = "iPhone14,4"
    static let iPhone14_5 = "iPhone14,5"
    static let iPhone14_6 = "iPhone14,6"
    static let iPhone14_7 = "iPhone14,7"
    static let iPhone14_8 = "iPhone14,8"
    static let iPhone15_2 = "iPhone15,2"
    static let iPhone15_3 = "iPhone15,3"

    static let iPad1_1 = "iPad1,1"
    static let iPad1_2 = "iPad1,2"
    static let iPad2_1 = "iPad2,1"
    static let iPad2_2 = "iPad2,2"
    static let iPad2_3 = "iPad2,3"
    static let iPad2_4 = "iPad2,4"
    static let iPad2_5 = "iPad2,5"
    static let iPad2_6 = "iPad2,6"
    static let iPad2_7 = "iPad2,7"
    static let iPad3_1 = "iPad3,1"
    static let iPad3_2 = "iPad3,2"
    static let iPad3_3 = "iPad3,3"
    static let iPad3_4 = "iPad3,4"
    static let iPad3_5 = "iPad3,5"
    static let iPad3_6 = "iPad3,6"
    static let iPad4_1 = "iPad4,1"
    static let iPad4_2 = "iPad4,2"
    static let iPad4_3 = "iPad4,3"
    static let iPad4_4 = "iPad4,4"
    static let iPad4_5 = "iPad4,5"
    static let iPad4_6 = "iPad4,6"
    static let iPad4_7 = "iPad4,7"
    static let iPad4_8 = "iPad4,8"
    static let iPad4_9 = "iPad4,9"
    static let iPad5_1 = "iPad5,1"
    static let iPad5_2 = "iPad5,2"
    static let iPad5_3 = "iPad5,3"
    static let iPad5_4 = "iPad5,4"
    static let iPad6_3 = "iPad6,3"
    static let iPad6_4 = "iPad6,4"
    static let iPad6_7 = "iPad6,7"
    static let iPad6_8 = "iPad6,8"
    static let iPad6_11 = "iPad6,11"
    static let iPad6_12 = "iPad6,12"
    static let iPad7_1 = "iPad7,1"
    static let iPad7_2 = "iPad7,2"
    static let iPad7_3 = "iPad7,3"
    static let iPad7_4 = "iPad7,4"
    static let iPad7_5 = "iPad7,5"
    static let iPad7_6 = "iPad7,6"
    static let iPad7_11 = "iPad7,11"
    static let iPad7_12 = "iPad7,12"
    static let iPad8_1 = "iPad8,1"
    static let iPad8_2 = "iPad8,2"
    static let iPad8_3 = "iPad8,3"
    static let iPad8_4 = "iPad8,4"
    static let iPad8_5 = "iPad8,5"
    static let iPad8_6 = "iPad8,6"
    static let iPad8_7 = "iPad8,7"
    static let iPad8_8 = "iPad8,8"
    static let iPad8_9 = "iPad8,9"
    static let iPad8_10 = "iPad8,10"
    static let iPad8_11 = "iPad8,11"
    static let iPad8_12 = "iPad8,12"
    static let iPad11_1 = "iPad11,1"
    static let iPad11_2 = "iPad11,2"
    static let iPad11_3 = "iPad11,3"
    static let iPad11_4 = "iPad11,4"
    static let iPad12_1 = "iPad12,1"
    static let iPad12_2 = "iPad12,2"
    static let iPad13_1 = "iPad13,1"
    static let iPad13_2 = "iPad13,2"
    static let iPad13_4 = "iPad13,4"
    static let iPad13_5 = "iPad13,5"
    static let iPad13_6 = "iPad13,6"
    static let iPad13_7 = "iPad13,7"
    static let iPad13_8 = "iPad13,8"
    static let iPad13_9 = "iPad13,9"
    static let iPad13_10 = "iPad13,10"
    static let iPad13_11 = "iPad13,11"
    static let iPad13_16 = "iPad13,16"
    static let iPad13_17 = "iPad13,17"
    static let iPad14_1 = "iPad14,1"
    static let iPad14_2 = "iPad14,2"

    static let iPod1_1 = "iPod1,1"
    static let iPod2_1 = "iPod2,1"
    static let iPod3_1 = "iPod3,1"
    static let iPod4_1 = "iPod4,1"
    static let iPod5_1 = "iPod5,1"
    static let iPod7_1 = "iPod7,1"
    static let iPod9_1 = "iPod9,1"

    // MARK: - Device List

    private var deviceList: [String: [String: String]]

    override init() {
        deviceList = [
            "AppleTV1,1": ["name": "Apple TV 1G", "version": "1.1"],
            "AppleTV2,1": ["name": "Apple TV 2G", "version": "2.1"],
            "AppleTV3,1": ["name": "Apple TV 2012", "version": "3.1"],
            "AppleTV3,2": ["name": "Apple TV 2013", "version": "3.2"],
            "AppleTV5,3": ["name": "Apple TV 4G", "version": "5.3"],
            "AppleTV6,2": ["name": "Apple TV 4K", "version": "6.2"],
            "Watch1,1": ["name": "Apple Watch (38 mm)", "version": "1.1"],
            "Watch1,2": ["name": "Apple Watch (42 mm)", "version": "1.2"],
            "Watch2,3": ["name": "Apple Watch Series 2 (38 mm)", "version": "2.3"],
            "Watch2,4": ["name": "Apple Watch Series 2 (42 mm)", "version": "2.4"],
            "Watch2,6": ["name": "Apple Watch Series 1 (38 mm)", "version": "2.6"],
            "Watch2,7": ["name": "Apple Watch Series 1 (42 mm)", "version": "2.7"],
            "Watch3,1": ["name": "Apple Watch Series 3 (38 mm/Cellular)", "version": "3.1"],
            "Watch3,2": ["name": "Apple Watch Series 3 (42 mm/Cellular)", "version": "3.2"],
            "Watch3,3": ["name": "Apple Watch Series 3 (38 mm)", "version": "3.3"],
            "Watch3,4": ["name": "Apple Watch Series 3 (42 mm)", "version": "3.4"],
            "Watch4,1": ["name": "Apple Watch Series 4 (40 mm)", "version": "4.1"],
            "Watch4,2": ["name": "Apple Watch Series 4 (44 mm)", "version": "4.2"],
            "Watch4,3": ["name": "Apple Watch Series 4 (40 mm/Cellular)", "version": "4.3"],
            "Watch4,4": ["name": "Apple Watch Series 4 (44 mm/Cellular)", "version": "4.4"],
            "Watch5,1": ["name": "Apple Watch Series 5 (40 mm)", "version": "5.1"],
            "Watch5,2": ["name": "Apple Watch Series 5 (44 mm)", "version": "5.2"],
            "Watch5,3": ["name": "Apple Watch Series 5 (40 mm/Cellular)", "version": "5.3"],
            "Watch5,4": ["name": "Apple Watch Series 5 (44 mm/Cellular)", "version": "5.4"],
            "i386": ["name": "Simulator", "version": "-1"],
            "x86_64": ["name": "Simulator", "version": "-1"],
            "iPad1,1": ["name": "iPad (WiFi)", "version": "1.1"],
            "iPad1,2": ["name": "iPad 3G", "version": "1.2"],
            "iPad2,1": ["name": "iPad 2 (WiFi)", "version": "2.1"],
            "iPad2,2": ["name": "iPad 2 (GSM)", "version": "2.2"],
            "iPad2,3": ["name": "iPad 2 (CDMA)", "version": "2.3"],
            "iPad2,4": ["name": "iPad 2 (WiFi Rev. A)", "version": "2.4"],
            "iPad2,5": ["name": "iPad Mini (WiFi)", "version": "2.5"],
            "iPad2,6": ["name": "iPad Mini (GSM)", "version": "2.6"],
            "iPad2,7": ["name": "iPad Mini (CDMA)", "version": "2.7"],
            "iPad3,1": ["name": "iPad 3 (WiFi)", "version": "3.1"],
            "iPad3,2": ["name": "iPad 3 (CDMA)", "version": "3.2"],
            "iPad3,3": ["name": "iPad 3 (Global)", "version": "3.3"],
            "iPad3,4": ["name": "iPad 4 (WiFi)", "version": "3.4"],
            "iPad3,5": ["name": "iPad 4 (CDMA)", "version": "3.5"],
            "iPad3,6": ["name": "iPad 4 (Global)", "version": "3.6"],
            "iPad4,1": ["name": "iPad Air (WiFi)", "version": "4.1"],
            "iPad4,2": ["name": "iPad Air (WiFi+GSM)", "version": "4.2"],
            "iPad4,3": ["name": "iPad Air (WiFi+CDMA)", "version": "4.3"],
            "iPad4,4": ["name": "iPad Mini Retina (WiFi)", "version": "4.4"],
            "iPad4,5": ["name": "iPad Mini Retina (WiFi+CDMA)", "version": "4.5"],
            "iPad4,6": ["name": "iPad Mini Retina (Wi-Fi + Cellular CN)", "version": "4.6"],
            "iPad4,7": ["name": "iPad Mini 3 (Wi-Fi)", "version": "4.7"],
            "iPad4,8": ["name": "iPad Mini 3 (Wi-Fi + Cellular)", "version": "4.8"],
            "iPad4,9": ["name": "iPad mini 3 (Wi-Fi/Cellular, China)", "version": "4.9"],
            "iPad5,1": ["name": "iPad mini 4 (Wi-Fi Only)", "version": "5.1"],
            "iPad5,2": ["name": "iPad mini 4 (Wi-Fi/Cellular)", "version": "5.2"],
            "iPad5,3": ["name": "iPad Air 2 (Wi-Fi)", "version": "5.3"],
            "iPad5,4": ["name": "iPad Air 2 (Wi-Fi + Cellular)", "version": "5.4"],
            "iPad6,3": ["name": "iPad Pro 9.7-inch (Wi-Fi Only)", "version": "6.3"],
            "iPad6,4": ["name": "iPad Pro 9.7-inch (Wi-Fi + Cellular)", "version": "6.4"],
            "iPad6,7": ["name": "iPad Pro (Wi-Fi Only)", "version": "6.7"],
            "iPad6,8": ["name": "iPad Pro (Wi-Fi/Cellular)", "version": "6.8"],
            "iPad6,11": ["name": "9.7-inch iPad (Wi-Fi)", "version": "6.11"],
            "iPad6,12": ["name": "9.7-inch iPad (Wi-Fi + Cellular)", "version": "6.12"],
            "iPad7,1": ["name": "iPad Pro 12.9-Inch (Wi-Fi Only - 2nd Gen)", "version": "7.1"],
            "iPad7,2": ["name": "iPad Pro 12.9-Inch (Wi-Fi/Cell - 2nd Gen)", "version": "7.2"],
            "iPad7,3": ["name": "iPad Pro 10.5-Inch (Wi-Fi Only)", "version": "7.3"],
            "iPad7,4": ["name": "iPad Pro 10.5-Inch (Wi-Fi/Cellular)", "version": "7.4"],
            "iPad7,5": ["name": "iPad 9.7-Inch 6th Gen (Wi-Fi Only)", "version": "7.5"],
            "iPad7,6": ["name": "iPad 9.7-Inch 6th Gen (Wi-Fi/Cellular)", "version": "7.6"],
            "iPad7,11": ["name": "iPad 10.2-Inch 7th Gen (Wi-Fi Only)", "version": "7.11"],
            "iPad7,12": ["name": "iPad 10.2-Inch 7th Gen (Wi-Fi/Cellular Only)", "version": "7.12"],
            "iPad8,1": ["name": "iPad Pro 11-Inch (Wi-Fi Only)", "version": "8.1"],
            "iPad8,2": ["name": "iPad Pro 11-Inch 1TB (Wi-Fi Only)", "version": "8.199999999999999"],
            "iPad8,3": ["name": "iPad Pro 11-Inch (Wi-Fi/Cellular)", "version": "8.300000000000001"],
            "iPad8,4": ["name": "iPad Pro 11-Inch 1TB (Wi-Fi/Cellular)", "version": "8.4"],
            "iPad8,5": ["name": "iPad Pro 12.9-Inch (Wi-Fi Only - 3rd Gen)", "version": "8.5"],
            "iPad8,6": ["name": "iPad Pro 12.9-Inch 1TB (Wi-Fi Only - 3rd Gen)", "version": "8.6"],
            "iPad8,7": ["name": "iPad Pro 12.9-Inch (Wi-Fi/Cell - 3rd Gen)", "version": "8.699999999999999"],
            "iPad8,8": ["name": "iPad Pro 12.9-Inch 1TB (Wi-Fi/Cell - 3rd Gen)", "version": "8.800000000000001"],
            "iPad8,9": ["name": "iPad Pro 11-Inch (Wi-Fi Only - 2nd Gen)", "version": "8.9"],
            "iPad8,10": ["name": "iPad Pro 11-Inch (Wi-Fi/Cellular - 2nd Gen)", "version": "8.1"],
            "iPad8,11": ["name": "iPad Pro 12.9-Inch 1TB (Wi-Fi Only - 4th Gen)", "version": "8.109999999999999"],
            "iPad8,12": ["name": "iPad Pro 12.9-Inch (Wi-Fi/Cell - 4th Gen)", "version": "8.800000000000001"],
            "iPad11,1": ["name": "iPad mini 5 (Wi-Fi Only)", "version": "11.1"],
            "iPad11,2": ["name": "iPad mini 5 (Wi-Fi/Cellular)", "version": "11.2"],
            "iPad11,3": ["name": "iPad Air 3 (Wi-Fi)", "version": "11.3"],
            "iPad11,4": ["name": "iPad Air 3 (Wi-Fi + Cellular)", "version": "11.4"],
            "iPad12,1": ["name": "iPad 9 (Wi-Fi)", "version": "12.1"],
            "iPad12,2": ["name": "iPad 9 (Wi-Fi + Cellular)", "version": "12.2"],
            "iPad13,1": ["name": "iPad Air 4 (Wi-Fi)", "version": "13.1"],
            "iPad13,2": ["name": "iPad Air 4 (Wi-Fi + Cellular)", "version": "13.2"],
            "iPad13,4": ["name": "iPad Pro 11\" 3rd Gen (Wi-Fi)", "version": "13.4"],
            "iPad13,5": ["name": "iPad Pro 11\" 3rd Gen (Wi-Fi + Cellular)", "version": "13.5"],
            "iPad13,6": ["name": "iPad Pro 11\" 3rd Gen (Wi-Fi + Cellular)", "version": "13.6"],
            "iPad13,7": ["name": "iPad Pro 11\" 3rd Gen (Wi-Fi + Cellular)", "version": "13.7"],
            "iPad13,8": ["name": "iPad Pro 12.9\" 5th Gen (Wi-Fi)", "version": "13.8"],
            "iPad13,9": ["name": "iPad Pro 12.9\" 5th Gen (Wi-Fi + Cellular)", "version": "13.9"],
            "iPad13,10": ["name": "iPad Pro 12.9\" 5th Gen (Wi-Fi + Cellular)", "version": "13.1"],
            "iPad13,11": ["name": "iPad Pro 12.9\" 5th Gen (Wi-Fi + Cellular)", "version": "13.11"],
            "iPad13,16": ["name": "iPad Air 5th Gen (Wi-Fi)", "version": "13.16"],
            "iPad13,17": ["name": "iPad Air 5th Gen (Wi-Fi + Cellular)", "version": "13.17"],
            "iPad14,1": ["name": "iPad Mini 6 (Wi-Fi)", "version": "14.1"],
            "iPad14,2": ["name": "iPad Mini 6 (Wi-Fi + Cellular)", "version": "14.2"],
            "iPhone1,1": ["name": "iPhone 2G", "version": "1.1"],
            "iPhone1,2": ["name": "iPhone 3G", "version": "1.2"],
            "iPhone2,1": ["name": "iPhone 3GS", "version": "2.1"],
            "iPhone3,1": ["name": "iPhone 4 (GSM)", "version": "3.1"],
            "iPhone3,2": ["name": "iPhone 4 (GSM Rev. A)", "version": "3.2"],
            "iPhone3,3": ["name": "iPhone 4 (CDMA)", "version": "3.3"],
            "iPhone4,1": ["name": "iPhone 4S", "version": "4.1"],
            "iPhone5,1": ["name": "iPhone 5 (GSM)", "version": "5.1"],
            "iPhone5,2": ["name": "iPhone 5 (Global)", "version": "5.2"],
            "iPhone5,3": ["name": "iPhone 5c (GSM)", "version": "5.3"],
            "iPhone5,4": ["name": "iPhone 5c (Global)", "version": "5.4"],
            "iPhone6,1": ["name": "iPhone 5s (GSM)", "version": "6.1"],
            "iPhone6,2": ["name": "iPhone 5s (Global)", "version": "6.2"],
            "iPhone7,1": ["name": "iPhone 6 Plus", "version": "7.1"],
            "iPhone7,2": ["name": "iPhone 6", "version": "7.2"],
            "iPhone8,1": ["name": "iPhone 6s", "version": "8.1"],
            "iPhone8,2": ["name": "iPhone 6s Plus", "version": "8.199999999999999"],
            "iPhone8,4": ["name": "iPhone SE", "version": "8.4"],
            "iPhone9,1": ["name": "iPhone 7", "version": "9.1"],
            "iPhone9,2": ["name": "iPhone 7 Plus", "version": "9.199999999999999"],
            "iPhone9,3": ["name": "iPhone 7", "version": "9.300000000000001"],
            "iPhone9,4": ["name": "iPhone 7 Plus", "version": "9.4"],
            "iPhone10,1": ["name": "iPhone 8", "version": "10.1"],
            "iPhone10,2": ["name": "iPhone 8 Plus", "version": "10.2"],
            "iPhone10,3": ["name": "iPhone X", "version": "10.3"],
            "iPhone10,4": ["name": "iPhone 8", "version": "10.4"],
            "iPhone10,5": ["name": "iPhone 8 Plus", "version": "10.5"],
            "iPhone10,6": ["name": "iPhone X", "version": "10.6"],
            "iPhone11,2": ["name": "iPhone XS", "version": "11.2"],
            "iPhone11,4": ["name": "iPhone XS Max", "version": "11.4"],
            "iPhone11,6": ["name": "iPhone XS Max China", "version": "11.6"],
            "iPhone11,8": ["name": "iPhone XR", "version": "11.8"],
            "iPhone12,1": ["name": "iPhone 11", "version": "12.1"],
            "iPhone12,3": ["name": "iPhone 11 Pro", "version": "12.3"],
            "iPhone12,5": ["name": "iPhone 11 Pro Max", "version": "12.5"],
            "iPhone12,8": ["name": "iPhone SE (2 Gen)", "version": "12.8"],
            "iPhone13,1": ["name": "iPhone 12 mini", "version": "13.1"],
            "iPhone13,2": ["name": "iPhone 12", "version": "13.2"],
            "iPhone13,3": ["name": "iPhone 12 Pro", "version": "13.3"],
            "iPhone13,4": ["name": "iPhone 12 Pro Max", "version": "13.4"],
            "iPhone14,2": ["name": "iPhone 13 Pro", "version": "14.2"],
            "iPhone14,3": ["name": "iPhone 13 Pro Max", "version": "14.3"],
            "iPhone14,4": ["name": "iPhone 13 mini", "version": "14.4"],
            "iPhone14,5": ["name": "iPhone 13", "version": "14.5"],
            "iPhone14,6": ["name": "iPhone SE (3 Gen)", "version": "14.6"],
            "iPhone14,7": ["name": "iPhone 14", "version": "14.7"],
            "iPhone14,8": ["name": "iPhone 14 Plus", "version": "14.8"],
            "iPhone15,2": ["name": "iPhone 14 Pro", "version": "15.2"],
            "iPhone15,3": ["name": "iPhone 14 Pro Max", "version": "15.3"],
            "iPod1,1": ["name": "iPod Touch (1 Gen)", "version": "1.1"],
            "iPod2,1": ["name": "iPod Touch (2 Gen)", "version": "2.1"],
            "iPod3,1": ["name": "iPod Touch (3 Gen)", "version": "3.1"],
            "iPod4,1": ["name": "iPod Touch (4 Gen)", "version": "4.1"],
            "iPod5,1": ["name": "iPod Touch (5 Gen)", "version": "5.1"],
            "iPod7,1": ["name": "iPod Touch (6 Gen)", "version": "7.1"],
            "iPod9,1": ["name": "iPod Touch (7 Gen)", "version": "9.1"],
        ]
        super.init()
    }

    // MARK: - Hardware String

    private func nativeHardwareString() -> String {
        var name: [Int32] = [CTL_HW, HW_MACHINE]
        var size: Int = 100
        sysctl(&name, 2, nil, &size, nil, 0)
        let hw_machine = UnsafeMutablePointer<CChar>.allocate(capacity: size)
        sysctl(&name, 2, hw_machine, &size, nil, 0)
        let hardware = String(cString: hw_machine)
        hw_machine.deallocate()
        return hardware
    }

    @objc func hardwareString() -> String {
        var hardware = nativeHardwareString()

        // Check if the hardware is simulator
        if hardware == _DeviceUtil.i386_Simulator || hardware == _DeviceUtil.x86_64_Simulator {
            if let deviceID = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] {
                hardware = deviceID
            }
        }
        return hardware
    }

    // MARK: - Platform

    @objc func platform() -> Platform {
        let hardware = hardwareString()

        if hardware.hasPrefix("iPhone")  { return .iPhone }
        if hardware.hasPrefix("iPod")    { return .iPodTouch }
        if hardware.hasPrefix("iPad")    { return .iPad }
        if hardware.hasPrefix("Watch")   { return .appleWatch }
        if hardware.hasPrefix("AppleTV") { return .appleTV }

        return .unknown
    }

    // MARK: - Hardware

    private func nativeHardware() -> Hardware {
        let hardware = nativeHardwareString()
        if hardware == _DeviceUtil.i386_Simulator  { return .SIMULATOR }
        if hardware == _DeviceUtil.x86_64_Simulator { return .SIMULATOR }
        return self.hardware()
    }

    @objc func hardware() -> Hardware {
        let hardware = hardwareString()

        if hardware == _DeviceUtil.AppleTV1_1 { return .APPLE_TV_1G }
        if hardware == _DeviceUtil.AppleTV2_1 { return .APPLE_TV_2G }
        if hardware == _DeviceUtil.AppleTV3_1 { return .APPLE_TV_3G }
        if hardware == _DeviceUtil.AppleTV3_2 { return .APPLE_TV_3_2G }
        if hardware == _DeviceUtil.AppleTV5_3 { return .APPLE_TV_4G }
        if hardware == _DeviceUtil.AppleTV6_2 { return .APPLE_TV_4K }

        if hardware == _DeviceUtil.Watch1_1 { return .APPLE_WATCH_38 }
        if hardware == _DeviceUtil.Watch1_2 { return .APPLE_WATCH_42 }
        if hardware == _DeviceUtil.Watch2_3 { return .APPLE_WATCH_SERIES_2_38 }
        if hardware == _DeviceUtil.Watch2_4 { return .APPLE_WATCH_SERIES_2_42 }
        if hardware == _DeviceUtil.Watch2_6 { return .APPLE_WATCH_SERIES_1_38 }
        if hardware == _DeviceUtil.Watch2_7 { return .APPLE_WATCH_SERIES_1_42 }
        if hardware == _DeviceUtil.Watch3_1 { return .APPLE_WATCH_SERIES_3_38_CELLULAR }
        if hardware == _DeviceUtil.Watch3_2 { return .APPLE_WATCH_SERIES_3_42_CELLULAR }
        if hardware == _DeviceUtil.Watch3_3 { return .APPLE_WATCH_SERIES_3_38 }
        if hardware == _DeviceUtil.Watch3_4 { return .APPLE_WATCH_SERIES_3_42 }
        if hardware == _DeviceUtil.Watch4_1 { return .APPLE_WATCH_SERIES_4_40 }
        if hardware == _DeviceUtil.Watch4_2 { return .APPLE_WATCH_SERIES_4_44 }
        if hardware == _DeviceUtil.Watch4_3 { return .APPLE_WATCH_SERIES_4_40_CELLULAR }
        if hardware == _DeviceUtil.Watch4_4 { return .APPLE_WATCH_SERIES_4_44_CELLULAR }
        if hardware == _DeviceUtil.Watch5_1 { return .APPLE_WATCH_SERIES_5_40 }
        if hardware == _DeviceUtil.Watch5_2 { return .APPLE_WATCH_SERIES_5_44 }
        if hardware == _DeviceUtil.Watch5_3 { return .APPLE_WATCH_SERIES_5_40_CELLULAR }
        if hardware == _DeviceUtil.Watch5_4 { return .APPLE_WATCH_SERIES_5_44_CELLULAR }

        if hardware == _DeviceUtil.i386_Simulator { return .SIMULATOR }

        if hardware == _DeviceUtil.iPad1_1  { return .IPAD }
        if hardware == _DeviceUtil.iPad1_2  { return .IPAD_3G }
        if hardware == _DeviceUtil.iPad11_1 { return .IPAD_MINI_5_WIFI }
        if hardware == _DeviceUtil.iPad11_2 { return .IPAD_MINI_5_WIFI_CELLULAR }
        if hardware == _DeviceUtil.iPad11_3 { return .IPAD_AIR_3_WIFI }
        if hardware == _DeviceUtil.iPad11_4 { return .IPAD_AIR_3_WIFI_CELLULAR }
        if hardware == _DeviceUtil.iPad12_1 { return .IPAD_9_WIFI }
        if hardware == _DeviceUtil.iPad12_2 { return .IPAD_9_WIFI_CELLULAR }
        if hardware == _DeviceUtil.iPad13_1 { return .IPAD_AIR_4_WIFI }
        if hardware == _DeviceUtil.iPad13_10 { return .IPAD_PRO_5_WIFI_CELLULAR }
        if hardware == _DeviceUtil.iPad13_11 { return .IPAD_PRO_5_WIFI_CELLULAR }
        if hardware == _DeviceUtil.iPad13_16 { return .IPAD_AIR_5_WIFI }
        if hardware == _DeviceUtil.iPad13_17 { return .IPAD_AIR_5_WIFI_CELLULAR }
        if hardware == _DeviceUtil.iPad13_2 { return .IPAD_AIR_4_WIFI_CELLULAR }
        if hardware == _DeviceUtil.iPad13_4 { return .IPAD_PRO_11_3_WIFI }
        if hardware == _DeviceUtil.iPad13_5 { return .IPAD_AIR_4_WIFI_CELLULAR }
        if hardware == _DeviceUtil.iPad13_6 { return .IPAD_PRO_11_3_WIFI_CELLULAR }
        if hardware == _DeviceUtil.iPad13_7 { return .IPAD_PRO_11_3_WIFI_CELLULAR }
        if hardware == _DeviceUtil.iPad13_8 { return .IPAD_PRO_5_WIFI }
        if hardware == _DeviceUtil.iPad13_9 { return .IPAD_PRO_5_WIFI_CELLULAR }
        if hardware == _DeviceUtil.iPad14_1 { return .IPAD_MINI_6_WIFI }
        if hardware == _DeviceUtil.iPad14_2 { return .IPAD_MINI_6_WIFI_CELLULAR }
        if hardware == _DeviceUtil.iPad2_1  { return .IPAD_2_WIFI }
        if hardware == _DeviceUtil.iPad2_2  { return .IPAD_2 }
        if hardware == _DeviceUtil.iPad2_3  { return .IPAD_2_CDMA }
        if hardware == _DeviceUtil.iPad2_4  { return .IPAD_2 }
        if hardware == _DeviceUtil.iPad2_5  { return .IPAD_MINI_WIFI }
        if hardware == _DeviceUtil.iPad2_6  { return .IPAD_MINI }
        if hardware == _DeviceUtil.iPad2_7  { return .IPAD_MINI_WIFI_CDMA }
        if hardware == _DeviceUtil.iPad3_1  { return .IPAD_3_WIFI }
        if hardware == _DeviceUtil.iPad3_2  { return .IPAD_3_WIFI_CDMA }
        if hardware == _DeviceUtil.iPad3_3  { return .IPAD_3 }
        if hardware == _DeviceUtil.iPad3_4  { return .IPAD_4_WIFI }
        if hardware == _DeviceUtil.iPad3_5  { return .IPAD_4 }
        if hardware == _DeviceUtil.iPad3_6  { return .IPAD_4_GSM_CDMA }
        if hardware == _DeviceUtil.iPad4_1  { return .IPAD_AIR_WIFI }
        if hardware == _DeviceUtil.iPad4_2  { return .IPAD_AIR_WIFI_GSM }
        if hardware == _DeviceUtil.iPad4_3  { return .IPAD_AIR_WIFI_CDMA }
        if hardware == _DeviceUtil.iPad4_4  { return .IPAD_MINI_RETINA_WIFI }
        if hardware == _DeviceUtil.iPad4_5  { return .IPAD_MINI_RETINA_WIFI_CDMA }
        if hardware == _DeviceUtil.iPad4_6  { return .IPAD_MINI_RETINA_WIFI_CELLULAR_CN }
        if hardware == _DeviceUtil.iPad4_7  { return .IPAD_MINI_3_WIFI }
        if hardware == _DeviceUtil.iPad4_8  { return .IPAD_MINI_3_WIFI_CELLULAR }
        if hardware == _DeviceUtil.iPad4_9  { return .IPAD_MINI_3_WIFI_CELLULAR_CN }
        if hardware == _DeviceUtil.iPad5_1  { return .IPAD_MINI_4_WIFI }
        if hardware == _DeviceUtil.iPad5_2  { return .IPAD_MINI_4_WIFI_CELLULAR }
        if hardware == _DeviceUtil.iPad5_3  { return .IPAD_AIR_2_WIFI }
        if hardware == _DeviceUtil.iPad5_4  { return .IPAD_AIR_2_WIFI_CELLULAR }
        if hardware == _DeviceUtil.iPad6_11 { return .IPAD_5_WIFI }
        if hardware == _DeviceUtil.iPad6_12 { return .IPAD_5_WIFI_CELLULAR }
        if hardware == _DeviceUtil.iPad6_3  { return .IPAD_PRO_97_WIFI }
        if hardware == _DeviceUtil.iPad6_4  { return .IPAD_PRO_97_WIFI_CELLULAR }
        if hardware == _DeviceUtil.iPad6_7  { return .IPAD_PRO_WIFI }
        if hardware == _DeviceUtil.iPad6_8  { return .IPAD_PRO_WIFI_CELLULAR }
        if hardware == _DeviceUtil.iPad7_1  { return .IPAD_PRO_2G_WIFI }
        if hardware == _DeviceUtil.iPad7_11 { return .IPAD_7_WIFI }
        if hardware == _DeviceUtil.iPad7_12 { return .IPAD_7_WIFI_CELLULAR }
        if hardware == _DeviceUtil.iPad7_2  { return .IPAD_PRO_2G_WIFI_CELLULAR }
        if hardware == _DeviceUtil.iPad7_3  { return .IPAD_PRO_105_WIFI }
        if hardware == _DeviceUtil.iPad7_4  { return .IPAD_PRO_105_WIFI_CELLULAR }
        if hardware == _DeviceUtil.iPad7_5  { return .IPAD_6_WIFI }
        if hardware == _DeviceUtil.iPad7_6  { return .IPAD_6_WIFI_CELLULAR }
        if hardware == _DeviceUtil.iPad8_1  { return .IPAD_PRO_11_WIFI }
        if hardware == _DeviceUtil.iPad8_10 { return .IPAD_PRO_11_2G_WIFI_CELLULAR }
        if hardware == _DeviceUtil.iPad8_11 { return .IPAD_PRO_4G_WIFI }
        if hardware == _DeviceUtil.iPad8_12 { return .IPAD_PRO_4G_WIFI_CELLULAR }
        if hardware == _DeviceUtil.iPad8_2  { return .IPAD_PRO_11_1TB_WIFI }
        if hardware == _DeviceUtil.iPad8_3  { return .IPAD_PRO_11_WIFI_CELLULAR }
        if hardware == _DeviceUtil.iPad8_4  { return .IPAD_PRO_11_1TB_WIFI_CELLULAR }
        if hardware == _DeviceUtil.iPad8_5  { return .IPAD_PRO_3G_WIFI }
        if hardware == _DeviceUtil.iPad8_6  { return .IPAD_PRO_3G_1TB_WIFI }
        if hardware == _DeviceUtil.iPad8_7  { return .IPAD_PRO_3G_WIFI_CELLULAR }
        if hardware == _DeviceUtil.iPad8_8  { return .IPAD_PRO_3G_1TB_WIFI_CELLULAR }
        if hardware == _DeviceUtil.iPad8_9  { return .IPAD_PRO_11_2G_WIFI }

        if hardware == _DeviceUtil.iPhone1_1  { return .IPHONE_2G }
        if hardware == _DeviceUtil.iPhone1_2  { return .IPHONE_3G }
        if hardware == _DeviceUtil.iPhone10_1 { return .IPHONE_8_CN }
        if hardware == _DeviceUtil.iPhone10_2 { return .IPHONE_8_PLUS_CN }
        if hardware == _DeviceUtil.iPhone10_3 { return .IPHONE_X_CN }
        if hardware == _DeviceUtil.iPhone10_4 { return .IPHONE_8 }
        if hardware == _DeviceUtil.iPhone10_5 { return .IPHONE_8_PLUS }
        if hardware == _DeviceUtil.iPhone10_6 { return .IPHONE_X }
        if hardware == _DeviceUtil.iPhone11_2 { return .IPHONE_XS }
        if hardware == _DeviceUtil.iPhone11_4 { return .IPHONE_XS_MAX }
        if hardware == _DeviceUtil.iPhone11_6 { return .IPHONE_XS_MAX_CN }
        if hardware == _DeviceUtil.iPhone11_8 { return .IPHONE_XR }
        if hardware == _DeviceUtil.iPhone12_1 { return .IPHONE_11 }
        if hardware == _DeviceUtil.iPhone12_3 { return .IPHONE_11_PRO }
        if hardware == _DeviceUtil.iPhone12_5 { return .IPHONE_11_PRO_MAX }
        if hardware == _DeviceUtil.iPhone12_8 { return .IPHONE_SE_2G }
        if hardware == _DeviceUtil.iPhone13_1 { return .IPHONE_12_MINI }
        if hardware == _DeviceUtil.iPhone13_2 { return .IPHONE_12 }
        if hardware == _DeviceUtil.iPhone13_3 { return .IPHONE_12_PRO }
        if hardware == _DeviceUtil.iPhone13_4 { return .IPHONE_12_PRO_MAX }
        if hardware == _DeviceUtil.iPhone14_2 { return .IPHONE_13_PRO }
        if hardware == _DeviceUtil.iPhone14_3 { return .IPHONE_13_PRO_MAX }
        if hardware == _DeviceUtil.iPhone14_4 { return .IPHONE_13_MINI }
        if hardware == _DeviceUtil.iPhone14_5 { return .IPHONE_13 }
        if hardware == _DeviceUtil.iPhone14_6 { return .IPHONE_SE_3G }
        if hardware == _DeviceUtil.iPhone14_7 { return .IPHONE_14 }
        if hardware == _DeviceUtil.iPhone14_8 { return .IPHONE_14_PLUS }
        if hardware == _DeviceUtil.iPhone15_2 { return .IPHONE_14_PRO }
        if hardware == _DeviceUtil.iPhone15_3 { return .IPHONE_14_PRO_MAX }
        if hardware == _DeviceUtil.iPhone2_1  { return .IPHONE_3GS }
        if hardware == _DeviceUtil.iPhone3_1  { return .IPHONE_4 }
        if hardware == _DeviceUtil.iPhone3_2  { return .IPHONE_4 }
        if hardware == _DeviceUtil.iPhone3_3  { return .IPHONE_4_CDMA }
        if hardware == _DeviceUtil.iPhone4_1  { return .IPHONE_4S }
        if hardware == _DeviceUtil.iPhone5_1  { return .IPHONE_5 }
        if hardware == _DeviceUtil.iPhone5_2  { return .IPHONE_5_CDMA_GSM }
        if hardware == _DeviceUtil.iPhone5_3  { return .IPHONE_5C }
        if hardware == _DeviceUtil.iPhone5_4  { return .IPHONE_5C_CDMA_GSM }
        if hardware == _DeviceUtil.iPhone6_1  { return .IPHONE_5S }
        if hardware == _DeviceUtil.iPhone6_2  { return .IPHONE_5S_CDMA_GSM }
        if hardware == _DeviceUtil.iPhone7_1  { return .IPHONE_6_PLUS }
        if hardware == _DeviceUtil.iPhone7_2  { return .IPHONE_6 }
        if hardware == _DeviceUtil.iPhone8_1  { return .IPHONE_6S }
        if hardware == _DeviceUtil.iPhone8_2  { return .IPHONE_6S_PLUS }
        if hardware == _DeviceUtil.iPhone8_4  { return .IPHONE_SE }
        if hardware == _DeviceUtil.iPhone9_1  { return .IPHONE_7 }
        if hardware == _DeviceUtil.iPhone9_2  { return .IPHONE_7_PLUS }
        if hardware == _DeviceUtil.iPhone9_3  { return .IPHONE_7_GSM }
        if hardware == _DeviceUtil.iPhone9_4  { return .IPHONE_7_PLUS_GSM }

        if hardware == _DeviceUtil.iPod1_1 { return .IPOD_TOUCH_1G }
        if hardware == _DeviceUtil.iPod2_1 { return .IPOD_TOUCH_2G }
        if hardware == _DeviceUtil.iPod3_1 { return .IPOD_TOUCH_3G }
        if hardware == _DeviceUtil.iPod4_1 { return .IPOD_TOUCH_4G }
        if hardware == _DeviceUtil.iPod5_1 { return .IPOD_TOUCH_5G }
        if hardware == _DeviceUtil.iPod7_1 { return .IPOD_TOUCH_6G }
        if hardware == _DeviceUtil.iPod9_1 { return .IPOD_TOUCH_7G }

        if hardware == _DeviceUtil.x86_64_Simulator { return .SIMULATOR }

        NSLog("This is a device which is not listed in this category. Please visit https://github.com/InderKumarRathore/DeviceUtil and add a comment there.")
        NSLog("Your device hardware string is: %@", hardware)
        return .UNKNOWN
    }

    // MARK: - Hardware Description

    @objc func hardwareDescription() -> String? {
        let hardware = hardwareString()
        if let description = deviceList[hardware]?["name"] {
            return description
        } else {
            logMessage(hardware)
            return nil
        }
    }

    @objc func hardwareSimpleDescription() -> String? {
        guard let hardwareDescription = hardwareDescription() else {
            return nil
        }
        do {
            // This expression matches all strings between round brackets (e.g (Wifi), (GSM))
            // except the pattern "[0-9]+ Gen"
            let regex = try NSRegularExpression(pattern: "\\((?![0-9]+ Gen).*\\)", options: .caseInsensitive)
            let result = regex.stringByReplacingMatches(in: hardwareDescription, options: [], range: NSRange(location: 0, length: hardwareDescription.count), withTemplate: "")
            return result
        } catch {
            return nil
        }
    }

    @objc func hardwareNumber() -> Float {
        let hardware = hardwareString()
        if let versionString = deviceList[hardware]?["version"], let version = Float(versionString), version != 0.0 {
            return version
        } else {
            logMessage(hardware)
            return 200.0 // device might be new one or missing one so returning 200.0
        }
    }

    // MARK: - Simulator Check

    @objc func isSimulator() -> Bool {
        return nativeHardware() == .SIMULATOR
    }

    // MARK: - Back Camera Resolution

    @objc func backCameraStillImageResolutionInPixels() -> CGSize {
        switch hardware() {
        case .IPHONE_2G,
             .IPHONE_3G:
            return CGSize(width: 1600, height: 1200)

        case .IPHONE_3GS:
            return CGSize(width: 2048, height: 1536)

        case .IPHONE_4,
             .IPHONE_4_CDMA,
             .IPAD_3_WIFI,
             .IPAD_3_WIFI_CDMA,
             .IPAD_3,
             .IPAD_4_WIFI,
             .IPAD_4,
             .IPAD_4_GSM_CDMA:
            return CGSize(width: 2592, height: 1936)

        case .IPHONE_4S,
             .IPHONE_5,
             .IPHONE_5_CDMA_GSM,
             .IPHONE_5C,
             .IPHONE_5C_CDMA_GSM,
             .IPHONE_6,
             .IPHONE_6_PLUS,
             .IPOD_TOUCH_6G,
             .IPAD_AIR_2_WIFI,
             .IPAD_AIR_2_WIFI_CELLULAR,
             .IPHONE_6S,
             .IPHONE_6S_PLUS,
             .IPAD_MINI_4_WIFI,
             .IPAD_MINI_4_WIFI_CELLULAR,
             .IPAD_MINI_5_WIFI,
             .IPAD_MINI_5_WIFI_CELLULAR,
             .IPAD_AIR_3_WIFI,
             .IPAD_AIR_3_WIFI_CELLULAR:
            return CGSize(width: 3264, height: 2448)

        case .IPHONE_7,
             .IPHONE_7_GSM,
             .IPHONE_7_PLUS,
             .IPHONE_7_PLUS_GSM,
             .IPHONE_8,
             .IPHONE_8_CN,
             .IPHONE_8_PLUS,
             .IPHONE_8_PLUS_CN,
             .IPHONE_X,
             .IPHONE_X_CN:
            return CGSize(width: 4032, height: 3024)

        case .IPOD_TOUCH_4G:
            return CGSize(width: 960, height: 720)

        case .IPOD_TOUCH_5G:
            return CGSize(width: 2440, height: 1605)

        case .IPAD_2_WIFI,
             .IPAD_2,
             .IPAD_2_CDMA:
            return CGSize(width: 872, height: 720)

        case .IPAD_MINI_WIFI,
             .IPAD_MINI,
             .IPAD_MINI_WIFI_CDMA:
            return CGSize(width: 1820, height: 1304)

        case .IPAD_PRO_97_WIFI,
             .IPAD_PRO_97_WIFI_CELLULAR:
            return CGSize(width: 4032, height: 3024)

        default:
            NSLog("We have no resolution for your device's camera listed in this category. Please, make photo with back camera of your device, get its resolution in pixels (via Preview Cmd+I for example) and add a comment to this repository (https://github.com/InderKumarRathore/DeviceUtil) on GitHub.com in format Device = Hpx x Wpx.")
            NSLog("Your device is: %@", hardwareDescription() ?? "Unknown")
            return CGSize.zero
        }
    }

    // MARK: - Private

    private func logMessage(_ hardware: String) {
        NSLog("This is a device which is not listed in this category. Please visit https://github.com/InderKumarRathore/DeviceUtil and add a comment there.")
        NSLog("Your device hardware string is: %@", hardware)
    }
}

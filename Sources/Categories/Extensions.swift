//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import Foundation
import UIKit
import ImageIO
import ObjectiveC

// MARK: - NSData (CocoaDebug)

@objc extension NSData {

    @objc static func dataWithInputStream(_ stream: InputStream?) -> Data? {
        guard let stream = stream else { return nil }

        let data = NSMutableData()
        stream.open()
        var buffer = [UInt8](repeating: 0, count: 1024)

        while true {
            let result = stream.read(&buffer, maxLength: 1024)
            if result > 0 {
                data.append(buffer, length: result)
            } else if result == 0 {
                break
            } else {
                // Stream error
                stream.close()
                return nil
            }
        }
        stream.close()
        return data as Data
    }

    @objc static func dataWithInputStream(_ stream: InputStream?, maxLength: UInt) -> Data? {
        guard let stream = stream else { return nil }

        let data = NSMutableData()
        stream.open()
        var buffer = [UInt8](repeating: 0, count: 1024)

        while true {
            let remaining = Int(maxLength) - data.length
            if remaining <= 0 { break }
            let toRead = Swift.min(1024, remaining)
            let result = stream.read(&buffer, maxLength: toRead)
            if result > 0 {
                data.append(buffer, length: result)
                if data.length >= Int(maxLength) {
                    break
                }
            } else if result == 0 {
                break
            } else {
                stream.close()
                return nil
            }
        }
        stream.close()
        return data as Data
    }
}

// MARK: - NSString (CocoaDebug)

@objc extension NSString {

    @objc func heightWithFont(_ font: UIFont?, constraintToWidth width: CGFloat) -> CGFloat {
        guard let font = font else { return 0 }
        let rect = (self as String).boundingRect(
            with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        return rect.size.height
    }
}

// MARK: - NSURLRequest (CocoaDebug)

private var requestIdKey: UInt8 = 0
private var startTimeKey: UInt8 = 0

@objc extension NSURLRequest {

    @objc var requestId: String? {
        get {
            return objc_getAssociatedObject(self, &requestIdKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &requestIdKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

    @objc var startTime: NSNumber? {
        get {
            return objc_getAssociatedObject(self, &startTimeKey) as? NSNumber
        }
        set {
            objc_setAssociatedObject(self, &startTimeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: - UIColor (CocoaDebug)

@objc extension UIColor {

    @objc static func colorFromHexString(_ hexString: String?) -> UIColor? {
        guard let hexString = hexString else { return nil }
        var rgbValue: UInt32 = 0
        let scanner = Scanner(string: hexString)
        scanner.scanLocation = 1
        scanner.scanHexInt32(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0xFF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
}

// MARK: - NSDictionary (CocoaDebug)

@objc extension NSDictionary {

    @objc func _stringForKey(_ key: NSCopying?) -> String? {
        guard let key = key else { return nil }
        let obj = object(forKey: key)
        if let str = obj as? String {
            return str
        }
        return nil
    }

    @objc func _arrayForKey(_ key: NSCopying?) -> NSArray? {
        guard let key = key else { return nil }
        let obj = object(forKey: key)
        if let arr = obj as? NSArray {
            return arr
        }
        return nil
    }

    @objc func _dictionaryForKey(_ key: NSCopying?) -> NSDictionary? {
        guard let key = key else { return nil }
        let obj = object(forKey: key)
        if let dict = obj as? NSDictionary {
            return dict
        }
        return nil
    }

    @objc func _integerForKey(_ key: NSCopying?) -> Int {
        guard let key = key else { return 0 }
        let obj = object(forKey: key)
        if let num = obj as? NSNumber {
            return num.intValue
        }
        if let str = obj as? NSString {
            return str.integerValue
        }
        return 0
    }

    @objc func _int64ForKey(_ key: NSCopying?) -> Int64 {
        guard let key = key else { return 0 }
        let obj = object(forKey: key)
        if let num = obj as? NSNumber {
            return num.int64Value
        }
        if let str = obj as? NSString {
            return str.longLongValue
        }
        return 0
    }

    @objc func _int32ForKey(_ key: NSCopying?) -> Int32 {
        guard let key = key else { return 0 }
        let obj = object(forKey: key)
        if let num = obj as? NSNumber {
            return num.int32Value
        }
        if let str = obj as? NSString {
            return str.intValue
        }
        return 0
    }

    @objc func _floatForKey(_ key: NSCopying?) -> Float {
        guard let key = key else { return 0 }
        let obj = object(forKey: key)
        if let num = obj as? NSNumber {
            return num.floatValue
        }
        if let str = obj as? NSString {
            return str.floatValue
        }
        return 0
    }

    @objc func _doubleForKey(_ key: NSCopying?) -> Double {
        guard let key = key else { return 0 }
        let obj = object(forKey: key)
        if let num = obj as? NSNumber {
            return num.doubleValue
        }
        if let str = obj as? NSString {
            return str.doubleValue
        }
        return 0
    }

    @objc func _boolForKey(_ key: NSCopying?) -> Bool {
        guard let key = key else { return false }
        let obj = object(forKey: key)
        if let num = obj as? NSNumber {
            return num.boolValue
        }
        if let str = obj as? NSString {
            return str.boolValue
        }
        return false
    }

    @objc(cd_stringForKey:default:)
    func _stringForKey(_ key: NSCopying?, default defaultValue: String?) -> String? {
        guard let key = key else { return defaultValue }
        let obj = object(forKey: key)
        if let str = obj as? String {
            return str
        }
        return defaultValue
    }

    @objc(cd_boolForKey:default:)
    func _boolForKey(_ key: NSCopying?, default defaultValue: Bool) -> Bool {
        guard let key = key else { return defaultValue }
        let obj = object(forKey: key)
        if obj is NSNumber || obj is NSString {
            return (obj as AnyObject).boolValue
        }
        return defaultValue
    }

    @objc(cd_integerForKey:default:)
    func _integerForKey(_ key: NSCopying?, default defaultValue: Int) -> Int {
        guard let key = key else { return defaultValue }
        let obj = object(forKey: key)
        if obj is NSNumber || obj is NSString {
            return (obj as AnyObject).integerValue
        }
        return defaultValue
    }

    @objc(cd_floatForKey:default:)
    func _floatForKey(_ key: NSCopying?, default defaultValue: Float) -> Float {
        guard let key = key else { return defaultValue }
        let obj = object(forKey: key)
        if obj is NSNumber || obj is NSString {
            return (obj as AnyObject).floatValue
        }
        return defaultValue
    }

    @objc(cd_arrayForKey:default:)
    func _arrayForKey(_ key: NSCopying?, default defaultValue: NSArray?) -> NSArray? {
        guard let key = key else { return defaultValue }
        let obj = object(forKey: key)
        if let arr = obj as? NSArray {
            return arr
        }
        return defaultValue
    }

    @objc(cd_dictionaryForKey:default:)
    func _dictionaryForKey(_ key: NSCopying?, default defaultValue: NSDictionary?) -> NSDictionary? {
        guard let key = key else { return defaultValue }
        let obj = object(forKey: key)
        if let dict = obj as? NSDictionary {
            return dict
        }
        return defaultValue
    }
}

// MARK: - UIImage (CocoaDebug)

@objc extension UIImage {

    /// Obtain the GIF image object according to the data data of a GIF image
    @objc static func imageWithGIFData(_ data: Data?) -> UIImage? {
        guard let data = data else { return nil }

        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let count = CGImageSourceGetCount(source)

        if count <= 1 {
            return UIImage(data: data)
        }

        var images = [UIImage]()
        var duration: TimeInterval = 0.0

        for i in 0..<count {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else { continue }

            let frameDuration = UIImage.ssz_frameDurationAtIndex(i, source: source)
            duration += Double(frameDuration)

            images.append(UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up))
        }

        if duration == 0 {
            duration = (1.0 / 10.0) * Double(count)
        }

        return UIImage.animatedImage(with: images, duration: duration)
    }

    /// Obtain the GIF image object according to the name of the local GIF image
    @objc static func imageWithGIFNamed(_ name: String?) -> UIImage? {
        guard let name = name else { return nil }
        let scale = Int(UIScreen.main.scale)
        return gifName(name, scale: scale)
    }

    /// Obtain the GIF image object according to the URL of a GIF image
    @objc static func imageWithGIFUrl(_ url: String?, gifImageBlock: ((UIImage?) -> Void)?) {
        guard let url = url, let gifUrl = URL(string: url) else { return }

        DispatchQueue.global().async {
            let gifData = try? Data(contentsOf: gifUrl)

            DispatchQueue.main.async {
                gifImageBlock?(UIImage.imageWithGIFData(gifData))
            }
        }
    }

    // MARK: - Private GIF Helpers

    private static func gifName(_ name: String, scale: Int) -> UIImage? {
        var scale = scale
        var imagePath = Bundle.main.path(forResource: "\(name)@\(scale)x", ofType: "gif")

        if imagePath == nil {
            if scale + 1 > 3 {
                scale -= 1
            } else {
                scale += 1
            }
            imagePath = Bundle.main.path(forResource: "\(name)@\(scale)x", ofType: "gif")
        }

        if let imagePath = imagePath {
            if let imageData = try? Data(contentsOf: URL(fileURLWithPath: imagePath)) {
                return UIImage.imageWithGIFData(imageData)
            }
        }

        // Try without scale suffix
        if let imagePath = Bundle.main.path(forResource: name, ofType: "gif") {
            if let imageData = try? Data(contentsOf: URL(fileURLWithPath: imagePath)) {
                return UIImage.imageWithGIFData(imageData)
            }
        }

        return UIImage(named: name)
    }

    private static func ssz_frameDurationAtIndex(_ index: Int, source: CGImageSource) -> Float {
        var frameDuration: Float = 0.1

        guard let cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) else {
            return frameDuration
        }

        let frameProperties = cfFrameProperties as NSDictionary
        let gifProperties = frameProperties[kCGImagePropertyGIFDictionary as String] as? NSDictionary

        if let delayTimeUnclamped = gifProperties?[kCGImagePropertyGIFUnclampedDelayTime as String] as? NSNumber {
            frameDuration = delayTimeUnclamped.floatValue
        } else if let delayTime = gifProperties?[kCGImagePropertyGIFDelayTime as String] as? NSNumber {
            frameDuration = delayTime.floatValue
        }

        // Many annoying ads specify a 0 duration to make an image flash as quickly as possible.
        // We follow Firefox's behavior and use a duration of 100 ms for any frames that specify
        // a duration of <= 10 ms.
        if frameDuration < 0.011 {
            frameDuration = 0.100
        }

        return frameDuration
    }
}

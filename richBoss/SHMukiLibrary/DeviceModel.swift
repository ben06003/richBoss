//
//  Device.swift
//  UIDevie
//
//  Created by smallHappy on 2017/9/15.
//  Copyright © 2017年 SmallHappy. All rights reserved.
//

import UIKit

class DeviceModel {
    
    // MARK: - UIDevice
    static var uuid: String {
        // device + app => Unique Device Identifier(設備唯一標識符)
        return UIDevice.current.identifierForVendor!.uuidString
    }
    
    static var systemName: String {
        // 作業系統名稱
        return UIDevice.current.systemName
    }
    
    static var systemVersion: String {
        // 作業系統版本
        return UIDevice.current.systemVersion
    }
    
    static var name: String {
        // 例如：某某某的iphone
        return UIDevice.current.name
    }
    
    static var orientation: String {
        switch UIDevice.current.orientation {
        case .faceUp:
            return "faceUp"
        case .faceDown:
            return "faceDown"
        case .landscapeLeft:
            return "landscapeLeft"
        case .landscapeRight:
            return "landscapeRight"
        case .portrait:
            return "portrait"
        case .portraitUpsideDown:
            return "portraitUpsideDown"
        case .unknown:
            return "unknown"
        }
    }
    
    static var userInterfaceIdiom: String {
        switch UIDevice.current.userInterfaceIdiom {
        case .mac:
            return "mac"
        case .phone:
            return "phone"
        case .pad:
            return "pad"
        case .tv:
            return "tv"
        case .carPlay:
            return "carPlay"
        case .unspecified:
            return "unspecified"
        default:
            return "unknown"
        }
    }
    
    static var model: String {
        return UIDevice.current.model
    }
    
    static var modelName: String {
        return UIDevice.current.modelName
    }
    
    static var multitaskingSupported: Bool {
        return UIDevice.current.isMultitaskingSupported
    }
    
    static var batteryState: String {
        UIDevice.current.isBatteryMonitoringEnabled = true
        if !UIDevice.current.isBatteryMonitoringEnabled {
            return "Battery monitoring is not Enabled."
        }
        switch UIDevice.current.batteryState {
        case .unknown:
            return "unknown"
        case .unplugged:
            return "unplugged"
        case .charging:
            return "charging"
        case .full:
            return "full"
        }
    }
    
    static var batteryLevel: Float {
        UIDevice.current.isBatteryMonitoringEnabled = true
        return UIDevice.current.batteryLevel
    }
    
    // MARK: - Bundle
    static var shortVersion: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    static var bundleVersion: String? {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
    
    static var displayName: String? {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
    }
    
    static var bundleIdentifier: String? {
        return Bundle.main.bundleIdentifier
    }
    
}

public extension UIDevice {
    
    /*
     參考資料：https://www.theiphonewiki.com/wiki/Models
     內容會變，請不時更新。
     */
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        // iPod
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        // iPhone
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1":                               return "iPhone 7 (CDMA)"
        case "iPhone9,3":                               return "iPhone 7 (GSM)"
        case "iPhone9,2":                               return "iPhone 7 Plus (CDMA)"
        case "iPhone9,4":                               return "iPhone 7 Plus (GSM)"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        // iPad
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro"
        // others
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}

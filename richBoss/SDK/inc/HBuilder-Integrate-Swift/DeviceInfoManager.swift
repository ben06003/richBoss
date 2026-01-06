//
//  DeviceInfoManager.swift
//  TestSwiftAndObjc
//
//  Created by 羅祐昌 on 2017/10/22.
//  Copyright © 2017年 muki. All rights reserved.
//

import UIKit
import Reachability
import CoreLocation

class DeviceInfoManager: NSObject, CLLocationManagerDelegate {
    
    private static let instance = DeviceInfoManager()
    static var shared: DeviceInfoManager {
        return self.instance
    }
    
    let locationManager = CLLocationManager()
    
    var boundary: String {
        return "Boundary-\(UIDevice.current.identifierForVendor!.uuidString)"
    }
    
    // MARK: - 取得版本
    var applicationVersion: String {
        return (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
    }
    
    var systemVersion: String {
        return UIDevice.current.systemVersion
    }
    
    // MARK: - 取得型號
    var specification: String {
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
    
    // MARK: - 是否網路連線
    var connectedToNetwork: Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    // MARK: - 啟動locationManager(取得經緯度)
    func setCoreLocation() {
        guard haveGPSLocation else { return }
        if !CLLocationManager.locationServicesEnabled() { return }
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = kCLDistanceFilterNone // 觸發更新資訊的最小距離
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.first?.coordinate else { return }
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        UserDefaults.standard.set(latitude, forKey: udk_latitude)
        UserDefaults.standard.set(longitude, forKey: udk_longitude)
    }
    
    func getJsonObject(url: URL, bodyDic: NSDictionary, sec:Double = 20, finish: ((_ object:Any?) -> Void)? = nil) {
        var body: Data?
        for model in bodyDic {
            let key = model.key as? String
            let value = model.value as? String
            body?.appendPOSTParameter(name: key, value: value)
        }
        body?.appendEndingBoundary()
        var request: URLRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: sec)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=" + self.boundary, forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        request.httpShouldHandleCookies = false
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
            if error != nil {
                print("post nil error: \(error!.localizedDescription)")
                finish?(nil)
                return
            }
            do{
                finish?(try JSONSerialization.jsonObject(with: data!, options: .mutableContainers))
            }catch let error as NSError {
                print("post catch error: \(error.description)")
                finish?(nil)
            }
        })
        task.resume()
    }
    
}

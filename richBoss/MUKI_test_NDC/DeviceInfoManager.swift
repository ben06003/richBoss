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
var GpsBackName:String?

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
    var applicationShortVersion: String {
        return (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
    }
    
    var applicationVersion: String {
        return (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? ""
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
        case "iPod5,1":                                       return "iPod touch (5th generation)"
        case "iPod7,1":                                       return "iPod touch (6th generation)"
        case "iPod9,1":                                       return "iPod touch (7th generation)"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":           return "iPhone 4"
        case "iPhone4,1":                                     return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                        return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                        return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                        return "iPhone 5s"
        case "iPhone7,2":                                     return "iPhone 6"
        case "iPhone7,1":                                     return "iPhone 6 Plus"
        case "iPhone8,1":                                     return "iPhone 6s"
        case "iPhone8,2":                                     return "iPhone 6s Plus"
        case "iPhone8,4":                                     return "iPhone SE"
        case "iPhone9,1", "iPhone9,3":                        return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                        return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4":                      return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                      return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                      return "iPhone X"
        case "iPhone11,2":                                    return "iPhone XS"
        case "iPhone11,4", "iPhone11,6":                      return "iPhone XS Max"
        case "iPhone11,8":                                    return "iPhone XR"
        case "iPhone12,1":                                    return "iPhone 11"
        case "iPhone12,3":                                    return "iPhone 11 Pro"
        case "iPhone12,5":                                    return "iPhone 11 Pro Max"
        case "iPhone12,8":                                    return "iPhone SE (2nd generation)"
        case "iPhone13,1":                                    return "iPhone 12 mini"
        case "iPhone13,2":                                    return "iPhone 12"
        case "iPhone13,3":                                    return "iPhone 12 Pro"
        case "iPhone13,4":                                    return "iPhone 12 Pro Max"
        case "iPhone14,4":                                    return "iPhone 13 mini"
        case "iPhone14,5":                                    return "iPhone 13"
        case "iPhone14,2":                                    return "iPhone 13 Pro"
        case "iPhone14,3":                                    return "iPhone 13 Pro Max"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":      return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":                 return "iPad (3rd generation)"
        case "iPad3,4", "iPad3,5", "iPad3,6":                 return "iPad (4th generation)"
        case "iPad6,11", "iPad6,12":                          return "iPad (5th generation)"
        case "iPad7,5", "iPad7,6":                            return "iPad (6th generation)"
        case "iPad7,11", "iPad7,12":                          return "iPad (7th generation)"
        case "iPad11,6", "iPad11,7":                          return "iPad (8th generation)"
        case "iPad12,1", "iPad12,2":                          return "iPad (9th generation)"
        case "iPad4,1", "iPad4,2", "iPad4,3":                 return "iPad Air"
        case "iPad5,3", "iPad5,4":                            return "iPad Air 2"
        case "iPad11,3", "iPad11,4":                          return "iPad Air (3rd generation)"
        case "iPad13,1", "iPad13,2":                          return "iPad Air (4th generation)"
        case "iPad2,5", "iPad2,6", "iPad2,7":                 return "iPad mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":                 return "iPad mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":                 return "iPad mini 3"
        case "iPad5,1", "iPad5,2":                            return "iPad mini 4"
        case "iPad11,1", "iPad11,2":                          return "iPad mini (5th generation)"
        case "iPad14,1", "iPad14,2":                          return "iPad mini (6th generation)"
        case "iPad6,3", "iPad6,4":                            return "iPad Pro (9.7-inch)"
        case "iPad7,3", "iPad7,4":                            return "iPad Pro (10.5-inch)"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":      return "iPad Pro (11-inch) (1st generation)"
        case "iPad8,9", "iPad8,10":                           return "iPad Pro (11-inch) (2nd generation)"
        case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":  return "iPad Pro (11-inch) (3rd generation)"
        case "iPad6,7", "iPad6,8":                            return "iPad Pro (12.9-inch) (1st generation)"
        case "iPad7,1", "iPad7,2":                            return "iPad Pro (12.9-inch) (2nd generation)"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":      return "iPad Pro (12.9-inch) (3rd generation)"
        case "iPad8,11", "iPad8,12":                          return "iPad Pro (12.9-inch) (4th generation)"
        case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":return "iPad Pro (12.9-inch) (5th generation)"
        case "AppleTV5,3":                                    return "Apple TV"
        case "AppleTV6,2":                                    return "Apple TV 4K"
        case "AudioAccessory1,1":                             return "HomePod"
        case "AudioAccessory5,1":                             return "HomePod mini"
        case "i386", "x86_64", "arm64":                       return "Simulator"
        default:                                              return identifier
        }
    }
    
    // MARK: - 是否網路連線
    var connectedToNetwork: Bool {
        var reachability: Reachability!
        // 網路偵測
        do {
            reachability = try Reachability()
            print("reachability:\( reachability.connection )")
            switch reachability.connection {
                case .wifi:
                    return true
                case .cellular:
                    return true
                case .none:
                    return false
                case .unavailable:
                    return false
            }
        } catch {
            return false
        }
    }
    
    // MARK: - 啟動locationManager(取得經緯度)
    func setCoreLocation() {
        guard haveGPSLocation else { return }
        if !CLLocationManager.locationServicesEnabled() { return }
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = kCLDistanceFilterNone // 觸發更新資訊的最小距離
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.allowsBackgroundLocationUpdates = false // 開啟背景更新(預設為 false)
        self.locationManager.pausesLocationUpdatesAutomatically = false // 不間斷的在背景更新(預設為 true)
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
extension DeviceInfoManager {
    // 定位距離增查
    func openopenGPSRecording(_cbId:String,_lat:Double,_lng:Double,_type:Int) {
        var key:Bool = true
        if _type == 0{
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }else{
            self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        }
        UserDefaults.standard.set("", forKey: "endTime")
        UserDefaults.standard.set("", forKey: "end_latitude")
        UserDefaults.standard.set("", forKey: "end_longitude")
        DispatchQueue.global().async {
            while key {
                let s = self.getDistance(lat1: Double(UserDefaults.standard.string(forKey: udk_latitude)!)!, lng1: Double(UserDefaults.standard.string(forKey: udk_longitude)!)!, lat2: _lat, lng2: _lng)
                print("\(Date()):\(s)")
                if s <= 0.1 {
                    key = false
                }
                sleep(1)
            }
            let now:Date = Date()
            // 建立時間格式
            let dateFormat:DateFormatter = DateFormatter()
            dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
            // 將當下時間轉換成設定的時間格式
            let dateString:String = dateFormat.string(from: now)
            UserDefaults.standard.set(dateString, forKey: "endTime")
            UserDefaults.standard.set(UserDefaults.standard.string(forKey: udk_latitude), forKey: "end_latitude")
            UserDefaults.standard.set(UserDefaults.standard.string(forKey: udk_longitude), forKey: "end_longitude")
            let endTime = UserDefaults.standard.string(forKey: "endTime") ?? ""
            let end_latitude = UserDefaults.standard.string(forKey: "end_latitude") ?? ""
            let end_longitude = UserDefaults.standard.string(forKey: "end_longitude") ?? ""
            let result = ["end_latitude":end_latitude,"end_longitude":end_longitude,"endTime":endTime]
            let _jsonData = try? JSONSerialization.data(withJSONObject: result, options: [])
            let _jsonString:String = String(data: _jsonData!, encoding: .utf8)!
            var userInfo: [String:Any] = [:]
            userInfo["_jsonString"] = _jsonString
            userInfo["call_back"] = _cbId
            let notification = Notification(name: evaluateJavaScriptNotification, object: nil, userInfo: userInfo)
            NotificationCenter.default.post(notification)
        }
    }
    
    //根據角度計算弧度
    func radian(d:Double) -> Double {
        return d * Double.pi/180.0
    }
    //根據弧度計算角度
    func angle(r:Double) -> Double {
        return r * 180/Double.pi
    }
    //根據兩點經緯度計算兩點距離
    func getDistance(lat1:Double,lng1:Double,lat2:Double,lng2:Double) -> Double {
        let EARTH_RADIUS:Double = 6378.1370
        let radLat1:Double = self.radian(d: lat1)
        let radLat2:Double = self.radian(d: lat2)
        
        let radLng1:Double = self.radian(d: lng1)
        let radLng2:Double = self.radian(d: lng2)
        
        let a:Double = radLat1 - radLat2
        let b:Double = radLng1 - radLng2
        
        var s:Double = 2 * asin(sqrt(pow(sin(a/2), 2) + cos(radLat1) * cos(radLat2) * pow(sin(b/2), 2)))
        s = s * EARTH_RADIUS
        return s
    }

}

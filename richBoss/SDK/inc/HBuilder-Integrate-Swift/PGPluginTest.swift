//
//  PGPluginTest.swift
//  HBuilder-Integrate-Swift
//
//  Created by EICAPITAN on 17/5/18.
//  Copyright © 2017年 EICAPITAN. All rights reserved.
//

import Foundation
import LocalAuthentication
import MapKit
import FacebookLogin

@objc(PGPluginTest)
class PGPluginTest: PGPlugin {
    
    // 外部連結通知
    func shouldStartLoadWith(_ commands: PGMethod?) {
        guard let path = commands?.arguments.component(1) as? String else { return }
        guard let flag = commands?.arguments.component(2) as? String else { return }
        print("isBlank:", flag == "_blank" ? true : false)
        print("path:", path)
        if flag == "_blank" ? true : false {
            let userInfo = [_path: path]
            let notification = Notification(name: shouldStartLoadNotification, object: nil, userInfo: userInfo)
            NotificationCenter.default.post(notification)
        }
    }
    
    // openURL
    func openUrlByBrowser(_ commands: PGMethod?) {
        guard let path = commands?.arguments.component(1) as? String else { return }
        guard let url = URL(string: path) else { return }
        print("path:", url.path)
        DispatchQueue.main.async {
            UIApplication.shared.open(url: url)
        }
    }
    
    // webView operation
    func paging(_ commands: PGMethod?) {
        guard let path = commands?.arguments.component(1) as? String else { return }
        guard let name = commands?.arguments.component(2) as? String else { return }
        guard let style = commands?.arguments.component(3) as? String, let viewStyle = PagingStyle(rawValue: style) else { return }
        guard let property = commands?.arguments.component(4) as? String, let viewProperty = WebViewProperty(rawValue: property) else { return }
        guard let refresh_time = commands?.arguments.component(5) as? Double else { return }
        guard let isHidden = commands?.arguments.component(6), let isTabBarHidden = JsonManager.sharedInstance.toBool(isHidden) else { return }
        let userInfo: [String: Any] = [_path: path, _view_name: name, _view_style: viewStyle, _view_property: viewProperty, _view_refresh_time: refresh_time, _view_isTabBarHidden: isTabBarHidden]
        let notification = Notification(name: pagingNotification, object: nil, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
    
    func startLoading(_ commands: PGMethod?) {
        let notification = Notification(name: startLoadingNotification, object: nil, userInfo: nil)
        NotificationCenter.default.post(notification)
    }
    
    func stopLoading(_ commands: PGMethod?) {
        let notification = Notification(name: stopLoadingNotification, object: nil, userInfo: nil)
        NotificationCenter.default.post(notification)
    }
    
    // 下載，並開啟檔案。
    func openFile(_ commands: PGMethod?) {
        guard let path = commands?.arguments.component(1) as? String else { return }
        guard let server_url = URL(string: path) else { return }
        let fileName = server_url.lastPathComponent
        let device_url = FileHandler.shared.path(folder: .files).appendingPathComponent(fileName)
        let userInfo: [String: Any]  = [_server_url: server_url, _device_url: device_url]
        let notification = Notification(name: openFileNotification, object: nil, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
    
    func getDownloadList(_ commands: PGMethod?) {
        print(commands)
    }
    
    func deleteSingleFile(_ commands: PGMethod?) {
        print(commands)
    }
    
    func deleteAllFiles(_ commands: PGMethod?) {
        print(commands)
    }
    
    func getFilesSize(_ commands: PGMethod?) -> Data {
        return Data()
    }
    
    // facebook 登入
    var loginManager: LoginManager?
    
    func loginViaFB(_ commands: PGMethod?) -> Data {
        if self.loginManager == nil {
            self.loginManager = LoginManager()
        }
        DispatchQueue.main.async {
            self.startLoading(nil)
            guard let vc = UIApplication.shared.delegate?.window??.rootViewController as? WebViewController else { return }
            self.loginManager?.logIn(readPermissions: [.publicProfile, .email], viewController: vc) {
                
                switch $0 {
                case  .failed(let error):
                    print(error)
                case .cancelled:
                    print("使用者取消登入")
                case .success(grantedPermissions: _, declinedPermissions: _, token: _):
                    print("使用者成功登入")
                    //                self.fetchProfile()
                }
            }
        }
        
        
//        if let latitude = UserDefaults.standard.string(forKey: udk_latitude), let longitude = UserDefaults.standard.string(forKey: udk_longitude) {
//            let jsonDictionary = [udk_latitude: latitude, udk_longitude: longitude]
//            return self.result(withJSON: jsonDictionary)
//        } else {
//            return self.result(withJSON: [:])
//        }
        return Data()
    }
    
    // facebook 分享
    func shareByFacebook(_ commands: PGMethod?) {
        guard let path = commands?.arguments.component(1) as? String else { return }
        let userInfo = [_path: path]
        let notification = Notification(name: facebookShareNotification, object: nil, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
    
    // line 分享
    func shareByLine(_ commands: PGMethod?) {
        guard let context = commands?.arguments.component(1) as? String else { return }
        guard !context.isEmpty else { return }
        guard let url = URL(string: "line://msg/text/" + context) else { return }
        guard let appstore = URL(string: "itms-apps://itunes.apple.com/app/id443904275") else { return }
        if UIApplication.shared.canOpenURL(URL(string: "line://")!) {
            UIApplication.shared.open(url: url)
        } else  {
            UIApplication.shared.open(url: appstore)
        }
    }
    
    // 重置webView之url
    func setProjectUrl(_ commands: PGMethod?) {
        // 改以api來判斷，這個方法目前棄而不用！
//        guard let path = commands?.arguments.component(1) as? String else { return }
//        guard let is_set = commands?.arguments.component(2) as? Int else { return }
//        guard URL(string: path) != nil else { return }
//        UserDefaults.standard.set(path, forKey: udk_baseUrl)
//        UserDefaults.standard.set(is_set, forKey: udk_isSet)
//        if let isSet = IsSet(rawValue: is_set), isSet == .settle {
//            let notification = Notification(name: resetBaseUrl)
//            NotificationCenter.default.post(notification)
//        }
    }
    
    // app資訊
    func getAppInfo(_ commands: PGMethod?) -> Data {
        let token = UserDefaults.standard.string(forKey: udk_token) ?? ""
        let os_version = DeviceInfoManager.shared.systemVersion
        let application_version = DeviceInfoManager.shared.applicationVersion
        let device = DeviceInfoManager.shared.specification
        let jsonDictionary = [_token: token, _os_version: os_version, _application_version: application_version, _device: device]
        return self.result(withJSON: jsonDictionary)
    }
    
    // 經緯度
    func getCoordinate(_ commands: PGMethod?) -> Data {
        if let latitude = UserDefaults.standard.string(forKey: udk_latitude), let longitude = UserDefaults.standard.string(forKey: udk_longitude) {
            let jsonDictionary = [udk_latitude: latitude, udk_longitude: longitude]
            return self.result(withJSON: jsonDictionary)
        } else {
            return self.result(withJSON: [:])
        }
    }
    
    // 導航
    func openCoordinateByMap(_ commands: PGMethod?) {
        guard let _start_latitude = UserDefaults.standard.string(forKey: udk_latitude), let start_latitude = CLLocationDegrees(_start_latitude) else { return }
        guard let _start_longitude = UserDefaults.standard.string(forKey: udk_longitude), let start_longitude = CLLocationDegrees(_start_longitude) else { return }
        let start_placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: start_latitude, longitude: start_longitude))
        let start = MKMapItem(placemark: start_placemark)
        start.name = "我的位置"
        guard let end_latitude = ClientManager.shared.toDouble(commands?.arguments.component(1)) else { return }
        guard let end_longitude = ClientManager.shared.toDouble(commands?.arguments.component(2)) else { return }
        let end_placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: end_latitude, longitude: end_longitude))
        let end = MKMapItem(placemark: end_placemark)
        end.name = "目的地"
        let mapItems = [start, end]
        let options = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving as AnyObject, // 導航模式：開車
            MKLaunchOptionsMapTypeKey: MKMapType.standard.rawValue as AnyObject, // 地圖樣式：標準
            MKLaunchOptionsShowsTrafficKey: true as AnyObject // 顯示交通：是
        ]
        MKMapItem.openMaps(with: mapItems, launchOptions: options)
    }
    
    // 判斷權限
    enum PrivacyType: Int {
        case geo = 1
    }
    
    func checkAuthorization(_ commands: PGMethod?) {
        guard let topic = commands?.arguments.component(1) as? String else { return }
        guard let _type = commands?.arguments.component(2) as? String, let type = Int(_type), let privacy = PrivacyType(rawValue: type) else { return }
        switch privacy {
        case .geo:
            self.checkGeoAuthorization(topic: topic)
        }
    }
    
    private func checkGeoAuthorization(topic: String) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            break
        case .denied, .notDetermined, .restricted:
            let userInfo = [_context: topic]
            let notification = Notification(name: checkGeoAuthorizationNotification, object: nil, userInfo: userInfo)
            NotificationCenter.default.post(notification)
        }
    }
    
}

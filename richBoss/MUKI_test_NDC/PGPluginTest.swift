//
//  PGPluginTest.swift
//  MUKI_test_NDC
//
//  Created by EICAPITAN on 17/5/18.
//  Copyright © 2017年 EICAPITAN. All rights reserved.
//

import Foundation
import LocalAuthentication
import MapKit
import FacebookLogin
import FacebookCore
import FBSDKLoginKit
import LineSDK


//@objc(PGPluginTest)
class PGPluginTest:Transform {
    // LINE 登入
    @objc func loginViaLINE(notification: Notification){
        print(notification)
//        let _cbId:String = commands?.arguments.component(0) as! String
        LoginManager.shared.login(permissions: [.profile], in: WebViewController()._vc) {
            result in
            switch result {
            case .success(let loginResult):
                if let profile = loginResult.userProfile {
//                    print(profile)
//                    print("User ID: \(profile.userID)")
//                    print("User Display Name: \(profile.displayName)")
//                    print("User Icon: \(String(describing: profile.pictureURL))")
                    var _userInfo:[String:String] = [String:String]()
                    _userInfo["name"] = profile.displayName
                    _userInfo["email"] = ""
                    _userInfo["id"] = profile.userID
                    _userInfo["picture"] = String(describing: profile.pictureURL)
//                    print(_userInfo["picture"])
                    let _jsonData = try? JSONSerialization.data(withJSONObject: _userInfo, options: [])
                    let _jsonString:String = String(data: _jsonData!, encoding: .utf8)!
                    let _result:PDRPluginResult = PDRPluginResult(status: PDRCommandStatusOK, messageAs: _jsonString)
//                    self.toCallback(_cbId, withReslut: _result.toJSONString())
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //Qrcode掃描
    @objc func openScan(_ commands: PGMethod?) {
        print("--- openScan ---")
        let _cbId:String = commands?.arguments.component(0) as! String
        let _data:NSDictionary = commands?.arguments.component(1) as! NSDictionary
        let _qrcodeVC:QRCodeVC = QRCodeVC()
        _qrcodeVC.create(_imgURL: (_data["img_url"] as! String), _msgStr: (_data["topic"] as! String))
        _qrcodeVC.fromCamera(_completeFunc: { _str in
            print("openScan complete")
            print(_str)
            
            var _userInfo:[String:String] = [String:String]()
            _userInfo["topic"] = ""
            _userInfo["img_url"] = _str
            
            let _jsonData = try? JSONSerialization.data(withJSONObject: _userInfo, options: [])
            let _jsonString:String = String(data: _jsonData!, encoding: .utf8)!
            let _result:PDRPluginResult = PDRPluginResult(status: PDRCommandStatusOK, messageAs: _str)
//            self.toCallback(_cbId, withReslut: _result.toJSONString())
        })
    }
    
    // alert
    func alert_title(message :String?) {
        // 建立一個提示框
        let alertController = UIAlertController(title: "提示",message: message,preferredStyle: .alert)
        // 建立[確認]按鈕
        let okAction = UIAlertAction(title: "確認",style: .default,handler: {(action: UIAlertAction!) -> Void in
                print("按下確認後，閉包裡的動作")
                // 用於轉址失敗關閉ＡＰＰ
                exit(0)
        })
        alertController.addAction(okAction)
        // 顯示提示框
//        self.present(alertController,animated: true,completion: nil)
    }

    //依POST 網址進行首頁設定
    func goTestSite(_ commands: PGMethod?) {
        guard let project_code = commands?.arguments.component(0) as? String else { return }
        let value = "{\"project_code\":\"\(project_code)\"}"
        postFormData = ["json_data":value]
        APIManager().requestWithFormData(urlString: basePostURL, parameters: postFormData!, completion: { (data) in
            DispatchQueue.main.async {
                self.startLoading(nil)
                self.processData(data: data)
            }
        })
    }

    func processData(data: Data){
        let fetchedDictionary = data.parseData()
        if fetchedDictionary["res_code"]as! Int == 0 {
            if postNum < 5{
                postNum += 1
                sleep(1)
                APIManager().requestWithFormData(urlString: basePostURL, parameters: postFormData!, completion: { (data) in
                    DispatchQueue.main.async {
                        self.processData(data: data)
                    }
                })
            }else{
                self.stopLoading(nil)
                self.alert_title(message: "連線異常，請重新啟動APP")
                return
            }
        }
        guard let dataDic_res_data = fetchedDictionary["res_data"] as? NSDictionary else {return}
        iVender_url_link = dataDic_res_data["project_url"] as? String
        let app = WebViewController()
        let rootVC = UIApplication.shared.delegate?.window??.rootViewController
        self.stopLoading(nil)
        rootVC?.present(app, animated: true, completion: nil)
    }
    
    //Icon數字設定
    func setBadgeNum(_ commands: PGMethod?) {
        guard let badgeNum = commands?.arguments.component(1) as? Int else { return }
        UIApplication.shared.applicationIconBadgeNumber = badgeNum
    }
    
    //原生碼Alert
    //var content = '訊息文字';
    //var position = '位置 center(中間) bottom(下方)';
    //var show_time_type = '顯示時間 short(短), long(長)';
    @objc func alertToast(_ commands: PGMethod?) {
        print("--- alertToast ---")
        guard let _content = commands?.arguments.component(1) as? String else { return }
        guard let _position = commands?.arguments.component(2) as? String else { return }
        guard let _showTime = commands?.arguments.component(3) as? String else { return }
        //print(_content, _position, _showTime)
        let userInfo: [String: Any] = ["content": _content, "position": _position, "showTime": _showTime]
        let notification = Notification(name: alertToastNotification, object: nil, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
    
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
        if DeviceModel.bundleIdentifier == "com.muki.oma" {
            guard let commands = commands else { return }
            guard commands.arguments.count >= 2 else { return }
            guard let path = commands.arguments[1] as? String else { return }
            let userInfo = [_path: path]
            let notification = Notification(name: facebookShareNotification, object: nil, userInfo: userInfo)
            NotificationCenter.default.post(notification)
            return
        }
        guard let path = commands?.arguments.component(1) as? String else { return }
        print(path)
        guard let url = URL(string: path) else { return }
        print("path:", url.path)
        DispatchQueue.main.async {
            UIApplication.shared.open(url: url)
        }
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
    @objc func openFile(_ commands: PGMethod?) {
        print("--- openFile ---")
        guard let path = commands?.arguments.component(1) as? String else { return }
        guard let server_url = URL(string: path) else { return }
        let fileName = server_url.lastPathComponent
        let device_url = FileHandler.shared.path(folder: .files).appendingPathComponent(fileName)
        let userInfo: [String: Any]  = [_server_url: server_url, _device_url: device_url]
        let notification = Notification(name: openFileNotification, object: nil, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
    
    // 下載，並開啟檔案20180110。
    @objc func downloadFile(_ commands: PGMethod?) {
        print("--- downloadFileFile ---")
        guard let path = commands?.arguments.component(1) as? String else { return }
        guard let server_url = URL(string: path) else { return }
        let fileName = server_url.lastPathComponent
        let device_url = FileHandler.shared.path(folder: .files).appendingPathComponent(fileName)
        let userInfo: [String: Any]  = [_server_url: server_url, _device_url: device_url]
        let notification = Notification(name: downloadFileNotification, object: nil, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
    
//    @objc func isFile(_ commands: PGMethod?) -> Data {
//        print("--- isFile ---")
//        guard let fileName = commands?.arguments.component(1) as? String else { return self.resultWithNull() }
//        let device_url = FileHandler.shared.path(folder: .files).appendingPathComponent(fileName)
//        let isFileExist = FileManager.default.fileExists(atPath: device_url.path)
//        let isFileExistStr:String = (isFileExist == true) ? "True" : "False"
//        let jsonDictionary = [_isFileExist: isFileExistStr]
        //print(jsonDictionary)
//        return self.result(withJSON: jsonDictionary)
//    }
    
    @objc func getDownloadList(_ commands: PGMethod?) {
        print("--- getDownloadList ---")
        let _appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let _webViewController:WebViewController = _appDelegate.window?.rootViewController?.childViewControllers[0] as! WebViewController
        let _downloadVC:DownloadVC = DownloadVC(frame: CGRect(x: 0, y: 0, width: _webViewController.view.frame.width, height: _webViewController.view.frame.height))
        _downloadVC.center = _webViewController.view.center
        _webViewController.view.addSubview(_downloadVC)
        guard let jsonString = commands?.arguments.component(1) as? String else { return }
        guard let jsonData = jsonString.data(using: .utf8) else { return }
        guard let jsonObject =  self.toJson(data: jsonData) else { return }
        let array = self.toArray(jsonObject)
        let files = array.map({ self.toArray($0).component(0) as? String }).compactMap({ $0 })
        FileHandler.shared.downloadFiles(files: files, _downloadVC: _downloadVC)
        SHPrint("🔗files🔗", files)
    }
    
    @objc func deleteSingleFile(_ commands: PGMethod?) {
        guard let fileName = commands?.arguments.component(1) as? String else { return }
        let url = FileHandler.shared.path(folder: .files).appendingPathComponent(fileName)
        FileHandler.shared.deleteFile(path: url)
    }
    
    @objc func deleteAllFiles(_ commands: PGMethod?) {
        print("--- deleteAllFiles ---")
        let url = FileHandler.shared.path(folder: .files)
        FileHandler.shared.deleteFile(path: url)
        FileHandler.shared.createFolder(url: url)
    }
    
    @objc func getFilesSize(_ commands: PGMethod?){
        print("--- getFilesSize ---")
        //print(commands?.arguments)
        var totalSize = 0.0
        // 計算已下載檔案之容量
        let url = FileHandler.shared.path(folder: .files)
        if let contents = try? FileManager.default.contentsOfDirectory(atPath: url.path) {
            var folderSize: UInt64 = 0
            contents.forEach {
                guard !$0.isEmpty else { return }
                guard let size = FileHandler.shared.getFileSize(path: url.appendingPathComponent($0).path) else { return }
                folderSize += size
            }
            totalSize = Double(folderSize) / pow(10, 6) // byte轉MB
            totalSize = round(totalSize * 100) / 100 // 四捨五入到小數第二位
        }
        // 計算裝置之總容量
        var deviceSize = 0.0
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: documentDirectoryPath.last!) {
            #if DEBUG
            // systemAttributes の値を全て出力
            for value in systemAttributes {
                print(value)
            }
            #endif
            if let freeSize = systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber {
                deviceSize = freeSize.doubleValue / pow(10, 6) // byte轉MB
                deviceSize = round(deviceSize * 100) / 100 // 四捨五入到小數第二位
            }
        }
        // 回傳結果
        let jsonDictionary = ["TotalFileSize": (totalSize as NSNumber).stringValue, "TotalInternalMemorySize": (deviceSize as NSNumber).stringValue]
        SHPrint("🐌🐌🐌", jsonDictionary)
//        return self.result(withJSON: jsonDictionary)
    }
    
    // facebook 登入
//    var loginManager: LoginManager?
    @objc func loginViaFB(_ commands: PGMethod?){
//        if self.loginManager == nil {
//            self.loginManager = LoginManager()
//        }
        let _cbId:String = commands?.arguments.component(0) as! String
        DispatchQueue.main.async {
//            self.startLoading(nil)
            let vc = UIApplication.shared.delegate?.window??.rootViewController
            LoginManager().logIn(readPermissions: [.publicProfile, .email], viewController: vc){ (loginResult) in
                switch loginResult{
                case .failed(let error):
                    print(error)
                    self.stopLoading(nil)
                case .cancelled:
                    print("使用者取消登入")
                    self.stopLoading(nil)
                case .success(grantedPermissions: _, declinedPermissions: _, token: _):
                    print("使用者成功登入")
                    self.getDetails(_cbId: _cbId)
                }
            }
        }
    }
    
    func getDetails(_cbId: String){
        guard let _ = AccessToken.current else{
            self.stopLoading(nil)
            return
        }
        let param = ["fields":"name,email,gender,id, picture"]
        var picURL:String?
        let graphRequest = GraphRequest(graphPath: "me",parameters: param)
        graphRequest.start { (urlResponse, requestResult) in
            switch requestResult{
            case .failed(let error):
                print(error)
                self.stopLoading(nil)
            case .success(response: let graphResponse):
                if let responseDictionary = graphResponse.dictionaryValue{
                    let name = responseDictionary["name"] as! String
                    let email = responseDictionary["email"] as! String
                    let id = responseDictionary["id"] as! String
                
                    if let photo = responseDictionary["picture"] as? NSDictionary{
                        let data = photo["data"] as! NSDictionary
                        picURL = data["url"] as! String
//                        let imgData = NSData(contentsOf: URL(string: picURL)!)
//                        userImage = UIImage(data: imgData! as Data)
                    }
                    
                    var _userInfo:[String:String] = [String:String]()
                    _userInfo["name"] = name
                    _userInfo["email"] = email
                    _userInfo["id"] = id
                    _userInfo["picture"] = picURL
                    print(_userInfo["picture"])
                    
                    let _jsonData = try? JSONSerialization.data(withJSONObject: _userInfo, options: [])
                    let _jsonString:String = String(data: _jsonData!, encoding: .utf8)!
                    let _result:PDRPluginResult = PDRPluginResult(status: PDRCommandStatusOK, messageAs: _jsonString)
//                    self.toCallback(_cbId, withReslut: _result.toJSONString())
                    self.stopLoading(nil)
                }
            }
        }
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
    
    // link 內建分享
    @objc func openShare(_ commands: PGMethod?) {
        guard let context = commands?.arguments.component(1) as? String else { return }
        let activityConterller = UIActivityViewController(activityItems: [context], applicationActivities: [])
//        present(activityConterller, animated: true, completion: nil)
     }
    
    // app資訊
    func getAppInfo(_ commands: PGMethod?) {
        let token = UserDefaults.standard.string(forKey: udk_token) ?? ""
        let os_version = DeviceInfoManager.shared.systemVersion
        let application_version = DeviceInfoManager.shared.applicationVersion
        let device = DeviceInfoManager.shared.specification
        let jsonDictionary = [_token: token, _os_version: os_version, _application_version: application_version, _device: device]
        print(jsonDictionary)
        print("----------------------getAppInfo------------------------------------")
        
//        return self.result(withJSON: jsonDictionary)
    }
    
    // 經緯度
    func getCoordinate(_ commands: PGMethod?) {
        if let latitude = UserDefaults.standard.string(forKey: udk_latitude), let longitude = UserDefaults.standard.string(forKey: udk_longitude) {
            let jsonDictionary = [udk_latitude: latitude, udk_longitude: longitude]
//            return self.result(withJSON: jsonDictionary)
        } else {
//            return self.result(withJSON: [:])
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


// HTTP請求使用需有APIManager.swift這隻檔案
extension Data{
    func parseData() -> NSDictionary{
        var dataDict = try? JSONSerialization.jsonObject(with: self, options: .mutableContainers) as! NSDictionary
        if dataDict == nil {
            dataDict = ["res_code" : 0]
        }
        return dataDict!
    }
    
    mutating func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

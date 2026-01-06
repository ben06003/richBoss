//
//  PGPluginTest.swift
//  MUKI_iVender
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


class JSPlugin: NSObject {
    var webviewC:WebViewController!
    
    func tranjson(str:String)->String {
        var json = str
        json = json.replacingOccurrences(of: "\r", with: "")
        json = json.replacingOccurrences(of: "\n", with: "")
        json = json.trimmingCharacters(in: .whitespaces)
        json = json.replacingOccurrences(of: " ", with: "")
        return json
    }
    
    // Swift呼叫JS
    @objc func evaluateJavaScript(notification: Notification){
        guard let call_back = notification.userInfo?["call_back"] as? String else { return }
        guard let _jsonString = notification.userInfo?["_jsonString"] as? String else { return }
        var _jsonString_str = tranjson(str: _jsonString)
        
        webviewC.mWebView.evaluateJavaScript("jsHandlerFunc(\(_jsonString_str),\(call_back))", completionHandler: nil)
    }
    // JS呼叫Swift
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        //        print(message)//WKScriptMessage对象
        //        print(message.name) //name : nativeMethod
        //        print(message.body) //js回传参数
        if let messageBody = message.body as? [String: Any],let FuncName = messageBody["FuncName"] as? String,let Body = messageBody["body"] as? [String: Any]{
            //            let FuncName = messageBody["FuncName"] as! String{return}
            //            let command = messageBody["body"] as! String {return}
            //            print(FuncName)
            //            print(Body)
            let userInfo = Body
            let notification = Notification(name: Notification.Name.init("\(FuncName)"), object: nil, userInfo: userInfo)
            NotificationCenter.default.post(notification)
        }
    }
    
    // LINE 登入
    @objc func loginViaLINE(notification: Notification){
        guard let _content = notification.userInfo?["command"] as? [String:Any] else { return }
        guard let _cbid = _content["0"] as? String else { return }
        LoginManager.shared.login(permissions: [.profile], in: webviewC) {
            result in
            switch result {
            case .success(let loginResult):
                if let profile = loginResult.userProfile {
                    var _userInfo:[String:String] = [String:String]()
                    _userInfo["name"] = profile.displayName
                    _userInfo["email"] = ""
                    _userInfo["id"] = profile.userID
                    _userInfo["picture"] = String(describing: profile.pictureURL)
                    let _jsonData = try? JSONSerialization.data(withJSONObject: _userInfo, options: [])
                    let _jsonString:String = String(data: _jsonData!, encoding: .utf8)!
                    
                    var userInfo: [String:Any] = ["":""]
                    userInfo["_jsonString"] = _jsonString
                    userInfo["call_back"] = _cbid
                    let notification = Notification(name: evaluateJavaScriptNotification, object: nil, userInfo: userInfo)
                    NotificationCenter.default.post(notification)
                    
                }
            case .failure(let error):
                print(error)
            }
        }
        //        print(notification)
        //        guard let _content = notification.userInfo?["command"] as? [String:Any] else { return }
        //        print(_content["1"])
    }
    
    // app資訊
    func getAppInfo(notification: Notification) {
        guard let _content = notification.userInfo?["command"] as? [String:Any] else { return }
        guard let _cbid = _content["0"] as? String else { return }
        let token = UserDefaults.standard.string(forKey: udk_token) ?? ""
        let os_version = DeviceInfoManager.shared.systemVersion
        let application_version = DeviceInfoManager.shared.applicationVersion
        let device = DeviceInfoManager.shared.specification
        let jsonDictionary = [_token: token, _os_version: os_version, _application_version: application_version, _device: device]
        print("----------------------getAppInfo------------------------------------")
        print(jsonDictionary)
        let _jsonData = try? JSONSerialization.data(withJSONObject: jsonDictionary, options: [])
        let _jsonString:String = String(data: _jsonData!, encoding: .utf8)!
        var userInfo: [String:Any] = ["":""]
        userInfo["_jsonString"] = _jsonString
        userInfo["call_back"] = _cbid
        let notification = Notification(name: evaluateJavaScriptNotification, object: nil, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
    
    
    // facebook 登入
    @objc func loginViaFB(notification: Notification){
        let loginManager = LoginManager()
        guard let _content = notification.userInfo?["command"] as? [String:Any] else { return }
        guard let _cbid = _content["0"] as? String else { return }
        DispatchQueue.main.async {
            self.webviewC.startAnimating()
            loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self.webviewC){ loginResult in
                switch loginResult{
                case .failed(let error):
                    print(error)
                    self.webviewC.stopAnimating()
                case .cancelled:
                    print("使用者取消登入")
                    self.webviewC.stopAnimating()
                case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                    print("使用者成功登入")
                    self.getDetails(_cbId: _cbid)
                }
            }
        }
    }
    
    func getDetails(_cbId: String){
        guard let _ = AccessToken.current else{
            self.webviewC.stopAnimating()
            return
        }
        let param = ["fields":"name,email,gender,id, picture"]
        var picURL:String?
        let graphRequest = GraphRequest(graphPath: "me",parameters: param)
        graphRequest.start { (urlResponse, requestResult) in
            switch requestResult{
            case .failed(let error):
                print(error)
                self.webviewC.stopAnimating()
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
                    let _jsonData = try? JSONSerialization.data(withJSONObject: _userInfo, options: [])
                    let _jsonString:String = String(data: _jsonData!, encoding: .utf8)!
                    var userInfo: [String:Any] = ["":""]
                    userInfo["_jsonString"] = _jsonString
                    userInfo["call_back"] = _cbId
                    let notification = Notification(name: evaluateJavaScriptNotification, object: nil, userInfo: userInfo)
                    NotificationCenter.default.post(notification)
                    self.webviewC.stopAnimating()
                }
            }
        }
    }
    
    //Icon數字設定
    func setBadgeNum(notification: Notification) {
        guard let _content = notification.userInfo?["command"] as? [String:Any] else { return }
        guard let badgeNum = _content["0"] as? Int else { return }
        UIApplication.shared.applicationIconBadgeNumber = badgeNum
    }
    
    //特定頁面否返回
    func gourl(notification: Notification) {
        
        guard let _content = notification.userInfo?["command"] as? [String:Any] else { return }
        guard let href = _content["0"] as? String else { return }
        go_url = href
    }
}

//
//  AppModel.swift
//  MUKI_Shipgo17
//
//  Created by mukiloong 2017/12/12.
//  Copyright © 2017年 EICAPITAN. All rights reserved.
//

import Foundation

// var
var back_url :String?
var go_url :String?
var postFileURL : String?
var filesname : String = ""

let web_page = "" // dCloud的webView主頁面，要留意，測試時期與結案時期該連結往往是不同的！
let api_receive_badge = "/api/receive_badge"
let api_app_update_check = "/api/app_update_check"
let api_chenli_url = "http://api.chenliedu.com"
let api_reset_baseUrl = "https://muki1.muki001.com/api/set_project_url"
let api_reset_baseUrl_2 = "https://muki1.muki001.com/api/set_project_url2"
let api_reset_baseUrl_3 = "https://muki1.muki001.com/api/set_project_url3"
let api_reset_baseUrl_4 = "https://muki1.muki001.com/api/set_project_url4"
let api_reset_baseUrl_5 = "https://muki1.muki001.com/api/set_project_url5"

// functions
let haveOutSidePage = false
let haveRemoteNotification = true // 若為false要記得刪掉相關設定；若為true要記得調整相關設定。
let haveGPSLocation = false // 若為false要記得手動刪掉plist裡面的相關設定...吧？
let haveFBShare = false
let haveLINELogin = false
let haveFBLogin = false
let haveVersionCheck = false// 在上線前基本上皆為false，畢竟沒有app store的id。
let haveRemoteNotificationSound = false
let haveQrcode = true

// notification
let shouldStartLoadNotification = Notification.Name.init("shouldStartLoadWithNSNotification")
let facebookShareNotification = Notification.Name.init("facebookShareNotification")
let enterForegroundNotification = Notification.Name.init("applicationWillEnterForeground")
let openFileNotification = Notification.Name.init("openFileNotification")
let downloadFileNotification = Notification.Name.init("downloadFileNotification")
let checkGeoAuthorizationNotification = Notification.Name.init("checkGeoAuthorization")
let pagingNotification = Notification.Name.init("paging")
let removeNotification = Notification.Name.init("remove")
let startLoadingNotification = Notification.Name.init("startLoading")
let stopLoadingNotification = Notification.Name.init("stopLoading")
let resetBaseUrl = Notification.Name.init("resetBaseUrl")
let alertToastNotification = Notification.Name.init("alertToastNotification")
let isCreateNotification = Notification.Name.init("isCreateNotification")
let openShaketNotification = Notification.Name.init("openShaketNotification")
let initUINotification = Notification.Name.init("initUI")

let evaluateJavaScriptNotification = Notification.Name.init("evaluateJavaScriptNotification")
let uploadFileNotification = Notification.Name.init("uploadFileNotification")

// dictionary key
let _callbackID = "callbackID"
let _path = "path"
let _view_name = "view_name"
let _view_style = "paging_style"
let _view_property = "view_property"
let _view_refresh_time = "view_refresh_time"
let _view_isTabBarHidden = "_view_isTabBarHidden"
let _token = "token"
let _os_version = "os_version"
let _application_version = "application_version"
let _device = "device"
let _latitude = "latitude"
let _longitude = "longitude"
let _context = "context"
let _paging_style = "paging_style" //刪掉
let _isFileExist = "isFileExist"
let _viewName = "Name"
let _createTime = "CreateTime"
let _isWebViewExist = "isExist"

// userDefault
let udk_device_id = "udk_device_id"
let udk_token = "udk_token"
let udk_latitude = "latitude"
let udk_longitude = "longitude"
let _server_url = "server_url"
let _device_url = "device_url"
let udk_baseUrl = "baseUrl"
let udk_isSet = "is_set"
let udk_currentPage = "current_page"

enum WebViewProperty: String {
    case main = "main"
    case sub = "sub"
}

enum PagingStyle: String {
    case push = "left"
    case pop = "right"
    case tab = "select"
    case normal = "normal"
}

enum IsSet: Int {
    case original = 0
    case settle = 1
}

// 搖一搖三軸加速器使用
enum PS {
    enum Constant: Double {
        case roundingPrecision = 3.0
        case staticThreshold = 0.013 // g^2
        case slowWalkingThreshold = 0.01    // g^2
        case accelerometerUpdateInterval = 0.1
    }
}

extension String {
     
    //將原始的url編碼轉為合法的url
    func urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return encodeUrlString ?? ""
    }
     
    //將編碼後的url轉換回原始的url
    func urlDecoded() -> String {
        return self.removingPercentEncoding ?? ""
    }
}

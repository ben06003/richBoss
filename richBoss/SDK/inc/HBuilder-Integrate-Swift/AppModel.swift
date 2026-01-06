//
//  AppModel.swift
//  HBuilder-Integrate-Swift
//
//  Created by smallHappy on 2017/12/12.
//  Copyright © 2017年 EICAPITAN. All rights reserved.
//

import Foundation

// baseURL
var baseUrl: String {
    let is_set = UserDefaults.standard.integer(forKey: udk_isSet)
    if let isSet = IsSet(rawValue: is_set), isSet == .settle, let path = UserDefaults.standard.string(forKey: udk_baseUrl) {
        return path
    } else {
//        return "https://aurmonfanny.com/"
        return "http://discountp2.muki001.com/" // 此為測試站
    }
    
}
let web_page = "" // dCloud的webView主頁面，要留意，測試時期與結案時期該連結往往是不同的！
let api_receive_badge = "/api/receive_badge"
let api_app_update_check = "/api/app_update_check"
let app_store = "https://itunes.apple.com/app/id1347069054"
let api_reset_baseUrl = "https://muki1.muki001.com/api/set_project_url"

// functions
let haveOutSidePage = false
let haveRemoteNotification = true // 若為false要記得刪掉相關設定；若為true要記得調整相關設定。
let haveGPSLocation = true // 若為false要記得手動刪掉plist裡面的相關設定...吧？
let haveFBShare = true
let haveFBLogin = true
let haveVersionCheck = true // 在上線前基本上皆為false，畢竟沒有app store的id。

// notification
let shouldStartLoadNotification = Notification.Name.init("shouldStartLoadWithNSNotification")
let facebookShareNotification = Notification.Name.init("facebookShareNotification")
let enterForegroundNotification = Notification.Name.init("applicationWillEnterForeground")
let openFileNotification = Notification.Name.init("openFileNotification")
let checkGeoAuthorizationNotification = Notification.Name.init("checkGeoAuthorization")
let pagingNotification = Notification.Name.init("paging")
let startLoadingNotification = Notification.Name.init("startLoading")
let stopLoadingNotification = Notification.Name.init("stopLoading")
let resetBaseUrl = Notification.Name.init("resetBaseUrl")

// dictionary key
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

// userDefault
let udk_token = "udk_token"
let udk_latitude = "latitude"
let udk_longitude = "longitude"
let _server_url = "server_url"
let _device_url = "device_url"
let udk_baseUrl = "baseUrl"
let udk_isSet = "is_set"

enum WebViewProperty: String {
    case main = "main"
    case sub = "sub"
}

enum PagingStyle: String {
    case push = "left"
    case pop = "right"
    case tab = "select"
}

enum IsSet: Int {
    case original = 0
    case settle = 1
}

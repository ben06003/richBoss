//
//  AppDelegate.swift
//  HBuilder-Integrate-Swift
//
//  Created by EICAPITAN on 17/5/17.
//  Copyright © 2017年 EICAPITAN. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
var url_link: String?
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // get document path for debug
        let path = FileHandler.shared.documentPath.path
        print("path:", path)
        // set rootViewController
        let mainVC = WebViewController()
        let navigationController = UINavigationController(rootViewController: mainVC)
        window?.rootViewController = navigationController
        guard haveRemoteNotification else {
            return PDRCore.initEngineWihtOptions(launchOptions, with: PDRCoreRunMode.webviewClient)
        }
        // set remote notification
        FirebaseApp.configure()
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (isGranted, error) in
                print("使用者\(isGranted ? "同意" : "拒絕")使用推播")
            }
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
//        application.applicationIconBadgeNumber = 0
        // fcm
        let fcmToken = Messaging.messaging().fcmToken
        print("FCM registration token:", fcmToken ?? "<null>")
        let instanceIDToken = InstanceID.instanceID().token()
        UserDefaults.standard.set(instanceIDToken, forKey: udk_token)
        // APNs
//        UIApplication.shared.registerForRemoteNotifications()
        if haveRemoteNotification {
            application.registerForRemoteNotifications()
        }
        let api = baseUrl + api_receive_badge
        if let url = URL(string: api), let token = instanceIDToken {
            DeviceInfoManager.shared.getJsonObject(url: url, bodyDic: [_token:token], sec: 10, finish: { print($0 ?? "jsonObject is nil") })
        }
        // launch~
        // WebApp集成时使用参数
//        return PDRCore.initEngineWihtOptions(launchOptions, with: PDRCoreRunMode.appClient);
        // Webview集成时使用参数
        
        
        PDRCore.initEngineWihtOptions(launchOptions, with: PDRCoreRunMode.webviewClient)
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        PDRCore.handle(PDRCoreSysEvent.peekQuickAction, with: shortcutItem)
        completionHandler(true);
    }

    func applicationWillResignActive(_ application: UIApplication) {
        UserDefaults.standard.set(false, forKey: "first")
        PDRCore.instance().handle(PDRCoreSysEvent.resignActive, with: nil);
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        PDRCore.instance().handle(PDRCoreSysEvent.enterBackground, with: nil);
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        PDRCore.instance().handle(PDRCoreSysEvent.enterForeGround, with: nil);
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        NotificationCenter.default.post(name: enterForegroundNotification, object: nil)
//        application.applicationIconBadgeNumber = 0
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        PDRCore.instance().handle(PDRCoreSysEvent.becomeActive, with: nil);
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        UserDefaults.standard.set(true, forKey: "first")
        PDRCore.destoryEngine();
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // open url
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        PDRCore.instance().handle(PDRCoreSysEvent.openURL, with: url);
        return true;
    }

    
    // push
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        PDRCore.instance().handle(PDRCoreSysEvent.regRemoteNotificationsError, with: error);
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PDRCore.instance().handle(PDRCoreSysEvent.revDeviceToken, with: deviceToken);
        Messaging.messaging().apnsToken = deviceToken
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        PDRCore.instance().handle(PDRCoreSysEvent.revRemoteNotification, with: userInfo)
        application.applicationIconBadgeNumber = 0
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        PDRCore.instance().handle(PDRCoreSysEvent.revLocalNotification, with: notification)
        application.applicationIconBadgeNumber = 0
    }
    
}


@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    /// App 在前景時，推播送出時即會觸發的 delegate
    ///
    /// - Parameters:
    ///   - center: _
    ///   - notification: _
    ///   - completionHandler: _
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // 印出後台送出的推播訊息(JOSN 格式)
        let userInfo = notification.request.content.userInfo
        
        // 可設定要收到什麼樣式的推播訊息，至少要打開 alert，不然會收不到推播訊息
        completionHandler([.badge, .sound, .alert])
    }
    
    /// App 在背景或關閉的狀況下時，點擊推播訊息時所會觸發的 delegate
    ///
    /// - Parameters:
    ///   - center: _
    ///   - response: _
    ///   - completionHandler: _
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // 印出後台送出的推播訊息(JOSN 格式)
        let userInfo = response.notification.request.content.userInfo
        
        // 取出userInfo的link並開啟Facebook
        if userInfo["gcm.notification.url_link"] != nil {
            url_link = userInfo["gcm.notification.url_link"] as! String
            let vc = WebViewController()
            let VCRoot = window?.rootViewController
            if (UserDefaults.standard.bool(forKey: "first")) {
                
            }else{
                VCRoot?.present(vc, animated: true, completion: nil)
            }
        }
        completionHandler()
    }
}




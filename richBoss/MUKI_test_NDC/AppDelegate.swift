//
//  AppDelegate.swift
//  MUKI_test_NDC
//
//  Created by EICAPITAN on 17/5/17.
//  Copyright © 2017年 EICAPITAN. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import LineSDK
import StoreKit
import FirebaseMessaging
import FirebaseCrashlytics
//import AppTrackingTransparency
//import AdSupport


var mukiTestUrlLink: String?
var schemesKey = 0
var firstOpen = 0

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    var orientationLock = UIInterfaceOrientationMask.allButUpsideDown
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        UIApplication.shared.isStatusBarHidden = false
        
        if #available(iOS 13.0, *) {
            UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        }
        
        // 頁面轉換判定
        var mainVC:UIViewController?
        mainVC = WebViewController()
        let navigationController = UINavigationController(rootViewController: mainVC!)
        self.window?.rootViewController = navigationController
        
        
        // set remote notification
        FirebaseApp.configure()
//        FirebaseConfiguration.shared.setLoggerLevel(.debug)  // ✅ 確保 Debug log 開啟
        
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().delegate = self
            Messaging.messaging().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (isGranted, error) in
                print("使用者\(isGranted ? "同意" : "拒絕")使用推播")
            }
        } else if #available(iOS 8.0, *) {
            application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
        } else {
            let types:UIRemoteNotificationType = [UIRemoteNotificationType.alert, UIRemoteNotificationType.badge, .sound]
            application.registerForRemoteNotifications(matching: types)
        }
        
        // fcm
        let fcmToken = Messaging.messaging().fcmToken
        UserDefaults.standard.set(fcmToken, forKey: udk_token)
        application.registerForRemoteNotifications()
        
        SKPaymentQueue.default().add(IAPManager.shared)
        
//        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        
        return true
    }
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return orientationLock
    }
        
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let fcmToken = Messaging.messaging().fcmToken
        print("fcmToken:\(fcmToken)")
        UserDefaults.standard.set(fcmToken, forKey: udk_token)
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true);
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        schemesKey = 1
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        NotificationCenter.default.post(name: enterForegroundNotification, object: nil)
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("deviceToken:\(deviceToken) ")
    }
    // line & fb login (外部)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if haveLINELogin {
            LoginManager.shared.application(app, open: url, options: options)
        }
        if url.host == nil {
            return true;
        }
        
        return true
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
        // 導向webviewcontroller 並連到該網址
        if userInfo["gcm.notification.url_link"] != nil {
            mukiTestUrlLink = userInfo["gcm.notification.url_link"] as? String
            let mainVC = WebViewController()
            let navigationController = UINavigationController(rootViewController: mainVC)
            self.window?.rootViewController = navigationController
//            self.present(navigationController, animated: true)
//            let app = WebViewController()
//            let rootVC = window?.rootViewController
//            rootVC?.present(app, animated: true, completion: nil)
        }
        completionHandler()
    }
}

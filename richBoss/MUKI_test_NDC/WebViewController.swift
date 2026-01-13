/*
 1. shouldStartLoadWith為開啟外部連結的方法。
 2. setCoreLocation為取得定位授權(並開始定位)的方法。
 3. checkoutUpdate為判斷軟體版本並提示更新的方法，須留意上架後得再次上一版，該功能才會具體有效，畢竟得要有app store的id。
 */

import Foundation
import UIKit
import WebKit
import LocalAuthentication
import MobileCoreServices
import UserNotifications
import AuthenticationServices
import Reachability
import StoreKit
import AVFoundation
//import AppTrackingTransparency
import Firebase
import SafariServices

extension WebViewController {
    // Buy蘋果內購商品
    @objc func buyAppleProduct(notification: Notification) {
        guard let _content = notification.userInfo?["command"] as? [String:Any] else { return }
        print("_content:\(_content)")
        guard let productId = _content["0"] as? String else { return }
        guard let order_id = _content["1"] as? String else { return }
        IAPManager.shared.orderID = order_id
        // 記錄在
        UserDefaults.standard.set(order_id, forKey: "IAPOrderId")
        UserDefaults.standard.set(productId, forKey: "IAPProductId")
//        print("productIndex1:\(IAPManager.shared.productListsA()[productId])")
        guard let productIndex = IAPManager.shared.productIndexs.index(of: productId ?? "") else { return }
        print("productIndex2:\(productIndex)")
        IAPManager.shared.buy(product: IAPManager.shared.products[productIndex])

    }
}

class WebViewController: BaseVC,Transform,WKUIDelegate,WKScriptMessageHandler{
    
    
    
    // 商店
//    var isProgress: Bool = false // 是否有交易正在進行中
//    var productIDs: [String] = [String]() // 產品ID(Consumable_Product、Not_Consumable_Product)
//    var productsArray: [SKProduct] = [SKProduct]() //  存放 server 回應的產品項目
//    var delegate: IAPurchaseViewControllerDelegate!
    
    var stopload:Bool = false
    lazy var backgroundImageView: UIImageView = {
        let _view = UIImageView(frame: self.view.bounds)
        //let _view = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width/2, height: self.view.frame.height/2))
        _view.isHidden = true
        self.view.addSubview(_view)
        return _view
    }()
    var haveback:Bool = false
    var documents = [URL]()
    var _navigationBar:UINavigationBar!
    var _screenImg:UIImageView!
    var _vc:UIViewController!
    var _view:UIView!
    var mWebView: WKWebView!
    var cbid:String?
    var isOutSide = false
    var AppleLoginkey:String?
    var coordinateCondKey:Int = 0
    var coordinateCondTime:Int = 5
    var coordinateCondTiming:TimeInterval?
    var getCoordinateCondKey = 1
    var fristKey = 0
    var _orientation:UIInterfaceOrientationMask = .portrait
    var _rotateOrientation:UIInterfaceOrientation = .portrait
    var looper: AVPlayerLooper?
    var player = AVQueuePlayer()
    var playItem = "bg1"

    // 上方navigationItemTitle
    var navigationItemTitle:String! {
        get {
            return self.navigationItemTitle
        }
        set {
            self.navigationItem.title = newValue
        }
    }
    // 下方橫條製作
    var bottomItem :UIView!
    var button1 :UIButton!
    var button2 :UIButton!
    var button3 :UIButton!
    var button4 :UIButton!
    // 網路偵測
    var reachability: Reachability!
    var connectionStatus :String?
    
    var lat_test = 24.161706
    var long_test = 120.651386
    
  
    override func loadView() {
       
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        super.loadView()
        self.view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        UserDefaults.standard.set("1", forKey: "app_into")
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.starLoad()
        launchAnimation()
        // 網路偵測
        do {
            reachability = try Reachability()
            NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        IAPManager.shared.getProducts()
        
        // 2️⃣ 請求 ATT 授權
//        requestTrackingPermission()
        
        self.connectionSure()
    }
    
//    func requestTrackingPermission() {
//        if #available(iOS 14, *) {
//            ATTrackingManager.requestTrackingAuthorization { status in
//                switch status {
//                case .authorized:
//                    print("用戶允許追蹤")
//                case .denied, .restricted, .notDetermined:
//                    print("用戶拒絕追蹤")
//                @unknown default:
//                    break
//                }
//            }
//        }
//    }
    
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        
        if connectionStatus == nil {
            switch reachability.connection {
            case .wifi:
                connectionStatus = "wifi"
            case .cellular:
                connectionStatus = "cellular"
            case .none:
                connectionStatus = "none"
            case .unavailable:
                connectionStatus = "none"
            }
        }else if connectionStatus == "wifi" || connectionStatus == "cellular"  {
            switch reachability.connection {
            case .wifi:
                return
            case .cellular:
                return
            case .none:
                // 建立一個提示框
                let alertController = UIAlertController(title: "連線狀態改變",message: "請重新開啟APP",preferredStyle: .alert)
                // 建立[確認]按鈕
                let okAction = UIAlertAction(title: "OK",style: .default,handler: {(action: UIAlertAction!) -> Void in
                    exit(0)
                    
                })
                alertController.addAction(okAction)
                // 顯示提示框
                self.present(alertController,animated: true,completion: nil)
            case .unavailable:
                // 建立一個提示框
                let alertController = UIAlertController(title: "連線狀態改變",message: "請重新開啟APP",preferredStyle: .alert)
                // 建立[確認]按鈕
                let okAction = UIAlertAction(title: "OK",style: .default,handler: {(action: UIAlertAction!) -> Void in
                    exit(0)
                    
                })
                alertController.addAction(okAction)
                // 顯示提示框
                self.present(alertController,animated: true,completion: nil)
            }
        }else if connectionStatus == "none" {
            switch reachability.connection {
            case .wifi:
                // 建立一個提示框
                let alertController = UIAlertController(title: "連線狀態改變",message: "請重新開啟APP",preferredStyle: .alert)
                // 建立[確認]按鈕
                let okAction = UIAlertAction(title: "OK",style: .default,handler: {(action: UIAlertAction!) -> Void in
                    exit(0)
                    
                })
                alertController.addAction(okAction)
                // 顯示提示框
                self.present(alertController,animated: true,completion: nil)
            case .cellular:
                // 建立一個提示框
                let alertController = UIAlertController(title: "連線狀態改變",message: "請重新開啟APP",preferredStyle: .alert)
                // 建立[確認]按鈕
                let okAction = UIAlertAction(title: "OK",style: .default,handler: {(action: UIAlertAction!) -> Void in
                    exit(0)
                    
                })
                alertController.addAction(okAction)
                // 顯示提示框
                self.present(alertController,animated: true,completion: nil)
            case .none:
                return
            case .unavailable:
                return
            }
        }
    }
    
    //播放启动画面动画
    private func launchAnimation() {
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        if let img = splashImageForOrientation(orientation: statusBarOrientation,
                                               size: self.view.bounds.size) {
            //获取启动图片
            let launchImage = UIImage(named: img)
            let launchview = UIImageView(frame: UIScreen.main.bounds)
            launchview.image = launchImage
            //将图片添加到视图上
            //self.view.addSubview(launchview)
            let delegate = UIApplication.shared.delegate
            let mainWindow = delegate?.window
            mainWindow!!.addSubview(launchview)
            
            //播放动画效果，完毕后将其移除
            UIView.animate(withDuration: 1, delay: 1.5, options: .beginFromCurrentState,
                           animations: {
                            launchview.alpha = 0.0
                            launchview.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.5, 1.5, 1.0)
            }) { (finished) in
                launchview.removeFromSuperview()
            }
        }
    }
    
    //获取启动图片名（根据设备方向和尺寸）
    func splashImageForOrientation(orientation: UIInterfaceOrientation, size: CGSize) -> String?{
        //获取设备尺寸和方向
        let viewSize = size
        var viewOrientation = "Portrait"
        
        if UIInterfaceOrientationIsLandscape(orientation) {
            viewOrientation = "Landscape"
        }
        
        //遍历资源库中的所有启动图片，找出符合条件的
        if let imagesDict = Bundle.main.infoDictionary  {
            if let imagesArray = imagesDict["UILaunchImages"] as? [[String: String]] {
                for dict in imagesArray {
                    if let sizeString = dict["UILaunchImageSize"],
                        let imageOrientation = dict["UILaunchImageOrientation"] {
                        let imageSize = CGSizeFromString(sizeString)
                        if imageSize.equalTo(viewSize)
                            && viewOrientation == imageOrientation {
                            if let imageName = dict["UILaunchImageName"] {
                                return imageName
                            }
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func connectionSure () {
        if !DeviceInfoManager.shared.connectedToNetwork {
            // 建立一個提示框
            let alertController = UIAlertController(title: "連線異常",message: "請確認連線後，再次嘗試",preferredStyle: .alert)
            // 建立[確認]按鈕
            let okAction = UIAlertAction(title: "重新連接",style: .default,handler: {(action: UIAlertAction!) -> Void in
                self.connectionSure()
            })
            alertController.addAction(okAction)
            // 顯示提示框
            self.present(alertController,animated: true,completion: nil)
        }else{
            //            self.startAnimating()
            self.initUI(path: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {

        self.navigationController?.isNavigationBarHidden = true
        self.setNotificationCenter(isAdd: true)
        UIApplication.shared.isIdleTimerDisabled = true
        if self.shouldShowLaunchAnimation {
            self.shouldShowLaunchAnimation = false
            //self.triggerLaunchAnimation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        print("_rotateOrientation:\(_rotateOrientation)")
        print("_orientation:\(_orientation)")
        if fristKey == 1 {
            UIUtils.lockOrientation(_orientation, andRotateTo: _rotateOrientation)
        }
        fristKey = 1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.setNotificationCenter(isAdd: false)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    // 設定螢幕為不可旋轉
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    // ✅ 初始方向
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            print(Float(self.mWebView.estimatedProgress))
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        print("轉向：\(mWebView.frame)")
        print("轉向：\(self.view.frame)")
        coordinator.animate(alongsideTransition: { _ in
            if size.width > size.height {
                self.navigationController?.isNavigationBarHidden = true
//                self.mWebView.frame = self.view.frame
           } else {
               // 竖屏
               self.navigationController?.isNavigationBarHidden = true
//               print("Portrait")
           }
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()

            self.mWebView.alpha = 0
        }, completion: { _ in
            UIView.animate(withDuration: 0.25) {
                self.mWebView.alpha = 1
            }
        })
    }
    
    // MARK: - InitUIfunction
    // 初始畫面用的方法。
    func initUI(path: String?) {
        self.view.backgroundColor = UIColor.black
        
        //navigationItem style
        let navigationItem = UINavigationItem()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.backgroundColor = UIColor.black
        
        // WKWebView 設定
        let conf = WKWebViewConfiguration()
        
        // 不允許行內播放（會要求全螢幕 → 必須手勢）
        conf.allowsInlineMediaPlayback = false
        
        // 禁止自動播放
        if #available(iOS 13.0, *) {
            conf.mediaTypesRequiringUserActionForPlayback = .all
        } else {
            conf.mediaPlaybackRequiresUserAction = true
        }
        
        // Preferences
        conf.preferences = WKPreferences()
        conf.preferences.minimumFontSize = 10
        conf.preferences.javaScriptEnabled = true
        conf.preferences.javaScriptCanOpenWindowsAutomatically = false
        
        conf.processPool = WKProcessPool()
        conf.userContentController = WKUserContentController()
        
        // 🔥🔥🔥 這段是「強制阻擋影片自動播放」的 JS Hack
        let blockDynamicVideoJS = """
        function blockVideo(v) {
            try {
                v.pause();
                v.autoplay = false;

                v.removeAttribute('autoplay');
                v.removeAttribute('playsinline');
                v.removeAttribute('muted');
                v.removeAttribute('preload');

                v.preload = 'none';

                // 移除所有 <source> 的 autoplay 特性
                let sources = v.querySelectorAll('source');
                sources.forEach(s => {
                    s.removeAttribute('autoplay');
                });
            } catch(e) {}
        }

        // 先處理既有影片
        document.querySelectorAll('video').forEach(v => blockVideo(v));

        // 監聽後續 DOM 變化
        const observer = new MutationObserver(mutations => {
            mutations.forEach(m => {
                m.addedNodes.forEach(node => {
                    if (node.tagName === 'VIDEO') {
                        blockVideo(node);
                    } else if (node.querySelectorAll) {
                        node.querySelectorAll('video').forEach(v => blockVideo(v));
                    }
                });
            });
        });

        observer.observe(document.body, { childList: true, subtree: true });
        """
        let blockScript = WKUserScript(source: blockDynamicVideoJS,
                                       injectionTime: .atDocumentEnd,
                                       forMainFrameOnly: true)
        conf.userContentController.addUserScript(blockScript)
        // 🔥🔥🔥 End
        
        var stRect = self.view.frame
	
        let _url = "https://sf2dev.com/"

        let baseURL_arr = _url.components(separatedBy: "/")
        baseUrl = baseURL_arr[0]+"/"+baseURL_arr[1]+"/"+baseURL_arr[2]
        
        if let url = URL(string: _url) {
            let request = URLRequest(url: url)
            
            self.mWebView = WKWebView(frame: stRect, configuration: conf)
            self.addUserAgent()
            
            if let mWebView = self.mWebView {
                mWebView.translatesAutoresizingMaskIntoConstraints = false
                mWebView.configuration.userContentController.add(self as! WKScriptMessageHandler, name: "nativeMethod")
                mWebView.navigationDelegate = self
                mWebView.scrollView.delegate = self
                mWebView.scrollView.bounces = false
                mWebView.uiDelegate = self
                
                // viewport
                let source: String = """
                var meta = document.createElement('meta');
                meta.name = 'viewport';
                meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
                var head = document.getElementsByTagName('head')[0];
                head.appendChild(meta);
                """
                let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
                mWebView.configuration.userContentController.addUserScript(script)
                
                mWebView.load(request)
                self.view.addSubview(mWebView)
                
                NSLayoutConstraint.activate([
                    mWebView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                    mWebView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                    mWebView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                    mWebView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                ])
                
                self.view.sendSubview(toBack: mWebView)
            }
        }
    }

    
    func markBottomItem () {
        self.bottomItem = UIView()
        self.bottomItem.frame = CGRect(x:0, y:0, width: self.view.frame.size.width, height: 40)
        self.bottomItem.center = CGPoint(x:self.view.frame.size.width/2, y: self.view.frame.size.height-20)
        self.bottomItem.backgroundColor = UIColor.darkGray
        self.bottomItem.alpha = 0.9
        
        self.button1 = UIButton()
        self.button1.frame.size = CGSize(width: 30, height: 30)
        self.button1.frame.origin = CGPoint(x: self.bottomItem.frame.size.width/5-20, y: 5)
        self.button1.backgroundColor = UIColor.clear
        self.button1.setImage(UIImage(named: "Left"), for: .normal)
        self.button1.tintColor = UIColor.lightGray
        self.button1.addTarget(self, action: #selector(self.backWeb), for: .touchUpInside)
        self.bottomItem.addSubview(self.button1)
        
        self.button2 = UIButton()
        self.button2.frame.size = CGSize(width: 30, height: 30)
        self.button2.frame.origin = CGPoint(x: self.bottomItem.frame.size.width*2/5-20, y: 5)
        self.button2.backgroundColor = UIColor.clear
        self.button2.setImage(UIImage(named: "Right"), for: .normal)
        self.button2.tintColor = UIColor.lightGray
        self.button2.addTarget(self, action: #selector(self.nextWeb), for: .touchUpInside)
        self.bottomItem.addSubview(self.button2)
        
        self.button3 = UIButton()
        self.button3.frame.size = CGSize(width: 30, height: 30)
        self.button3.frame.origin = CGPoint(x: self.bottomItem.frame.size.width*3/5-20, y: 5)
        self.button3.backgroundColor = UIColor.clear
        self.button3.setImage(UIImage(named: "Copy"), for: .normal)
        self.button3.tintColor = UIColor.white
        self.button3.addTarget(self, action: #selector(self.copyUrl), for: .touchUpInside)
        self.bottomItem.addSubview(self.button3)
        
        self.button4 = UIButton()
        self.button4.frame.size = CGSize(width: 30, height: 30)
        self.button4.frame.origin = CGPoint(x: self.bottomItem.frame.size.width*4/5-20, y: 5)
        self.button4.backgroundColor = UIColor.clear
        self.button4.setImage(UIImage(named: "Share"), for: .normal)
        self.button4.tintColor = UIColor.white
        self.button4.addTarget(self, action: #selector(self.shareUrl), for: .touchUpInside)
        self.bottomItem.addSubview(self.button4)
        
        self.view.addSubview(self.bottomItem)
        self.bottomItem.isHidden = true
    }
    
    @objc func backWeb () {
        if self.mWebView.canGoBack {
            self.mWebView.goBack()
        }
    }
    @objc func nextWeb () {
        if self.mWebView.canGoForward {
            self.mWebView.goForward()
        }
    }
    @objc func copyUrl () {
        let nowUrl = self.mWebView.url
        let strUrl = nowUrl!.absoluteString
        UIPasteboard.general.string = strUrl
        let content = "複製網址"
        let _contentSize:CGSize = content.size(OfFont: UIFont.systemFont(ofSize: 14))
        let _showView:UILabel = UILabel()
        _showView.frame.size = CGSize(width: _contentSize.width+20, height: _contentSize.height+10)
        _showView.center = self.view.center
        _showView.backgroundColor = UIColor.darkGray
        _showView.textColor = UIColor.white
        _showView.textAlignment = .center
        _showView.font = UIFont.systemFont(ofSize: 14)
        _showView.text = content
        _showView.layer.cornerRadius = 5
        _showView.layer.masksToBounds = true
        self.mWebView?.addSubview(_showView)
        _showView.tag = self.mWebView!.subviews.count
        
        let _delayTime:Double = 2
        
        for _i in 0..<self.mWebView!.subviews.count {
            let _current = self.mWebView!.subviews[_i]
            if _current is UILabel && _current.tag == _showView.tag {
                _ = Brook_Dispatch().delay(_delay: _delayTime, _func: {
                    _current.removeFromSuperview()
                })
            }
        }
        
    }
    @objc func shareUrl () {
        let nowUrl = self.mWebView.url
        let strUrl = nowUrl!.absoluteString
        let activityConterller = UIActivityViewController(activityItems: [strUrl], applicationActivities: [])
        present(activityConterller, animated: true, completion: nil)
    }
    // MARK: - setNotificationCenter
    private func setNotificationCenter(isAdd: Bool) {
        if isAdd {
            NotificationCenter.default.addObserver(self, selector: #selector(self.applicationWillEnterForegroundNotification(notification:)), name: enterForegroundNotification, object: nil)
//            NotificationCenter.default.addObserver(self, selector: #selector(self.orientationChanged), name:Notification.Name.init("UIDeviceOrientationDidChangeNotification"), object: nil)
            // 由js呼叫的loading
            NotificationCenter.default.addObserver(self, selector: #selector(self.starLoad), name: startLoadingNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.stopLoad), name: stopLoadingNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.evaluateJavaScript(notification:)), name: evaluateJavaScriptNotification, object: nil)
            
            // JS呼叫Swift
            NotificationCenter.default.addObserver(self, selector: #selector(self.loginViaApple(notification:)), name: Notification.Name.init("AppleLogin"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.buyAppleProduct(notification:)), name: Notification.Name.init("InAppBuy"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.openUrlByBrowser(notification:)), name: Notification.Name.init("OpenBrowser"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.getAppVersion(notification:)), name: Notification.Name.init("GetAppVersion"), object: nil)
         	
            NotificationCenter.default.addObserver(self, selector: #selector(self.initODM(notification:)), name: Notification.Name.init("InitODM"), object: nil)
           
        } else {
            NotificationCenter.default.removeObserver(self)
        }
    }
        
    private func checkoutUpdate() {
        guard haveVersionCheck else { return }
        _ = try? VersionManager.shared.isUpdateAvailable {
            if let error = $1 { print(error); return }
            guard let update = $0, update else { return }
            self.showAlertToUpdate(false)
//            guard let url = URL(string: app_store_baseUrl + api_app_update_check) else { return }
//            JsonManager.sharedInstance.getJsonObject(method: .get, url: url, finish: {
//                guard let jsonObject = $0 as? [String: String] else { return }
//                let isForced = jsonObject["return_data"] == "1"
//                self.showAlertToUpdate(isForced)
//            })
        }
    }
    
    private func showAlertToUpdate(_ isForced: Bool) {
        let alertController = UIAlertController (title: "您的App並非最新版本", message: "請至「App Store」下載最新版本。", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "否", style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: "是", style: .default) { _ in
            guard let url = URL(string: app_store) else { return }
            if  UIApplication.shared.canOpenURL(url) == true {
                UIApplication.shared.open(url: url)
            }
        }
        let recognizeAction = UIAlertAction(title: "知道了", style: .default){ _ in
            guard let url = URL(string: app_store) else { return }
            if  UIApplication.shared.canOpenURL(url) == true {
                UIApplication.shared.open(url: url)
            }
            /*
             DispatchQueue.main.async {
             UIApplication.shared.open(url: url)
             exit(0)
             }
             */
        }
        if isForced {
            alertController.addAction(recognizeAction)
        } else {
            alertController.addAction(noAction)
            alertController.addAction(yesAction)
        }
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    @objc private func applicationWillEnterForegroundNotification(notification: Notification) {
        print("回到前景")
        DispatchQueue.main.async{
            self.mWebView.evaluateJavaScript("willEnterForeground()", completionHandler: nil)
        }
        // 判斷是否有更新版本
//        self.checkoutUpdate()
    }
    
    @objc private func alertToas(notification: Notification) {
        guard let _content = notification.userInfo?["content"] as? String else { return }
        guard let _position = notification.userInfo?["position"] as? String else { return }
        guard let _showTime = notification.userInfo?["showTime"] as? String else { return }
        print(_content, _position, _showTime)
        
        let _contentSize:CGSize = _content.size(OfFont: UIFont.systemFont(ofSize: 14))
        //print(_contentSize)
        
        let _showView:UILabel = UILabel()
        _showView.frame.size = CGSize(width: _contentSize.width+20, height: _contentSize.height+10)
        _showView.center = (_position == "center") ? self.view.center : CGPoint(x: self.view.center.x, y: self.view.frame.height-90)
        _showView.backgroundColor = UIColor.darkGray
        _showView.textColor = UIColor.white
        _showView.textAlignment = .center
        _showView.font = UIFont.systemFont(ofSize: 14)
        _showView.text = _content
        _showView.layer.cornerRadius = 5
        _showView.layer.masksToBounds = true
        //self.view.addSubview(_showView)
        self.mWebView?.addSubview(_showView)
        _showView.tag = self.mWebView!.subviews.count
        
        let _delayTime:Double = (_showTime == "long") ? 7 : 3
        
        //_ = Brook_Dispatch().delay(_delay: _delayTime, _func: {
        //print(self.webFrame!.subviews)
        for _i in 0..<self.mWebView!.subviews.count {
            print(_i)
            let _current = self.mWebView!.subviews[_i]
            if _current is UILabel && _current.tag == _showView.tag {
                _ = Brook_Dispatch().delay(_delay: _delayTime, _func: {
                    print("chanl")
                    _current.removeFromSuperview()
                })
            }
        }
        //})
    }
    @objc private func shouldStartLoadWith(notification: Notification) {
        guard let _content = notification.userInfo?["command"] as? [String:Any] else { return }
        guard let href = _content["0"] as? String else { return }
        let outsideVC = OutSideVC()
        let newLink = href.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        outsideVC.link = URL(string: newLink)
        outsideVC.outside_orientation =  _orientation
        outsideVC.outside_rotateOrientation =  _rotateOrientation
        UIUtils.lockOrientation(.portrait, andRotateTo: .portrait)
        self.navigationController?.pushViewController(outsideVC, animated: true)
    }
    
    @objc private func facebookShare(notification: Notification) {
        guard let path = notification.userInfo?[_path] as? String else { return }
        guard let url = URL(string: path) else { return }
        print(#function, path)
//        let content = FBS
//        let content = FBSDKShareLinkContent.init()
//        content.contentURL = url
//        FBSDKShareDialog.show(from: self, with: content, delegate: nil)
    }
    
    
    func addUserAgent () {
        self.mWebView.evaluateJavaScript("navigator.userAgent") {(result, error) in
            print(result)
            if let webView = self.mWebView, let userAgent = result as? String {
                webView.customUserAgent = userAgent + "/IosMobile"
                print(self.mWebView.customUserAgent)
            }
        }
    }
    
    // MARK: - webView event
    @objc private func starLoad() {
        self.startAnimating()
    }
    
    @objc private func stopLoad() {
        self.stopAnimating()
    }
    
    @objc private func onLeftBarButtonAction() {
        if (go_url == nil) {
            mWebView.goBack()
        }else{
            let url = URL(string: go_url as! String)
            go_url = nil
            let request = URLRequest(url: url!)
            mWebView.load(request)
        }
        
    }
    
    @objc private func onRightBarButtonAction() {
        mWebView.reload()
    }
    
    @objc private func failLoad() {
        self.stopAnimating()
    }
    
}

extension WebViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
}


extension WebViewController: WKNavigationDelegate {
    // 網址訪問失敗
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    
    // 另外加載網站
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        print("b:\(navigationAction.request.description)")
        // 確認有要開啟的 URL
       guard let url = navigationAction.request.url else { return nil }

       // 使用 SFSafariViewController 開啟外部連結
       let safariVC = SFSafariViewController(url: url)
       safariVC.modalPresentationStyle = .formSheet  // 可改成 .fullScreen
       self.present(safariVC, animated: true)

       return nil // 不建立新的 WKWebView
    }
    
    // 網址導向之前
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("a:\(navigationResponse.request.description)")
        decisionHandler(.allow)
    }
    
    // 網站開始載入
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.startAnimating()
        //        self.view.bringSubview(toFront: self.bottomItem)
        DispatchQueue.global().async {
            for i in 0...5 {
                sleep(1)
            }
            DispatchQueue.main.async {
//                self.navigationItem.title = self.webView.title
                self.stopAnimating()
            }
        }
    }
    
    // 網站載入結束
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        self.navigationItem.title = self.webView.title
        //        backForwardListCheck()
        self.stopAnimating()
        if firstOpen == 0 {
            firstOpen = 1
//            let IAPProductId:String? = UserDefaults.standard.string(forKey: "IAPProductId")
//            if ((IAPProductId) != nil) {
//                guard let productIndex = IAPManager.shared.productIndexs.index(of: IAPProductId?.description ?? "") else { return }
//                print("IAPManager.shared.products.count:\(IAPManager.shared.products.count)")
//                print("productIndex:\(productIndex)")
//                if (IAPManager.shared.products.count >= productIndex) {
//                    IAPManager.shared.buy(product: IAPManager.shared.products[productIndex])
//                }
//            }
        }
    }
    
    var backItem: WKBackForwardListItem? {
        return nil
    }
    
    var forwardItem: WKBackForwardListItem? {
        return nil
    }
    
    //
    func backForwardListCheck(){
        if mWebView.canGoBack {
            self.button1.tintColor = UIColor.white
        }else{
            self.button1.tintColor = UIColor.lightGray
        }
        if mWebView.canGoForward{
            self.button2.tintColor = UIColor.white
        }else{
            self.button2.tintColor = UIColor.lightGray
        }
    }
}

//提示警告視窗
class Brook_Alert {
    
    var _alertController:UIAlertController!
    fileprivate var _dispatch:Brook_Dispatch!
    
    deinit{
        self._alertController = nil
        self._dispatch = nil
    }
    
    init(_viewCtrl:UIViewController, _style:UIAlertControllerStyle, _drawIcon:Int, _title:String, _message:String, _defaultTitle:String?=nil, _defaultTAction:((UIAlertAction)->())?=nil, _cancelTitle:String?=nil ,_cancelAction:((UIAlertAction)->())?=nil, _destructiveTitle:String?=nil, _destructiveAction:((UIAlertAction)->())?=nil) {
        
        self._dispatch = Brook_Dispatch()
        
        self._alertController = UIAlertController (title: _title, message: _message, preferredStyle: _style ) //.Alert .ActionSheet
        
        if _defaultTitle != nil {
            let _defaultAlert = UIAlertAction (title: _defaultTitle, style: UIAlertActionStyle.default, handler: { UIAlertAction in
                _defaultTAction?(UIAlertAction)
                self.dismiss()
            })
            self._alertController.addAction(_defaultAlert)
        }
        
        //取消
        if _cancelTitle != nil {
            let _cancelAlert = UIAlertAction (title: _cancelTitle, style: UIAlertActionStyle.cancel, handler: { UIAlertAction in
                _cancelAction?(UIAlertAction)
                self.dismiss()
            })
            self._alertController.addAction(_cancelAlert)
        }
        
        if _destructiveTitle != nil {
            let _destructiveAlert = UIAlertAction (title: _destructiveTitle, style: UIAlertActionStyle.destructive, handler: { UIAlertAction in
                _destructiveAction?(UIAlertAction)
                self.dismiss()
            })
            self._alertController.addAction(_destructiveAlert)
        }
        
        _viewCtrl.present(self._alertController, animated: true, completion: nil )
        
    }
    
    //移除
    func dismiss(_delay:Double?=nil, _action:(()->())?=nil) { //_viewCtrl:UIViewController
        if _delay == nil {
            self._alertController.dismiss(animated: false, completion: nil)
            if _action != nil { _action!() }
            self._alertController = nil
            self._dispatch = nil
        }else{
            _ = self._dispatch.delay(_delay: _delay!, _func: {
                self._alertController.dismiss(animated: false, completion: nil)
                if _action != nil { _action!() }
                self._alertController = nil
                self._dispatch = nil
            })
        }
    }
    
}

//程式執行調度
class Brook_Dispatch {
    
    //延遲執行
    func delay(_delay:Double, _func: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + _delay) {
            _func()
        }
    }
    
    //間隔執行
    fileprivate var _nsTimer:Timer!
    fileprivate var _intervalFunc:(()->())? = nil
    func interval_Start(_intervalSecs:Double, _func: @escaping ()->()) {
        self._intervalFunc = _func
        self._nsTimer = Timer.scheduledTimer(timeInterval: _intervalSecs, target:self, selector: #selector(self.action), userInfo:nil, repeats:true)
    }
    func interval_Stop() {
        self._nsTimer.invalidate()
    }
    @objc fileprivate func action() {
        self._intervalFunc!()
    }
    
    //單次異步執行
    func one(_func: @escaping ()->()) {
        DispatchQueue.main.async {
            _func()
        }
    }
    //sync 同步
    //async 異步
    
    //背景執行緒語法
    func globalOne(_func: @escaping ()->()) {
        DispatchQueue.main.async {
            _func()
        }
    }
    
    //單次異步執行
    func oneAsync(_label:String, _index:Int, _startFunc: @escaping (_ _index:Int)->(), _endFunc: @escaping (_ _index:Int)->()) {
        let _group = DispatchGroup()
        let _queue = DispatchQueue(label: _label)
        _queue.async(group: _group) {
            print("執行線程 = \(_index)")
            _startFunc(_index)
        }
        _group.notify(queue: DispatchQueue.main) {
            print("執行完成 = \(_index)")
            _endFunc(_index)
        }
    }
    
    //多次異步執行
    func many(_label:String?="many", _num:Int, _startFunc: @escaping (_ _index:Int)->(), _endFunc: @escaping (_ _index:Int)->()) {
        let _group = DispatchGroup()
        let _queue = DispatchQueue(label: _label!)
        for _i in 0..<_num {
            _queue.async(group: _group) {
                print("執行線程 = \(_i)")
                _startFunc(_i)
                
            }
        }
        
        _group.notify(queue: DispatchQueue.main) {
            print("執行完成")
            for _i in 0..<_num {
                _endFunc(_i)
            }
        }
        
    }
    
    //後台執行
    func background() {
        let _backgroundQueue = DispatchQueue(label: "backgroundQueue", qos: .background, target: nil)
        _backgroundQueue.async {
            print("Dispatched to background queue")
        }
    }
    
    deinit{
        self._nsTimer = nil
        self._intervalFunc = nil
    }
    
}

extension String {
    
    //字串寬度 高度
    func size(OfFont font: UIFont) -> CGSize {
        return (self as NSString).size(withAttributes: [NSAttributedString.Key.font: font])
    }
    
    //抓取字串範圍字符
    public subscript(_integerRange: Range<Int>) -> String {
        let _start = self.index(startIndex, offsetBy: _integerRange.lowerBound)
        let _end = self.index(startIndex, offsetBy: _integerRange.upperBound)
        let _range = _start..<_end
        return String(self[_range])
    }
    public subscript(_index: Int) -> String {
        let _integerRange = _index..<_index+1
        let _start = self.index(startIndex, offsetBy: _integerRange.lowerBound)
        let _end = self.index(startIndex, offsetBy: _integerRange.upperBound)
        let _range = _start..<_end
        return String(self[_range])
    }
    //回傳指定字串回傳所在位置
    public subscript(_indexStr: String) -> Int {
        var _index:Int = 0
        for _i in 0..<self.count {
            if self[_i] == _indexStr {
                _index = _i
                return _index
            }
        }
        return -1
    }
    //回傳兩指定字串中間字串
    public subscript(_indexStr1: String, _indexStr2: String) -> String {
        var _index1:Int = 0
        for _i in 0..<self.count {
            if self[_i] == _indexStr1 {
                _index1 = _i+1
                break
            }
        }
        var _index2:Int = self.count
        for _i in _index1..<self.count {
            if self[_i] == _indexStr2 {
                _index2 = _i
                break
            }
        }
        return self[_index1..<_index2]
    }
    
    //回傳指定字串之間字串陣列
    func disString(_indexStr: String) -> [String] {
        
        var _index:Int = 0
        var _returnStr:[String] = [String]()
        
        func getStr(_startIndex:Int) {
            var _bool:Bool = false
            for _i in _startIndex..<self.count {
                if self[_i] == _indexStr {
                    _returnStr.append((self[_startIndex..<_i]))
                    _index = _i+1
                    _bool = true
                    break
                }else if _i == self.count-1 {
                    _returnStr.append((self[_startIndex..<_i+1]))
                }
            }
            if _bool == true {
                getStr(_startIndex: _index)
            }
        }
        
        getStr(_startIndex: 0)
        //print(_returnStr)
        return _returnStr
    }
    
    //刪除字串裡的空白
    func removeWhitespaces() -> String {
        //return components(separatedBy: .whitespaces).joined()
        return components(separatedBy: .whitespacesAndNewlines).joined()
    }
    
    //語言本地化
    func localizedString(_bundle:Bundle) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: _bundle, value: "", comment: "")
    }
    
    func getAttributedStringFromHTMLString() -> NSAttributedString
    {
        do {
            let attributedString = try NSAttributedString(data: self.data(using: String.Encoding.unicode, allowLossyConversion: true)!, options: [NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.html], documentAttributes: nil)
            return attributedString
        } catch {
            //print(error)
            return NSAttributedString()
        }
    }
    
    func getHTMLString() -> String
    {
        do {
            let attributedString = try NSAttributedString(data: self.data(using: String.Encoding.unicode, allowLossyConversion: true)!, options: [NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.html], documentAttributes: nil).string
            return attributedString
        } catch {
            //print(error)
            return ""
        }
    }
    
}

// MARK: - JS VS Swift
extension WebViewController {
    
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
      
        guard let _jsonString = notification.userInfo?["_jsonString"] as? String else { return }
        
        var _jsonString_str = tranjson(str: _jsonString)
   
        DispatchQueue.main.async{
            self.mWebView.evaluateJavaScript("jsHandlerFunc(\(_jsonString_str))", completionHandler: nil)
        }
    }
    // JS呼叫Swift
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        //        print(message)//WKScriptMessage对象
        //        print(message.name) //name : nativeMethod
        //        print(message.body) //js回传参数
        if let messageBody = message.body as? [String: Any],let FuncName = messageBody["FuncName"] as? String,let Body = messageBody["body"] as? [String: Any]{
            //            let FuncName = messageBody["FuncName"] as! String{return}
            //            let command = messageBody["body"] as! String {return}
            print(FuncName)
            print(Body)
            let userInfo = Body
            let notification = Notification(name: Notification.Name.init("\(FuncName)"), object: nil, userInfo: userInfo)
            NotificationCenter.default.post(notification)
        }
    }
    // Apple 登入
    @objc func longBright(notification: Notification){
        print("longBright")
        guard let _content = notification.userInfo?["command"] as? [String:Any] else { return }
        guard let _bool = _content["0"] as? Bool else { return }
        if _bool {
            UIApplication.shared.isIdleTimerDisabled = true
        }else{
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    // Apple 登入
    @objc func loginViaApple(notification: Notification){
        guard let _content = notification.userInfo?["command"] as? [String:Any] else { return }
        if #available(iOS 13, *) {
            handleAuthorizationAppleIDButtonPress()
        }
    }
    
    // app資訊
    @objc func getAppInfo(notification: Notification) {
        let token = UserDefaults.standard.string(forKey: udk_token) ?? ""
        let os_version = DeviceInfoManager.shared.systemVersion
        let application_version = DeviceInfoManager.shared.applicationVersion
        let device = DeviceInfoManager.shared.specification
        let jsonDictionary = [_token: token, _os_version: os_version, _application_version: application_version, _device: device]
        print("----------------------getAppInfo------------------------------------")
        print(jsonDictionary)
        let _jsonData = try? JSONSerialization.data(withJSONObject: jsonDictionary, options: [])
        let _jsonString:String = String(data: _jsonData!, encoding: .utf8)!
        var userInfo: [String:Any] = [:]
        userInfo["_jsonString"] = _jsonString
       
        let notification = Notification(name: evaluateJavaScriptNotification, object: nil, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
    
    // initODM
    @objc func initODM(notification: Notification) {
        guard let _content = notification.userInfo?["command"] as? [String:Any] else { return }
        guard let _mobile = _content["0"] as? String else { print("_mobile type error"); return }
        print("_mobile:\(_mobile)")
        
        Analytics.initiateOnDeviceConversionMeasurement(phoneNumber: _mobile)
    }
    
    @objc func getAppVersion(notification: Notification) {

        let application_version = DeviceInfoManager.shared.applicationShortVersion
        print("----------------------getAppVersion------------------------------------")
        print("application_version:\(application_version)")
        var userInfo: [String:Any] = [:]
        userInfo["_jsonString"] = application_version

        let notification = Notification(name: evaluateJavaScriptNotification, object: nil, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
    
    
    
    //Icon數字設定
    @objc func setBadgeNum(notification: Notification) {
        guard let _content = notification.userInfo?["command"] as? [String:Any] else { return }
        guard let badgeNum = _content["0"] as? Int else { return }
        UIApplication.shared.applicationIconBadgeNumber = badgeNum
    }
    

    // openURL
    @objc func openUrlByBrowser(notification: Notification) {
        guard let _content = notification.userInfo?["command"] as? [String:Any] else { return }
        guard let path = _content["0"] as? String else { return }
        guard let url = URL(string: path) else { return }
        print("path:", url.path)
        DispatchQueue.main.async {
            UIApplication.shared.open(url: url)
        }
    }
    // openURL
    @objc func backgroundMusicStop() {
        print("backgroundMusicStop")
        player.pause()
    }
    // openURL
    @objc func backgroundMusicStart() {
        print("backgroundMusicStart")
         let fileUrl = Bundle.main.url(forResource: playItem, withExtension: "mp3")!
         let item = AVPlayerItem(url: fileUrl)
         looper = AVPlayerLooper(player: player, templateItem: item)
         player.play()
    }
    // openURL
    @objc func backgroundMusicVolume(notification: Notification) {
        guard let _content = notification.userInfo?["command"] as? [String:Any] else { return }
        guard let _float = _content["0"] as? Float else { return }
        player.volume = _float
    }
    // openURL
    @objc func backgroundMusicItem(notification: Notification) {
        guard let _content = notification.userInfo?["command"] as? [String:Any] else { return }
        guard let index = _content["0"] as? Int else { return }
        switch index {
        case 0 :
            playItem = "bg1"
            break;
        case 1:
            playItem = "bg2"
            break;
        default:
            playItem = "bg1"
            break;
        }
        backgroundMusicStart()
    }
}

//MARK: - transferWebData
extension WebViewController{
    // 傳輸變數(ios內部暫存)。
    @objc func iosStorage(notification: Notification) {
        guard let _content = notification.userInfo?["command"] as? [String:Any] else { return }
        guard let cbId = _content["0"] as? String else { return }
        guard let key = _content["1"] as? String else { return }
        guard let value = _content["2"] as? String else { return }
        UserDefaults.standard.set(value, forKey: "\(key)")
        var _userInfo:[String:Any]?
        if UserDefaults.standard.string(forKey: "\(key)") != nil {
            _userInfo = ["res_code": "1","res_content": ""]
        } else {
            _userInfo = ["res_code": "-1","res_content": "資料寫入失敗"]
        }
        let _jsonData = try? JSONSerialization.data(withJSONObject: _userInfo, options: [])
        let _jsonString:String = String(data: _jsonData!, encoding: .utf8)!
        var resultInfo: [String:Any] = [:]
        resultInfo["_jsonString"] = _jsonString
        resultInfo["call_back"] = cbId
        let notification = Notification(name: evaluateJavaScriptNotification, object: nil, userInfo: resultInfo)
        NotificationCenter.default.post(notification)
    }
    
    // 取得變數資料。
    @objc func getIosStorage(notification: Notification) {
//        print("getIosStorage")
        guard let _content = notification.userInfo?["command"] as? [String:Any] else { return }
        guard let cbId = _content["0"] as? String else { return }
        guard let key = _content["1"] as? String else { return }
        var _userInfo:[String:Any]?
        let transferWebData = UserDefaults.standard.string(forKey: "\(key)") ?? ""
        if transferWebData == "" {
            _userInfo = ["res_code": "-1","res_content": ""]
        }else{
            _userInfo = ["res_code": "1","res_content": "\(transferWebData)" ]
        }
//        print("transferWebData:\(transferWebData)")
        let _jsonData = try? JSONSerialization.data(withJSONObject: _userInfo, options: [])
        let _jsonString:String = String(data: _jsonData!, encoding: .utf8)!
        var resultInfo: [String:Any] = [:]
        resultInfo["_jsonString"] = _jsonString
        resultInfo["call_back"] = cbId
        let notification = Notification(name: evaluateJavaScriptNotification, object: nil, userInfo: resultInfo)
        NotificationCenter.default.post(notification)
    }
    
    // 移除變數資料。
    @objc func removeIosStorage(notification: Notification) {
        print("removeIosStorage")
        guard let _content = notification.userInfo?["command"] as? [String:Any] else { return }
        guard let key = _content["0"] as? String else { return }
        print("removeIosStorage:\(key)")
        UserDefaults.standard.removeObject(forKey: "\(key)")
    }
}


// MARK:APPLE LOGIN
@available(iOS 13, *)
extension WebViewController {
    @objc
    func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email,.fullName]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
}
@available(iOS 13, *)
extension WebViewController: ASAuthorizationControllerDelegate {
    /// - Tag: did_complete_authorization
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            print("appleIDCredential :\(appleIDCredential)")
            guard let identityToken = appleIDCredential.identityToken else { return }
            let tokenString = String(data: identityToken, encoding: .utf8)
            print("tokenString:\(tokenString)")
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName?.description
            let email = appleIDCredential.email
            var _userInfo:[String:String] = [String:String]()

            _userInfo["name"] = ""
            _userInfo["email"] = ""
            _userInfo["id"] = tokenString
            _userInfo["picture"] = ""
            let _jsonData = try? JSONSerialization.data(withJSONObject: _userInfo, options: [])
            let _jsonString:String = String(data: _jsonData!, encoding: .utf8)!
            
            var userInfo: [String:Any] = [:]
            userInfo["_jsonString"] = _jsonString
            if userIdentifier != nil {
                let notification = Notification(name: evaluateJavaScriptNotification, object: nil, userInfo: userInfo)
                NotificationCenter.default.post(notification)
            }
            

        case let passwordCredential as ASPasswordCredential:
        
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            // For the purpose of this demo app, show the password credential as an alert.
            DispatchQueue.main.async {
                self.showPasswordCredentialAlert(username: username, password: password)
            }
            
        default:
            break
        }
    }
    
    private func showPasswordCredentialAlert(username: String, password: String) {
        let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
        let alertController = UIAlertController(title: "Keychain Credential Received",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}
@available(iOS 13, *)
extension WebViewController: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension WebViewController {
   
}


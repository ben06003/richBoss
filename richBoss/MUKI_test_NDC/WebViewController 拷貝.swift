/*
 1. shouldStartLoadWith為開啟外部連結的方法。
 2. setCoreLocation為取得定位授權(並開始定位)的方法。
 3. checkoutUpdate為判斷軟體版本並提示更新的方法，須留意上架後得再次上一版，該功能才會具體有效，畢竟得要有app store的id。
 */

import Foundation
import FBSDKShareKit
import QuickLook
import AVKit

var paging_list = ["isUpdatePage": 1, "view_name": "url_link", "view_property": MUKI_iVender.WebViewProperty.main, "paging_style": MUKI_iVender.PagingStyle.tab, "view_refresh_time": 300.0, "_view_isTabBarHidden": false, "path": ""] as [String : Any]

class WebViewController: BaseVC, PDRCoreDelegate, Transform {
    
    lazy var backgroundImageView: UIImageView = {
        let _view = UIImageView(frame: self.view.bounds)
        //let _view = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width/2, height: self.view.frame.height/2))
        _view.isHidden = true
        self.view.addSubview(_view)
        return _view
    }()
    
    var _navigationBar:UINavigationBar!
    
    var _screenImg:UIImageView!
    
    var webFrame: DCloudWebView? {
        willSet {
            UserDefaults.standard.set(newValue?.name, forKey: udk_currentPage)
            //print(newValue?.frame)
            
            let _bundleIdentifier:String = Bundle.main.bundleIdentifier!
            if _bundleIdentifier != "com.muki.test" {
                if newValue?.frame.origin.y == 64 && self._navigationBar == nil {
                    self._navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 20, width: self.view.frame.height, height: 44))
                    //self._navigationBar.backgroundColor = UIColor.gray
                    self.view.addSubview(self._navigationBar)
                    self._navigationBar.pushItem(self.onMakeNavitem(), animated: true)
                }
            }
            
            
        }
    }
    var documents = [URL]()
    var playerVC: AVPlayerViewController!
    
    var _createPageBool:Bool = false
    
    var _tableView:UITableView!
    var _refreshControl:UIRefreshControl!
    var _pageNotification:Notification!
    
    var _vc:UIViewController!
    var _view:UIView!
    
    func onMakeNavitem()->UINavigationItem{
        let _navigationItem = UINavigationItem()
        let _leftBtn = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: self, action: #selector(done))
        _leftBtn.setFAIcon(icon: FAType.FAAngleLeft, iconSize: 35)
        //let _leftBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        _navigationItem.setLeftBarButton(_leftBtn, animated: true)
        return _navigationItem
    }
    
    @objc func done() {
        self._navigationBar.removeFromSuperview()
        self._navigationBar = nil
        //self.webFrame?.removeFromSuperview()
        ViewModel.shared.remove((self.webFrame?.name)!)
        
        let _info:[DCloudWebView] = ViewModel.shared.array
        let _index:Int = _info.count-1
        self.createPage(path: _info[_index].url!, name: _info[_index].name!, style: PagingStyle.tab, property: WebViewProperty.main, refresh_time: 60, isTabBarHidden: false)
        //print("")
        //print(self.view.subviews)
    }
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 延續歡迎頁
        if  self._createPageBool == false {
            if let image = self.view.takeSnapshot() {
                self.backgroundImageView.image = image
                self.backgroundImageView.isHidden = false
                self.view.bringSubview(toFront: self.backgroundImageView)
            }
        }
        self.connectionSure()
        
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
            self.startAnimating()
            ViewModel.shared.delegate = self
            self._vc = self
            self._view = self.view
            
            let _bundleIdentifier:String = Bundle.main.bundleIdentifier!
            
            if _bundleIdentifier == "com.muki.test1" {
                let _alert = Brook_Alert(_viewCtrl: self, _style: UIAlertControllerStyle.alert, _drawIcon: 0, _title: "選擇測試URL", _message: "", _cancelTitle: "取消")
                let _title:[String] = [api_reset_baseUrl, api_reset_baseUrl_2, api_reset_baseUrl_3, api_reset_baseUrl_4, api_reset_baseUrl_5]
                for _i in 0..<5 {
                    let _destructiveAlert = UIAlertAction (title: _title[_i], style: UIAlertActionStyle.default,
                                                           handler: { UIAlertAction in
                                                            self.goto(_url: _title[_i])
                    }
                    )
                    _alert._alertController.addAction(_destructiveAlert)
                }
            }else{
                self.goto(_url: api_reset_baseUrl)
            }
        }
    }
    
    func goto(_url:String) {
        if let url = URL(string: _url) {
            ClientManager.shared.getJsonObject(method: .get, url: url) {
                let json = self.toDictionary($0)
                let return_data = self.toDictionary(json["return_data"])
                let is_set = self.toInt(return_data["is_set"])
                let path = self.toString(return_data["url"])
                if let is_set = is_set, !path.isEmpty {
                    UserDefaults.standard.set(path, forKey: udk_baseUrl)
                    UserDefaults.standard.set(is_set, forKey: udk_isSet)
                } else {
                    UserDefaults.standard.set(nil, forKey: udk_baseUrl)
                    UserDefaults.standard.set(nil, forKey: udk_isSet)
                }
                DispatchQueue.main.async {
                    self.initUI(path: nil)
                }
            }
        } else {
            self.initUI(path: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.setNotificationCenter(isAdd: true)
        if self.shouldShowLaunchAnimation {
            self.shouldShowLaunchAnimation = false
            //self.triggerLaunchAnimation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        DeviceInfoManager.shared.setCoreLocation()
        self.checkoutUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.setNotificationCenter(isAdd: false)
    }
    
    // 設定螢幕為不可旋轉
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    // MARK: - function
    // 初始畫面用的方法。
    func initUI(path: String?) {
        //
        self.view.addSubview(UIView())
        
        // 建置dCloud的webView
        let pCoreHandle = PDRCore.instance()
        guard pCoreHandle != nil else { return }
        pCoreHandle?.start()
        pCoreHandle?.coreDeleagete = self
        pCoreHandle?.persentViewController = self
        // 設定layout
        // leftBarButtonItem
        let left = UIBarButtonItem(title: "返回App", style: .plain, target: self, action: #selector(self.onLeftBarButtonAction))
        self.navigationItem.leftBarButtonItem = left
        var stRect = self.view.frame
        if self.view.frame.size.height >= 812 && self.view.frame.size.height < 1024 {
            // iPhoneX
            stRect.origin.y = 44
            stRect.size.height -= 34
        } else {
            // others
            stRect.origin.y = 20
        }
        stRect.size.height -= stRect.origin.y
        // 建構PDRCoreAppFrame
        let _urlModel:UrlModel = UrlModel()
        _urlModel.getApiUrl(_baseUrl: { _url in
            var pFilePath: String {
                // 點擊推播轉址啟用
                if let url_link = iVender_url_link {
                    print(url_link)
                    return url_link
                }
                if let path = path {
                    return path
                } else {
                    return _url
                }
            }
            print(pFilePath)
            self.webFrame = ViewModel.shared.receivePage(name: "login", url: pFilePath, frame: stRect, style: .tab)
            guard self.webFrame != nil else { return }
            pCoreHandle?.appManager.activeApp.appWindow.registerFrame(self.webFrame)
            self.view.addSubview(self.webFrame!)
        })
    }
    
    @objc func pullToRefresh() {
        print("--- pullToRefresh ---")
        self._refreshControl.endRefreshing()
        self.paging(notification: self._pageNotification)
    }
    
    // 換頁，仿app原生push/pop樣式的方法。
    private func createPage(path: String, name: String, style: PagingStyle, property: WebViewProperty, refresh_time: Double, isTabBarHidden: Bool) {
        self._createPageBool = true
        let pCoreHandle = PDRCore.instance()
        guard pCoreHandle != nil else { return }
        // 設定layout
        var stRect = self.view.frame
        if self.view.frame.size.height >= 812 && self.view.frame.size.height < 1024 {
            // iPhoneX
            stRect.origin.y = 44
            stRect.size.height -= 34
        } else {
            // others
            stRect.origin.y = 20
        }
        stRect.size.height -= stRect.origin.y
        switch style {
        case .push:
            stRect.origin.x = self.view.frame.width
        case .pop:
            stRect.origin.x = -self.view.frame.width
        case .tab:
            stRect.origin.x = 0
        case .normal:
            break
        }
        
        // 建構PDRCoreAppFrame
        if let image = self.view.takeSnapshot() {
            self.backgroundImageView.image = image
            self.backgroundImageView.isHidden = false
            self.view.bringSubview(toFront: self.backgroundImageView)
        }
        
        self.webFrame?.delegate = nil
        pCoreHandle?.appManager.activeApp.appWindow.unRegisterFrame(self.webFrame)
        pCoreHandle?.coreDeleagete = nil
        pCoreHandle?.persentViewController = nil
        //self.webFrame?.removeFromSuperview()
        //self.webFrame = nil
        
        self.webFrame = ViewModel.shared.receivePage(name: name, url: path, frame: stRect, style: style, property: property)
        guard self.webFrame != nil else { return }
        self.webFrame?.delegate = self
        pCoreHandle?.appManager.activeApp.appWindow.registerFrame(self.webFrame)
        pCoreHandle?.coreDeleagete = self
        pCoreHandle?.persentViewController = self
        //self.webFrame?.isHidden = true
        self.view.addSubview(self.webFrame!)
        /*
        self._tableView = UITableView()
        self._tableView.frame = self.view.frame
        self.view.addSubview(self._tableView!)
        
        self._tableView.tableHeaderView = self.webFrame
        
        self._refreshControl = UIRefreshControl()
        //self.refreshControl.attributedTitle = NSAttributedString(string: "...")
        self._refreshControl.addTarget(self, action: #selector(self.pullToRefresh), for:.valueChanged)
        self._tableView.addSubview(self._refreshControl)
        */
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self._createPageBool = false
        }
        
        /*
        self.webFrame?.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            //print("----- isHidden isHidden isHidden isHidden-----")
            self.webFrame?.isHidden = false
        }
        */
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            //self.createPage(path: path, name: name, style: style, property: property, refresh_time: refresh_time, isTabBarHidden: isTabBarHidden)
            self.paging(notification: self._pageNotification)
        }
        */
    }
    
    private func setNotificationCenter(isAdd: Bool) {
        if isAdd {
            // 由js呼叫的loading
            NotificationCenter.default.addObserver(self, selector: #selector(self.starLoad), name: startLoadingNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.stopLoad), name: stopLoadingNotification, object: nil)
            // 由dCloud觸發的loading
            NotificationCenter.default.addObserver(self, selector: #selector(self.starLoad), name: NSNotification.Name(rawValue: PDRCoreAppFrameStartLoadNotificationKey), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.stopLoad), name: NSNotification.Name(rawValue: PDRCoreAppFrameDidLoadNotificationKey), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.failLoad), name: NSNotification.Name(rawValue: PDRCoreAppFrameLoadFailedNotificationKey), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.paging(notification:)), name: pagingNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.remove(notification:)), name: removeNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.shouldStartLoadWith(notification:)), name: shouldStartLoadNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.facebookShare(notification:)), name: facebookShareNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.applicationWillEnterForegroundNotification(notification:)), name: enterForegroundNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.openFile(notification:)), name: openFileNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.downloadFile(notification:)), name: downloadFileNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.restBaseUrl(notification:)), name: resetBaseUrl, object: nil)
        
            NotificationCenter.default.addObserver(self, selector: #selector(self.alertToas(notification:)), name: alertToastNotification, object: nil)
        } else {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    private func checkoutUpdate() {
        guard haveVersionCheck else { return }
        _ = try? VersionManager.shared.isUpdateAvailable {
            if let error = $1 { print(error); return }
            guard let update = $0, update else { return }
            guard let url = URL(string: baseUrl + api_app_update_check) else { return }
            JsonManager.sharedInstance.getJsonObject(method: .get, url: url, finish: {
                guard let jsonObject = $0 as? [String: String] else { return }
                let isForced = jsonObject["return_data"] == "1"
                self.showAlertToUpdate(isForced)
            })
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
            /*
            DispatchQueue.main.async {
                UIApplication.shared.open(url: url)
                exit(0)
            }
            */
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
        self.present(alertController, animated: true, completion: nil)
    }
    

    
    // MARK: - selector
    @objc private func restBaseUrl(notification: Notification) {
        self.alert(title: nil, message: "重置webView之url需重啟app，是否要立即結束應用程式。", confirmHandler: { _ in
            exit(0)
        })
    }
    
    @objc private func applicationWillEnterForegroundNotification(notification: Notification) {
        // 判斷是否有更新版本
        self.checkoutUpdate()
    }
    
    @objc private func remove(notification: Notification) {
        if let image = self.view.takeSnapshot() {
            self.backgroundImageView.image = image
            self.backgroundImageView.isHidden = false
            self.view.bringSubview(toFront: self.backgroundImageView)
        }
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
        self.webFrame?.addSubview(_showView)
        _showView.tag = self.webFrame!.subviews.count
        
        let _delayTime:Double = (_showTime == "long") ? 7 : 3
        
        //_ = Brook_Dispatch().delay(_delay: _delayTime, _func: {
            //print(self.webFrame!.subviews)
            for _i in 0..<self.webFrame!.subviews.count {
                let _current = self.webFrame!.subviews[_i]
                if _current is UILabel && _current.tag == _showView.tag {
                    _ = Brook_Dispatch().delay(_delay: _delayTime, _func: {
                        _current.removeFromSuperview()
                    })
                }
            }
        //})
    }
    
    @objc private func paging(notification: Notification) {
        self._pageNotification = notification
        //let callbackID = notification.userInfo?[_callbackID] as? String 
        guard let path = notification.userInfo?[_path] as? String else { return }
        guard let name = notification.userInfo?[_view_name] as? String else { return }
        guard let style = notification.userInfo?[_paging_style] as? PagingStyle else { return }
        guard let property = notification.userInfo?[_view_property] as? WebViewProperty else { return }
        guard let refresh_time = notification.userInfo?[_view_refresh_time] as? Double else { return }
        guard let isTabBarHidden = notification.userInfo?[_view_isTabBarHidden] as? Bool else { return }
        self.createPage(path: path, name: name, style: style, property: property, refresh_time: refresh_time, isTabBarHidden: isTabBarHidden)
        
        self.checkRefreshView(_delay: refresh_time, _name: name)
    }
    
    func checkRefreshView(_delay:Double, _name:String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + _delay) {
            print("----- checkRefreshView -----")
            let _currentName = UserDefaults.standard.string(forKey: udk_currentPage) ?? ""
            if _currentName != "" && _currentName != _name {
                print(_name)
                ViewModel.shared.remove((_name))
            }
        }
    }
    
    @objc private func shouldStartLoadWith(notification: Notification) {
        guard let path = notification.userInfo?[_path] as? String else { return }
        let outsideVC = OutSideVC()
        outsideVC.link = URL(string: path)
        self.navigationController?.pushViewController(outsideVC, animated: true)
    }
    
    @objc private func facebookShare(notification: Notification) {
        guard let path = notification.userInfo?[_path] as? String else { return }
        guard let url = URL(string: path) else { return }
        print(#function, path)
        let content = FBSDKShareLinkContent.init()
        content.contentURL = url
        FBSDKShareDialog.show(from: self, with: content, delegate: nil)
    }
    
    @objc private func downloadFile(notification: Notification) {
        guard let server_url = notification.userInfo?[_server_url] as? URL else { return }
        guard let device_url = notification.userInfo?[_device_url] as? URL else { return }
        self.starLoad()
        if FileManager.default.fileExists(atPath: device_url.path) {
            print("資源檔(" + device_url.lastPathComponent + ")已存在，需刪除。")
            FileHandler.shared.deleteFile(path: device_url)
        } else {
            print("資源檔(" + device_url.lastPathComponent + ")不存在，需下載。")
            FileHandler.shared.createFolder(url: device_url.deletingLastPathComponent())
        }
        JsonManager.sharedInstance.getFileData(fileURL: server_url) {
            guard let data = $0 else { return }
            self.documents.removeAll()
            self.documents.append(device_url)
            try? data.write(to: device_url)
            
            if server_url.pathExtension.lowercased() == "doc" || server_url.pathExtension.lowercased() == "docx" || server_url.pathExtension.lowercased() == "xls" || server_url.pathExtension.lowercased() == "xlsx" || server_url.pathExtension.lowercased() == "ppt" || server_url.pathExtension.lowercased() == "pptx" || server_url.pathExtension.lowercased() == "csv" || server_url.pathExtension.lowercased() == "pdf" || server_url.pathExtension.lowercased() == "txt" || server_url.pathExtension.lowercased() == "jpg" || server_url.pathExtension.lowercased() == "jpeg" || server_url.pathExtension.lowercased() == "png" {
                let qlPreviewController = QLPreviewController()
                qlPreviewController.delegate = self
                qlPreviewController.dataSource = self
                qlPreviewController.currentPreviewItemIndex = 0
                DispatchQueue.main.async {
                    if self.documents.count == 0 { return }
                    self.present(qlPreviewController, animated: true, completion: {
                        self.stopLoad()
                    })
                }
            } else {
                self.playerVC = AVPlayerViewController()
                self.playerVC.player = AVPlayer(url: device_url)
                DispatchQueue.main.async {
                    self.stopLoad()
                }
                self.present(self.playerVC, animated: true, completion: nil)
            }
        }
        return
    }
    
    
    @objc private func openFile(notification: Notification) {
//        if DeviceModel.bundleIdentifier == "com.muki.oma" {
            guard let server_url = notification.userInfo?[_server_url] as? URL else { return }
            guard let device_url = notification.userInfo?[_device_url] as? URL else { return }
            self.starLoad()
            if FileManager.default.fileExists(atPath: device_url.path) {
                print("資源檔(" + device_url.lastPathComponent + ")已存在，需刪除。")
                FileHandler.shared.deleteFile(path: device_url)
            } else {
                print("資源檔(" + device_url.lastPathComponent + ")不存在，需下載。")
                FileHandler.shared.createFolder(url: device_url.deletingLastPathComponent())
            }
            JsonManager.sharedInstance.getFileData(fileURL: server_url) {
                guard let data = $0 else { return }
                self.documents.removeAll()
                self.documents.append(device_url)
                try? data.write(to: device_url)
        
                if server_url.pathExtension.lowercased() == "doc" || server_url.pathExtension.lowercased() == "docx" || server_url.pathExtension.lowercased() == "xls" || server_url.pathExtension.lowercased() == "xlsx" || server_url.pathExtension.lowercased() == "ppt" || server_url.pathExtension.lowercased() == "pptx" || server_url.pathExtension.lowercased() == "csv" || server_url.pathExtension.lowercased() == "pdf" || server_url.pathExtension.lowercased() == "txt" || server_url.pathExtension.lowercased() == "jpg" || server_url.pathExtension.lowercased() == "jpeg" || server_url.pathExtension.lowercased() == "png" {
                    let qlPreviewController = QLPreviewController()
                    qlPreviewController.delegate = self
                    qlPreviewController.dataSource = self
                    qlPreviewController.currentPreviewItemIndex = 0
                    DispatchQueue.main.async {
                        if self.documents.count == 0 { return }
                        self.present(qlPreviewController, animated: true, completion: {
                            self.stopLoad()
                        })
                    }
                } else {
                    self.playerVC = AVPlayerViewController()
                    self.playerVC.player = AVPlayer(url: device_url)
                    DispatchQueue.main.async {
                        self.stopLoad()
                    }
                    self.present(self.playerVC, animated: true, completion: nil)
                }
            }
            return
//        }
//        guard let server_url = notification.userInfo?[_server_url] as? URL else { return }
//        guard let device_url = notification.userInfo?[_device_url] as? URL else { return }
//        let url = FileHandler.shared.path(folder: .files).appendingPathComponent(server_url.path)
//        if !FileManager.default.fileExists(atPath: url.path) {
//            self.view.vibrate()
//            return
//        }
//        if server_url.pathExtension == "doc" || server_url.pathExtension == "docx" || server_url.pathExtension == "xls" || server_url.pathExtension == "xlsx" || server_url.pathExtension == "ppt" || server_url.pathExtension == "pptx" || server_url.pathExtension == "csv" || server_url.pathExtension == "pdf" || server_url.pathExtension == "txt" || server_url.pathExtension == "jpg" || server_url.pathExtension == "jpeg" || server_url.pathExtension == "png" {
//            self.starLoad()
//            self.documents.removeAll()
//            self.documents.append(url)
//            let qlPreviewController = QLPreviewController()
//            qlPreviewController.delegate = self
//            qlPreviewController.dataSource = self
//            qlPreviewController.currentPreviewItemIndex = 0
//            DispatchQueue.main.async {
//                self.present(qlPreviewController, animated: true, completion: {
//                    self.stopLoad()
//                })
//            }
//        } else {
//            self.playerVC = AVPlayerViewController()
//            self.playerVC.player = AVPlayer(url: device_url)
//            self.present(self.playerVC, animated: true, completion: nil)
//        }
    }

    // MARK: - webView event
    @objc private func starLoad() {
        
        if !DeviceInfoManager.shared.connectedToNetwork {
//            let vc = ReloadVC()
//            vc.delegate = self
//            self.present(vc, animated: true, completion: nil)
        } else {
            if  self._createPageBool == false {
                if let image = self.view.takeSnapshot() {
                    self.backgroundImageView.image = image
                    self.backgroundImageView.isHidden = false
                    self.view.bringSubview(toFront: self.backgroundImageView)
                }
            }
            // 推播轉址需開啟
            if let path = iVender_url_link{
                paging_list["path"] = path
                let notification = Notification(name: pagingNotification, object: nil, userInfo: paging_list)
                iVender_url_link = nil
                paging(notification: notification)
            }
            self.startAnimating()
        }
    }
    
    @objc private func stopLoad() {
        let left = UIBarButtonItem(title: "返回App", style: .plain, target: self, action: #selector(self.onLeftBarButtonAction))
        self.navigationItem.leftBarButtonItem = left
        
        if  self._createPageBool == false {
            self.backgroundImageView.isHidden = true
        }
        self.stopAnimating()
    }
    
    @objc private func onLeftBarButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func failLoad() {
        self.stopAnimating()
    }
    
}

extension WebViewController: DCloudWebViewDelegate {
    
    func webViewFinishLoading(_ webView: DCloudWebView) {
        func webViewFinishLoading(_ webView: DCloudWebView) {
            self.webFrame = webView
        }
    }
    
}

extension WebViewController: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return self.documents.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.documents[index] as QLPreviewItem
    }
    
}

extension WebViewController: ViewModelDelegate {
    
    func viewModel() {
        self.backgroundImageView.isHidden = true
        self.backgroundImageView.image = nil
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

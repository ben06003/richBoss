//
//  OutSideVC.swift
//  MUKI_test_NDC
//
//  Created by smallHappy on 2017/12/12.
//  Copyright © 2017年 EICAPITAN. All rights reserved.
//

import UIKit
import WebKit

class OutSideVC: BaseVC,WKUIDelegate {
    
    var rotate:String = "top"
    var link: URL?
    var webView: WKWebView!
    // 下方橫條製作
    var bottomItem :UIView!
    var button1 :UIButton!
    var button2 :UIButton!
    var button3 :UIButton!
    var button4 :UIButton!
    var button5 :UIButton!
    var outside_rotateOrientation:UIInterfaceOrientation?
    var outside_orientation:UIInterfaceOrientationMask?
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.loadPage()
    }
    
    // MARK: - function
    override func initUI() {
        super.initUI()
        self.view.backgroundColor = UIColor.white
        //navigationItem
        let navigationItem = UINavigationItem()
        self.navigationController?.navigationBar.barStyle = .default
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.init(red: 245/255, green: 245/255, blue: 247/255, alpha: 1)
        //        self.navigationController?.navigationBar.tintColor = UIColor.darkGray
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 245/255, green: 245/255, blue: 247/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        // leftBarButtonItem
        //        self.navigationItem.leftBarButtonItem?.customView?.frame.size = CGSize(width: 30, height: 30)
        
        var leftImg = UIImage(named: "Close")
        leftImg = leftImg!.reSizeImage(reSize: CGSize(width: 20, height: 20))
        let left = UIBarButtonItem(image: leftImg, style: .plain, target: self, action: #selector(self.onLeftBarButtonAction))
        
        self.navigationItem.leftBarButtonItem = left
        self.navigationItem.leftBarButtonItem?.customView?.frame
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        
        var rightImg = UIImage(named: "Relaod")
        rightImg = rightImg!.reSizeImage(reSize: CGSize(width: 20, height: 20))
        let right = UIBarButtonItem(image: rightImg, style: .plain , target: self, action: #selector(self.onRightBarButtonAction))
        
        self.navigationItem.rightBarButtonItem = right
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
        self.markBottomItem()
        
        
        // webView
        var stRect = self.view.frame
        if self.view.frame.size.height >= 812 && self.view.frame.size.height < 1024 {
            // 瀏海機
            if DeviceInfoManager.shared.specification == "iPhone 12 mini"{
                stRect.origin.y = 50
                stRect.size.height -= 40
            }else{
                stRect.origin.y = 44
                stRect.size.height -= 34
            }
            
        } else {
            // others
            stRect.origin.y = 20
        }
        stRect.size.height -= stRect.origin.y
        
        let conf = WKWebViewConfiguration()
        //偏好设置
        conf.preferences = WKPreferences()
        //字体
        conf.preferences.minimumFontSize = 10
        //设置js跳转
        conf.preferences.javaScriptEnabled = true
        //不自动打开窗口
        conf.preferences.javaScriptCanOpenWindowsAutomatically = true
        //web内容处理池
        conf.processPool = WKProcessPool()
        //js和webview内容交互
        conf.userContentController = WKUserContentController()
        self.webView =  WKWebView(frame: stRect, configuration: conf)
        //        self.webView.scrollView.bounces = false
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        self.view.addSubview(self.webView)
        
        //        self.view.bringSubview(toFront: self.bottomItem)
        
    }
    
    private func loadPage() {
        guard let url = self.link else { return }
        let request = URLRequest(url: url)
        self.webView.load(request)
    }
    
    // MARK: - selector
    @objc private func onLeftBarButtonAction() {
        UIUtils.lockOrientation(outside_orientation!, andRotateTo: outside_rotateOrientation!)
        self.navigationController?.popViewController(animated: true)
    }
    
    func markBottomItem () {
        
        var stRect = self.view.frame
        var bottomItemY:CGFloat = 0
        if self.view.frame.size.height >= 812 && self.view.frame.size.height < 1024 {
            // 瀏海機
            bottomItemY = self.view.frame.height - 74
        } else {
            // others
            bottomItemY = self.view.frame.height - 40
        }
        
        self.bottomItem = UIView()
        self.bottomItem.frame = CGRect(x:0, y:bottomItemY, width: self.view.frame.width, height: 40)
        //        self.bottomItem.center = CGPoint(x:self.view.frame.size.width/2, y: self.view.frame.size.height)
        self.bottomItem.backgroundColor = UIColor.init(red: 245/255, green: 245/255, blue: 247/255, alpha: 0.95)
        
        self.button1 = UIButton()
        self.button1.frame.size = CGSize(width: 30, height: 30)
        self.button1.frame.origin = CGPoint(x: self.bottomItem.frame.size.width/6-20, y: 5)
        self.button1.backgroundColor = UIColor.clear
        self.button1.setImage(UIImage(named: "Left"), for: .normal)
        self.button1.tintColor = UIColor.init(red: 100/255, green: 107/255, blue: 252/255, alpha: 1)
        self.button1.addTarget(self, action: #selector(self.backWeb), for: .touchUpInside)
        self.bottomItem.addSubview(self.button1)
        
        self.button2 = UIButton()
        self.button2.frame.size = CGSize(width: 30, height: 30)
        self.button2.frame.origin = CGPoint(x: self.bottomItem.frame.size.width*2/6-20, y: 5)
        self.button2.backgroundColor = UIColor.clear
        self.button2.setImage(UIImage(named: "Right"), for: .normal)
        self.button2.tintColor = UIColor.init(red: 100/255, green: 107/255, blue: 252/255, alpha: 1)
        self.button2.addTarget(self, action: #selector(self.nextWeb), for: .touchUpInside)
        self.bottomItem.addSubview(self.button2)
        
        self.button3 = UIButton()
        self.button3.frame.size = CGSize(width: 30, height: 30)
        self.button3.frame.origin = CGPoint(x: self.bottomItem.frame.size.width*3/6-20, y: 5)
        self.button3.backgroundColor = UIColor.clear
        self.button3.setImage(UIImage(named: "Copy"), for: .normal)
        self.button3.tintColor = UIColor.init(red: 100/255, green: 107/255, blue: 252/255, alpha: 1)
        self.button3.addTarget(self, action: #selector(self.copyUrl), for: .touchUpInside)
        self.bottomItem.addSubview(self.button3)
        
        self.button4 = UIButton()
        self.button4.frame.size = CGSize(width: 30, height: 30)
        self.button4.frame.origin = CGPoint(x: self.bottomItem.frame.size.width*5/6-20, y: 5)
        self.button4.backgroundColor = UIColor.clear
        self.button4.setImage(UIImage(named: "Share"), for: .normal)
        self.button4.tintColor = UIColor.init(red: 100/255, green: 107/255, blue: 252/255, alpha: 1)
        self.button4.addTarget(self, action: #selector(self.shareUrl), for: .touchUpInside)
        self.bottomItem.addSubview(self.button4)
        
        self.button5 = UIButton()
        self.button5.frame.size = CGSize(width: 30, height: 30)
        self.button5.frame.origin = CGPoint(x: self.bottomItem.frame.size.width*4/6-20, y: 5)
        self.button5.backgroundColor = UIColor.clear
        self.button5.setImage(UIImage(named: "Web"), for: .normal)
        self.button5.tintColor = UIColor.init(red: 100/255, green: 107/255, blue: 252/255, alpha: 1)
        self.button5.addTarget(self, action: #selector(self.webOpen), for: .touchUpInside)
        self.bottomItem.addSubview(self.button5)
        
        
        self.view.addSubview(self.bottomItem)
        
        //        var stRect = self.view.frame
        //        if self.view.frame.size.height >= 812 && self.view.frame.size.height < 1024 {
        //            // 瀏海機
        //            stRect.origin.y = 44
        //            stRect.size.height -= 34
        //        } else {
        //            // others
        //            stRect.origin.y = 20
        //        }
        //        stRect.size.height -= 40
        //        stRect.size.height -= stRect.origin.y
        //
        //        self.webView.frame = stRect
    }
    
}

extension OutSideVC {
    

    @objc private func onRightBarButtonAction() {
        self.webView.reload()
    }
    
    @objc func backWeb () {
        if self.webView.canGoBack {
            self.webView.goBack()
        }
    }
    @objc func nextWeb () {
        if self.webView.canGoForward {
            self.webView.goForward()
        }
    }
    @objc func copyUrl () {
        
        
        let nowUrl = self.webView.url
        let strUrl = nowUrl!.absoluteString
        UIPasteboard.general.string = strUrl
        let copyVC = UIView()
        copyVC.frame.size = CGSize(width: 150, height: 150)
        copyVC.center = self.view.center
        copyVC.backgroundColor = UIColor.darkGray
        copyVC.layer.cornerRadius = 10
        copyVC.layer.masksToBounds = true
        copyVC.alpha = 0.7
        var copyImg = UIImage(named: "Copy")
        copyImg = copyImg?.withColor(UIColor.white)
        let imageView = UIImageView()
        imageView.frame.size = CGSize(width: 70, height: 70)
        imageView.image = copyImg
        imageView.frame.origin = CGPoint(x:40, y: 20)
        copyVC.addSubview(imageView)
        let content = "複製完成"
        let _contentSize:CGSize = content.size(OfFont: UIFont.systemFont(ofSize: 16))
        let _showView:UILabel = UILabel()
        _showView.frame.size = CGSize(width: _contentSize.width+20, height: _contentSize.height+10)
        _showView.frame.origin = CGPoint(x: (copyVC.frame.size.width - _showView.frame.size.width) / 2, y: 110)
        _showView.backgroundColor = UIColor.clear
        _showView.textColor = UIColor.white
        _showView.textAlignment = .center
        _showView.font = UIFont.systemFont(ofSize: 16)
        _showView.text = content
        _showView.layer.cornerRadius = 5
        _showView.layer.masksToBounds = true
        copyVC.addSubview(_showView)
        self.webView?.addSubview(copyVC)
        copyVC.tag = self.webView!.subviews.count
        let _delayTime:Double = 2
        
        for _i in 0..<self.webView!.subviews.count {
            
            let _current = self.webView!.subviews[_i]
            if _current is UIView && _current.tag == copyVC.tag {
                _ = Brook_Dispatch().delay(_delay: _delayTime, _func: {
                    _current.removeFromSuperview()
                })
            }
        }
        
    }
    @objc func shareUrl () {
        let nowUrl = self.webView.url
        let strUrl = nowUrl!.absoluteString
        let activityConterller = UIActivityViewController(activityItems: [strUrl], applicationActivities: [])
        present(activityConterller, animated: true, completion: nil)
    }
    
    @objc func webOpen () {
        let nowUrl = self.webView.url
        DispatchQueue.main.async {
            UIApplication.shared.open(url: nowUrl!)
        }
    }
}

extension OutSideVC: WKNavigationDelegate {
    // 網址訪問失敗
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    
    // 另外加載網站
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        return nil
    }
    
    // 網址導向之前
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
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
                self.navigationItem.title = self.webView.title
                self.stopAnimating()
            }
        }
    }
    
    // 網站載入結束
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.navigationItem.title = self.webView.title
        //        backForwardListCheck()
        self.stopAnimating()
    }
    
    //    func backForwardListCheck(){
    //        if self.webView.canGoBack {
    //            self.button1.tintColor = UIColor.white
    //        }else{
    //            self.button1.tintColor = UIColor.lightGray
    //        }
    //        if self.webView.canGoForward{
    //            self.button2.tintColor = UIColor.white
    //        }else{
    //            self.button2.tintColor = UIColor.lightGray
    //        }
    //    }
}

class UIUtils {
    //設置能夠旋轉的方向
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    //
   static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        self.lockOrientation(orientation)
        //強制改變裝置的方向
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
}

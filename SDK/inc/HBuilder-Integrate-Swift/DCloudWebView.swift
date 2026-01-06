//
//  DCloudWebView.swift
//  HBuilder-Integrate-Swift
//
//  Created by smallHappy on 2018/3/26.
//  Copyright © 2018年 EICAPITAN. All rights reserved.
//

import UIKit

protocol DCloudWebViewDelegate {
    func webViewFinishLoading(_ webView: DCloudWebView)
}

class DCloudWebView: PDRCoreAppFrame {
    
    var delegate: DCloudWebViewDelegate?
    var name: String?
    var url: String?
    var webViewProperty: WebViewProperty?
    var pagingStyle: PagingStyle?
    var CreateTime: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initUI()
    }
    
    override init!(name frameName: String!, loadURL pagePath: String!, frame: CGRect) {
        super.init(name: frameName, loadURL: pagePath, frame: frame)
        self.initUI()
    }
    
    override init!(name frameName: String!, loadURL pagePath: String!, frame: CGRect, withEngineName engineName: String!) {
        super.init(name: frameName, loadURL: pagePath, frame: frame, withEngineName: engineName)
        self.initUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("💔💔💔💔", "deinit:", self.name ?? "", "💔💔💔💔")
    }
    
    // MARK: - function
    private func initUI() {
        // 由js呼叫的loading
        NotificationCenter.default.addObserver(self, selector: #selector(self.starLoad), name: startLoadingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.stopLoad), name: stopLoadingNotification, object: nil)
        // 由dCloud觸發的loading
        NotificationCenter.default.addObserver(self, selector: #selector(self.starLoad), name: NSNotification.Name(rawValue: PDRCoreAppFrameStartLoadNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.stopLoad), name: NSNotification.Name(rawValue: PDRCoreAppFrameDidLoadNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.failLoad), name: NSNotification.Name(rawValue: PDRCoreAppFrameLoadFailedNotificationKey), object: nil)
        self.CreateTime = DateManager.shared.getNowWithFormatter()?.toString
    }
    
    // MARK: - selector
    @objc private func starLoad() {
        
    }
    
    @objc private func stopLoad() {
        UIView.animate(withDuration: 0.2, delay: 0.2, animations: {
            self.frame.origin.x = 0
        }) { _ in
            self.delegate?.webViewFinishLoading(self)
        }
    }
    
    @objc private func failLoad() {
        UIView.animate(withDuration: 0.2, delay: 0.2, animations: {
            self.frame.origin.x = 0
        }) { _ in
            self.delegate?.webViewFinishLoading(self)
        }
    }
    
    
}

//
//  OutSideVC.swift
//  HBuilder-Integrate-Swift
//
//  Created by smallHappy on 2017/12/12.
//  Copyright © 2017年 EICAPITAN. All rights reserved.
//

import UIKit

class OutSideVC: BaseVC {
    
    var link: URL?
    var webView: UIWebView!

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.loadPage()
    }
    
    // MARK: - function
    override func initUI() {
        super.initUI()
        // leftBarButtonItem
        let left = UIBarButtonItem(title: "返回App", style: .plain, target: self, action: #selector(self.onLeftBarButtonAction))
        self.navigationItem.leftBarButtonItem = left
        // webView
        var stRect = self.view.frame
        if self.view.frame.size.height == 812 {
            // iPhoneX
            stRect.origin.y = 44
//            stRect.size.height -= 34
        } else {
            // others
            stRect.origin.y = 20
        }
        stRect.size.height -= stRect.origin.y
        self.webView = UIWebView(frame: stRect)
        self.webView.scalesPageToFit = true
        self.webView.delegate = self
        self.view.addSubview(self.webView)
    }
    
    private func loadPage() {
        guard let url = self.link else { return }
        let request = URLRequest(url: url)
        self.webView.loadRequest(request)
    }
    
    // MARK: - selector
    @objc private func onLeftBarButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }

}

extension OutSideVC: UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.stopAnimating()
    }
    
}

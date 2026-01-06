//
//  LoadingView.swift
//  WebView
//
//  Created by smallHappy on 2017/2/24.
//  Copyright © 2017年 SmallHappy. All rights reserved.
//

import UIKit

/** 
 
 這是讀取動畫，view的center座標鎖定於螢幕中央，view的寬高鎖定為70，宣告後改變frame無效。
 
 兩種樣式(style)可供選擇，預設為.white。
 
 */

class LoadingAnimatingView: UIView {
    
    enum LoadingAnimatingViewStyle {
        /// 白底，灰色activityIndicator
        case white
        /// 黑底，白色activityIndicator
        case gray
    }
    /// 讀取動畫之樣式
    var style = LoadingAnimatingViewStyle.white
    
    var backgroundView: UIView!
    var activityIndicatorView: UIActivityIndicatorView!
    var isAnimating: Bool {
        return self.activityIndicatorView.isAnimating
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initUI()
    }
    
    override func layoutSubviews() {
        self.setUI()
    }
    
    //MARK: - function
    private func initUI() {
        self.backgroundColor = UIColor.clear
        self.isHidden = true
        
        self.backgroundView = UIView()
        self.backgroundView.backgroundColor = UIColor.clear
        self.backgroundView.alpha = 0.75
        self.backgroundView.layer.cornerRadius = 10
        self.addSubview(self.backgroundView)
        
        self.activityIndicatorView = UIActivityIndicatorView()
        self.activityIndicatorView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        self.activityIndicatorView.hidesWhenStopped = true
        self.activityIndicatorView.stopAnimating()
        self.addSubview(self.activityIndicatorView)
    }

    private func setUI() {
        let viewSize: CGFloat = 70
        self.frame.size = CGSize(width: viewSize, height: viewSize)
        self.center = CGPoint(x: self.superview!.frame.width / 2, y: self.superview!.frame.height / 2)
        
        self.backgroundView.frame = CGRect(x: 0, y: 0, width: viewSize, height: viewSize)
        self.activityIndicatorView.center = CGPoint(x: viewSize / 2, y: viewSize / 2)
    }
    
    func start() {
        self.isHidden = false
        self.activityIndicatorView.startAnimating()
        switch self.style {
        case .white:
//            self.backgroundView.backgroundColor = UIColor.white
            self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        case .gray:
//            self.backgroundView.backgroundColor = UIColor.black
            self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        }
    }
    
    func stop() {
        self.isHidden = true
        self.activityIndicatorView.stopAnimating()
    }
    
}

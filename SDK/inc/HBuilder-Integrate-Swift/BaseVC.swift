//
//  BaseVC.swift
//  HBuilder-Integrate-Swift
//
//  Created by smallHappy on 2017/12/12.
//  Copyright © 2017年 EICAPITAN. All rights reserved.
//

import UIKit

class BaseVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.initUI()
    }
    
    //MARK: - fcuntion
    func initUI() {
        // set mask & loadingView
        self.mask = UIView(frame: UIScreen.main.bounds)
        self.mask.backgroundColor = UIColor.black.withAlphaComponent(0.75)
//        self.view.addSubview(self.mask)
        self.loadingAnimatingView = LoadingAnimatingView()
        self.loadingAnimatingView.style = .white
        self.view.addSubview(self.loadingAnimatingView)
        self.stopAnimating()
    }
    // display launchScreen animation
    var shouldShowLaunchAnimation = true // 避免pop回rootVC時，在viewWillAppear重複顯示launchScreen。
    
    func triggerLaunchAnimation() {
        let launchVC = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateViewController(withIdentifier: "LaunchScreen") // 要記得在storyboard設定id啊
        var launchView = launchVC.view
        launchView?.frame = UIScreen.main.bounds
        self.view.addSubview(launchView!) // 加到UIWindow可能在尺寸上會更好，下列方法無法實現，待研究。
        UIView.animate(withDuration: 1.8, animations: {
            UIView.setAnimationCurve(.easeInOut)
            launchView?.alpha = 0.0
            launchView?.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
        }, completion: { _ in
            launchView?.removeFromSuperview()
            launchView = nil
        })
    }
    
    // MARK: - loadingAnimatingView event
    private var mask: UIView!
    private var loadingAnimatingView: LoadingAnimatingView!
    
    func startAnimating() {
        self.view.bringSubview(toFront: self.mask)
        self.view.bringSubview(toFront: self.loadingAnimatingView)
        self.mask.isHidden = false
        self.mask.alpha = 0.0
        UIView.animate(withDuration: 0.2, animations: {
            self.mask.alpha = 0.75
        }) { _ in
            self.loadingAnimatingView.start()
        }
        self.view.isUserInteractionEnabled = false
    }
    
    func stopAnimating() {
        UIView.animate(withDuration: 0.2, animations: {
            self.mask.alpha = 0
        }) { _ in
            self.loadingAnimatingView.stop()
        }
        self.mask.isHidden = true
        self.view.isUserInteractionEnabled = true
    }

}

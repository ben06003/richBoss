//
//  UIView+Snapshot.swift
//  GCDLCM
//
//  Created by smallHappy on 2018/7/2.
//  Copyright © 2018年 Gjun. All rights reserved.
//

import UIKit

extension UIView {
    static var key = 1
    func takeSnapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        var image = UIGraphicsGetImageFromCurrentImageContext()
        if (UIView.key == 1) {
            if self.frame.size.height == 480.0 && self.frame.size.width == 320.0 { // iphone4 4s
                image = UIImage(named: "ivendor歡迎頁640x1136")
            }
            if self.frame.size.height == 568.0 && self.frame.size.width == 320.0 { // iphone5 SE
                image = UIImage(named: "ivendor歡迎頁640x1136")
            }
            if self.frame.size.height == 667.0 && self.frame.size.width == 375.0 { // iphone8 7
                image = UIImage(named: "ivendor歡迎頁750x1334")
            }
            if self.frame.size.height == 736.0 && self.frame.size.width == 414.0 { // iphone8 7 PLUS
                image = UIImage(named: "ivendor歡迎頁1242x2208")
            }
            if self.frame.size.height == 812.0 && self.frame.size.width == 375.0 { // iphoneX Xs
                image = UIImage(named: "ivendor歡迎頁1125x2436")
            }
            if self.frame.size.height == 896.0 && self.frame.size.width == 414.0 { // iphoneXs MAX
                image = UIImage(named: "ivendor歡迎頁1242x2688")
            }
            if self.frame.size.height == 896.0 && self.frame.size.width == 414.0 { // iphoneXr
                image = UIImage(named: "ivendor歡迎頁828x1792")
            }
            if self.frame.size.height == 1024.0 && self.frame.size.width == 768.0 { // ipad 9.7
                image = UIImage(named: "ivendor歡迎頁1536x2048")
            }
            if self.frame.size.height == 1112.0 && self.frame.size.width == 824.0 { // ipad 10.5
                image = UIImage(named: "ivendor歡迎頁1536x2048")
            }
            if self.frame.size.height == 1366.0 && self.frame.size.width == 1024.0 { // ipad 12.9
                image = UIImage(named: "ivendor歡迎頁1536x2048")
            }
            if self.frame.size.height == 1194.0 && self.frame.size.width == 834.0 { // ipad 11
                image = UIImage(named: "ivendor歡迎頁1536x2048")
            }
            if self.frame.size.height == 13666.0 && self.frame.size.width == 1024.0 { // ipad 12.9 3rd
                image = UIImage(named: "ivendor歡迎頁1536x2048")
            }
            UIView.key += 1
        }
        UIGraphicsEndImageContext()
        return image
    }
    
}

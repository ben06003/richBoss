//
//  UIView+Vibrate.swift
//  MUKI_Shipgo17
//
//  Created by smallHappy on 2018/6/15.
//  Copyright © 2018年 EICAPITAN. All rights reserved.
//

import Foundation

extension UIView {
    
    func vibrate() {
        let layer = self.layer
        let p1 = CGPoint(x: layer.position.x - 2, y: layer.position.y - 2)
        let p2 = CGPoint(x: layer.position.x + 2, y: layer.position.y + 2)
        let anination = CABasicAnimation(keyPath: "position")
        anination.fromValue = NSValue.init(cgPoint: p1)
        anination.toValue = NSValue.init(cgPoint: p2)
        anination.duration = 0.03
        anination.autoreverses = true
        anination.repeatCount = 5
        self.layer.add(anination, forKey: "myFrame")
    }
    
}

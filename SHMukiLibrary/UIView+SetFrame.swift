//
//  UIView+SetFrame.swift
//  TestFloatTextFiled
//
//  Created by smallHappy on 2018/6/5.
//  Copyright © 2018年 SmallHappy. All rights reserved.
//

import UIKit

let screenW = UIScreen.main.bounds.width
let screenH = UIScreen.main.bounds.height
let gap: CGFloat = 10

extension UIView {
    
    func setFrame(x: CGFloat? = nil, y: CGFloat? = nil, width: CGFloat? = nil, height: CGFloat? = nil) {
        if let x = x {
            self.frame.origin.x = x
        }
        if let y = y {
            self.frame.origin.y = y
        }
        if let width = width {
            self.frame.size.width = width
        }
        if let height = height {
            self.frame.size.height = height
        }
    }
    
    func setOriginY(_ upperView: UIView, gap: CGFloat) {
        self.frame.origin.y = upperView.frame.maxY + gap
    }
    
    func setOriginY(_ upperView: UIView) {
        self.frame.origin.y = upperView.frame.maxY + gap
    }
    
    func setOriginX(_ leftView: UIView, gap: CGFloat) {
        self.frame.origin.x = leftView.frame.maxX + gap
    }
    
    func setOriginX(_ leftView: UIView) {
        self.frame.origin.x = leftView.frame.maxX + gap
    }
    
}

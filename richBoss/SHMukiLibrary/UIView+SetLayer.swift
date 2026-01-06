//
//  UIView+SetLayer.swift
//  TestFloatTextFiled
//
//  Created by smallHappy on 2018/6/5.
//  Copyright © 2018年 SmallHappy. All rights reserved.
//

import UIKit

extension UIView {
    
    func setEdge(cornerRadius: CGFloat = 8.0) {
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = cornerRadius
    }
    
    func setShadow() {
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.8
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
    }
    
}

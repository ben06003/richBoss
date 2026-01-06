//
//  YJDownloadingCircle.swift
//  MUKI_test_NDC
//
//  Created by mukiloong on 2019/7/9.
//  Copyright © 2019年 EICAPITAN. All rights reserved.
//

import UIKit

class MukiLoadingCircle: UIView {
    
    var loadingLayer:CAShapeLayer! = nil

    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
    }
    
    override func awakeFromNib() {
        initViews()
    }
    
    func initViews() {
        backgroundColor = UIColor.clear
        alpha = 1
    }
    
    
    func drawHalfCircle() {
        loadingLayer = self.drawCircle()
        loadingLayer.strokeStart = 0
        loadingLayer.strokeEnd = 1
        

        let basicAni = CABasicAnimation(keyPath: "strokeEnd")
        basicAni.fromValue = 0
        basicAni.toValue = 1
        basicAni.duration = 0.5
        basicAni.repeatCount = .infinity
        basicAni.autoreverses = true
        basicAni.fillMode = kCAFillModeForwards
        basicAni.isRemovedOnCompletion = false
        loadingLayer.add(basicAni, forKey: nil)
        let basicAni2 = CABasicAnimation(keyPath: "transform.rotation.z")
        basicAni2.fromValue = 0.0
        basicAni2.toValue = M_PI*2
        basicAni2.duration = 0.5
        basicAni2.repeatCount = .infinity
        basicAni2.autoreverses = false
        basicAni2.fillMode = kCAFillModeForwards
        basicAni2.isRemovedOnCompletion = false
        loadingLayer.add(basicAni2, forKey: nil)
    }
    
    private func drawCircle() -> CAShapeLayer {
        
        let circleLayer = CAShapeLayer()
        let rect = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        circleLayer.frame = rect
        circleLayer.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineWidth = 3
        circleLayer.strokeColor = UIColor.white.cgColor
        let bezier = UIBezierPath(ovalIn: rect)
        circleLayer.path = bezier.cgPath
        self.layer.addSublayer(circleLayer)
        
        return circleLayer
        
    }
    
    func start() {
        self.layer.isHidden = false
    }
    
    func stop() {
        self.layer.isHidden = true
    }
    
}

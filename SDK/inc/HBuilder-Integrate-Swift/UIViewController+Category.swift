//
//  UIViewController+Category.swift
//  Toast
//
//  Created by smallHappy on 2017/9/9.
//  Copyright © 2017年 SmallHappy. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func alert(title: String? = nil, message: String? = nil, handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "確認", style: .default, handler: handler)
        alert.addAction(confirm)
        DispatchQueue.main.async { self.present(alert, animated: true, completion: nil) }
    }
    
    func alert(title: String? = nil, message: String? = nil, cancelHandler: ((UIAlertAction) -> Void)? = nil, confirmHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style: .default, handler: cancelHandler)
        alert.addAction(cancel)
        let confirm = UIAlertAction(title: "確認", style: .default, handler: confirmHandler)
        alert.addAction(confirm)
        DispatchQueue.main.async { self.present(alert, animated: true, completion: nil) }
    }
    
}

extension UIViewController {
    
    enum ToastLength: Double {
        case long = 3.5, short = 2.0
    }
    
    enum ToastStyle {
        case label, view
    }
    
    func toast(style: ToastStyle = .view, message: String, length: ToastLength = .short) {
        let frameW = self.view.frame.width
        let frameH = self.view.frame.height
        let gap: CGFloat = 10
        let labelH: CGFloat = 21
        switch style {
        case .label:
            // setUI
            let label = UILabel(frame: CGRect(x: 0, y: frameH - labelH - gap, width: frameW, height: labelH))
            label.text = message
            label.textColor = UIColor.darkGray
            label.textAlignment = .center
            self.view.addSubview(label)
            // animating
            label.transform = CGAffineTransform(translationX: 0, y: labelH + gap)
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                label.transform = CGAffineTransform.identity
            }, completion: { (isFinish) in
                UIView.animate(withDuration: length.rawValue, animations: {
                    label.alpha = 0.0
                }, completion: { (isFinish) in
                    label.removeFromSuperview()
                })
            })
        case .view:
            // setUI
            let viewH = labelH + gap * 2
            let _view = UIView(frame: CGRect(x: gap, y: frameH - viewH - gap, width: frameW - gap * 2, height: viewH))
            _view.backgroundColor = UIColor.black
            _view.alpha = 0.85
            _view.layer.cornerRadius = 8.0
            self.view.addSubview(_view)
            let label = UILabel(frame: CGRect(x: gap * 2, y: frameH - labelH - gap * 2, width: frameW - gap * 4, height: labelH))
            label.text = message
            label.textColor = UIColor.white
            label.textAlignment = .center
            self.view.addSubview(label)
            // animating
            _view.transform = CGAffineTransform(translationX: 0, y: viewH + gap)
            label.transform = CGAffineTransform(translationX: 0, y: labelH + gap * 2)
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                _view.transform = CGAffineTransform.identity
                label.transform = CGAffineTransform.identity
            }, completion: { (isFinish) in
                UIView.animate(withDuration: length.rawValue, animations: {
                    _view.alpha = 0.0
                    label.alpha = 0.0
                }, completion: { (isFinish) in
                    _view.removeFromSuperview()
                    label.removeFromSuperview()
                })
            })
        }
    }
    
}

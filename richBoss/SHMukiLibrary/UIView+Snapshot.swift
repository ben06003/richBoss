//
//  UIView+Snapshot.swift
//  GCDLCM
//
//  Created by smallHappy on 2018/7/2.
//  Copyright © 2018年 Gjun. All rights reserved.
//

import UIKit

extension UIView {
    
    func takeSnapshot() -> UIImage? {
        
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return image
    }
    
}

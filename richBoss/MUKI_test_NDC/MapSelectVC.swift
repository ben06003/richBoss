//
//  OutSideVC.swift
//  MUKI_test_NDC
//
//  Created by smallHappy on 2017/12/12.
//  Copyright © 2017年 EICAPITAN. All rights reserved.
//

import UIKit
import MapKit

class MapSelectVC: UIView,UIGestureRecognizerDelegate {
    
    var end_latitude:Double = 0.0
    var end_longitude:Double = 0.0
    var _start_latitude:Double = 0.0
    var _start_longitude:Double = 0.0
    
     func createMapSelect(){
        let mask = UIView(frame: UIScreen.main.bounds)
        mask.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        let _view1:UIView = UIView()
        let tap:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tapBtnAndcancelBtnClick))
        tap.delegate = self
        mask.addGestureRecognizer(tap)
        _view1.backgroundColor = UIColor.white
//        print("\(self.frame.size.width-100),\(self.frame.size.width/2-50),\(self.frame.size.height/2-25)")
        _view1.frame.size = CGSize(width:  self.frame.size.width-150, height: 120)
        _view1.frame.origin = CGPoint(x: 75, y: self.frame.size.height/2-60)
        _view1.layer.shadowRadius = 8
        _view1.layer.cornerRadius = 8
//        _view1.layer.borderColor = UIColor.blue.cgColor
//        _view1.layer.borderWidth = 2
        
        let ios_button:UIButton = UIButton()
        ios_button.setImage(UIImage(named: "IOSMap"), for: UIControlState.normal)
        ios_button.frame.size = CGSize(width: 80, height: 80)
        ios_button.frame.origin = CGPoint(x: (_view1.frame.size.width/2-80)/2, y: 20)
        ios_button.addTarget(self, action: #selector(self.openMap), for: .touchUpInside)
        _view1.addSubview(ios_button)
        
        let google_button:UIButton = UIButton()
        google_button.setImage(UIImage(named: "GoogleMap.png"), for: UIControlState.normal)
        google_button.frame.size = CGSize(width: 80, height: 80)
        google_button.frame.origin = CGPoint(x: _view1.frame.size.width-(_view1.frame.size.width/2-80)/2-80 , y: 20)
        google_button.addTarget(self, action: #selector(self.openGoogleMap), for: .touchUpInside)
        _view1.addSubview(google_button)
        
        mask.addSubview(_view1)
        self.addSubview(mask)
    }
    
    @objc func openGoogleMap(){
        print("openGoogleMap")
        UIApplication.shared.openURL(URL(string:"comgooglemaps://?saddr=\(_start_latitude),\(_start_longitude)&daddr=\(end_latitude),\(end_longitude)&directionsmode=driving")!)
        self.removeFromSuperview()
    }
    
    @objc func openMap(){
        print("openMap")
        let start_placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: _start_latitude, longitude: _start_longitude))
        let start = MKMapItem(placemark: start_placemark)
        start.name = "我的位置"
        let end_placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: end_latitude, longitude: end_longitude))
        let end = MKMapItem(placemark: end_placemark)
        end.name = "目的地"
        let mapItems = [start, end]
        let options = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving as AnyObject, // 導航模式：開車
            MKLaunchOptionsMapTypeKey: MKMapType.standard.rawValue as AnyObject, // 地圖樣式：標準
            MKLaunchOptionsShowsTrafficKey: true as AnyObject // 顯示交通：是
        ]
        MKMapItem.openMaps(with: mapItems, launchOptions: options)
        self.removeFromSuperview()
    }
    
    //移除或者中断进度
    @objc func tapBtnAndcancelBtnClick() {
                self.removeFromSuperview()
        //        displayLink.invalidate()
        //        displayLink = nil
    }
}

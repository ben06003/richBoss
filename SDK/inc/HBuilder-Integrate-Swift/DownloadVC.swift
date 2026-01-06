//
//  DownloadVC.swift
//  HBuilder-Integrate-Swift
//
//  Created by KangShuo on 2018/10/13.
//  Copyright © 2018 EICAPITAN. All rights reserved.
//

import UIKit

class DownloadVC:UIView {
    
    
    var _bgView:UIView!
    var _progressView:UIProgressView!
    
    var _filesTitle:UILabel!
    var _filesValue:Int! {
        get {
            return self._filesValue
        }
        set {
            //var _str:String = String(newValue)
            self._filesTitle.text = "還有 "+String(newValue)+" 個檔案"
        }
    }
    
    var _downloadTitle:UILabel!
    var _downloadValue:String! {
        get {
            return self._downloadValue
        }
        set {
            //var _str:String = String(newValue)
            self._downloadTitle.text = "正在下載檔案 "+newValue
        }
    }
    
    var _comCount:Int!
    /*
    {
        get {
            return self._comCount
        }
        set {
            //var _str:String = String(newValue)
            self._allCountTitle.text = String(newValue)+" / "+String(self._allCount)
        }
    }
    */
    var _allCount:Int!
    /*
    {
        get {
            return self._allCount
        }
        set {
            //var _str:String = String(newValue)
            
            self._allCountTitle.text = String(self._comCount)+" / "+String(newValue)
        }
    }
    */
    var _allCountTitle:UILabel!
    
    var _percentTitle:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func create(_files:[String]) {
        //let _appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        //let _webViewController:WebViewController = _appDelegate.window?.rootViewController?.childViewControllers[0] as! WebViewController
        
        
        self._bgView = UIView()
        self._bgView.backgroundColor = UIColor.white
        self._bgView.frame.size = CGSize(width: self.frame.width*0.9, height: self.frame.height*0.5)
        self._bgView.center = self.center
        self._bgView.layer.cornerRadius = 5
        self.addSubview(self._bgView)
        
        self._filesTitle = UILabel()
        _filesTitle.frame.size = CGSize(width: self._bgView.frame.width*0.8, height: 30)
        _filesTitle.frame.origin = CGPoint(x: self._bgView.frame.width*0.1, y: 20)
        _filesTitle.font = UIFont.boldSystemFont(ofSize: 16)
        //_filesTitle.text = "還有 "+String(_files.count)+" 個檔案"
        self._bgView.addSubview(_filesTitle)
        self._filesValue = _files.count
        
        self._downloadTitle = UILabel()
        _downloadTitle.frame.size = CGSize(width: self._bgView.frame.width*0.8, height: 30)
        _downloadTitle.frame.origin = CGPoint(x: self._bgView.frame.width*0.1, y: 60)
        _downloadTitle.font = UIFont.systemFont(ofSize: 14)
        //_downloadTitle.text = "正在下載檔案"
        self._bgView.addSubview(_downloadTitle)
        
        self._progressView = UIProgressView(progressViewStyle:UIProgressView.Style.default)
        //self._progressView.frame = CGRect(x: 0, y: 0, width: _width, height: 0)//(0, 0, _width, 0)
        self._progressView.frame.size = CGSize(width: self._bgView.frame.width*0.8, height: 0)
        self._progressView.frame.origin = CGPoint(x: self._bgView.frame.width*0.1, y: self._downloadTitle.frame.maxY+50)
        //self._progressView.center = CGPoint(x: self._bgView.center.x, y: self._bgView.frame.height-70)
        //self._progressView.progress=0.5 //默认进度50%
        //(横 1.0倍,縦 2.0倍).
        //self._progressView.transform = CGAffineTransformMakeScale(1.0, 2.0)
        self._bgView.addSubview(self._progressView)
        
        self._allCountTitle = UILabel()
        _allCountTitle.frame.size = CGSize(width: self._bgView.frame.width*0.5, height: 30)
        _allCountTitle.frame.origin = CGPoint(x: self._bgView.frame.width*0.1, y: self._progressView.frame.maxY+20)
        _allCountTitle.font = UIFont.systemFont(ofSize: 14)
        _allCountTitle.text = "0 / 0"
        self._bgView.addSubview(self._allCountTitle)
        
        self._percentTitle = UILabel()
        _percentTitle.frame.size = CGSize(width: self._bgView.frame.width*0.5, height: 30)
        _percentTitle.frame.origin = CGPoint(x: self._bgView.frame.width*0.8, y: self._progressView.frame.maxY+20)
        _percentTitle.font = UIFont.systemFont(ofSize: 14)
        _percentTitle.text = "%"
        self._bgView.addSubview(self._percentTitle)
        
        self._allCount = _files.count
        self._comCount = 0
        
        let _cancelBtn:UIButton = UIButton()
        _cancelBtn.frame.size = CGSize(width: 50, height: 30)
        _cancelBtn.frame.origin = CGPoint(x: self._bgView.frame.maxX-100, y: self._bgView.frame.height-40)
        _cancelBtn.backgroundColor = UIColor.clear
        _cancelBtn.setTitle( "取消", for: UIControlState.normal)//普通狀態下的文字
        _cancelBtn.setTitleColor( UIColor.black, for: .normal) //普通狀態下文字的顏色
        _cancelBtn.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
        //_cancelBtn.backgroundColor = UIColor.gray
        self._bgView.addSubview(_cancelBtn)
        
    }
    
    @objc func cancelAction() {
        print("")
        self.removeFromSuperview()
    }
    
}

//
//  QRCodeVC.swift
//  HBuilder-Integrate-Swift
//
//  Created by KangShuo on 2018/9/30.
//  Copyright © 2018 EICAPITAN. All rights reserved.
//

import UIKit
import AVFoundation

class QRCodeVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate ,UIAlertViewDelegate {
    
    var scanRectView:UIView!
    var device:AVCaptureDevice!
    var input:AVCaptureDeviceInput!
    var output:AVCaptureMetadataOutput!
    var session:AVCaptureSession!
    var preview:AVCaptureVideoPreviewLayer!
    
    var _completeFunc:((String)->())!
    
    var _msgStr:String!
    var _image:UIImage!
    var _img:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func create(_imgURL:String, _msgStr:String) {
        
        self._msgStr = _msgStr
        
        let _appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        //print(_appDelegate.window?.rootViewController?.childViewControllers)
        let _webViewController:WebViewController = _appDelegate.window?.rootViewController?.childViewControllers[0] as! WebViewController
        _webViewController.addChildViewController(self)
        self.didMove(toParentViewController: _webViewController)
        _webViewController.view.insertSubview(self.view, at: _webViewController.view.subviews.count)
        
        _ = Brook_LinkHTTP().link( _httpMethod: .get, _returnType: .Data, _url: _imgURL, _alertShow: true, _testSpeedBool: false,
            _errorFunc: {
                print("-- _img ERROR --")
            },
            _completefFunc: { (_data) in
                //print("_dict = \(_dict)")
                //_action(_dict as! NSDictionary)
                print("-- _img --")
                self._image = UIImage(data: _data as! Data)!
                //print(self._image.size)
                //print("")
                
                var _size:CGSize = self._image.size
                
                if self._image.size.height > 50 {
                   _size = CGSize(width: (self._image.size.width/self._image.size.height)*50, height: 50)
                }
                
                self._img.frame.size = _size
                self._img.center = CGPoint(x: self.view.center.x, y: 70)
                self._img.image = self._image
            }
        )
    }
    
    //通過攝像頭掃描
    func fromCamera(_completeFunc:@escaping ((String)->())) {
        do{
            self._completeFunc = _completeFunc
            
            self.device = AVCaptureDevice.default(for: AVMediaType.video)
            
            self.input = try AVCaptureDeviceInput(device: self.device)
            
            self.output = AVCaptureMetadataOutput()
            self.output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            self.session = AVCaptureSession()
            if UIScreen.main.bounds.size.height<500 {
                self.session.sessionPreset = AVCaptureSession.Preset.vga640x480
            }else{
                self.session.sessionPreset = AVCaptureSession.Preset.high
            }
            
            self.session.addInput(self.input)
            self.session.addOutput(self.output)
            
            self.output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            //計算中間可探測區域
            let windowSize = UIScreen.main.bounds.size
            let scanSize = CGSize(width:windowSize.width*3/4, height:windowSize.width*3/4)
            var scanRect = CGRect(x:(windowSize.width-scanSize.width)/2,
                                  y:(windowSize.height-scanSize.height)/2,
                                  width:scanSize.width, height:scanSize.height)
            //計算rectOfInterest注意x，y交換位置
            scanRect = CGRect(x:scanRect.origin.y/windowSize.height,
                              y:scanRect.origin.x/windowSize.width,
                              width:scanRect.size.height/windowSize.height,
                              height:scanRect.size.width/windowSize.width)
            //設置可探測區域
            self.output.rectOfInterest = scanRect
            
            self.preview = AVCaptureVideoPreviewLayer(session:self.session)
            self.preview.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.preview.frame = UIScreen.main.bounds
            self.view.layer.insertSublayer(self.preview, at:0)
            
            //添加中間的探測區域綠框
            self.scanRectView = UIView()
            self.view.addSubview(self.scanRectView)
            self.scanRectView.frame = CGRect(x:0, y:0, width:scanSize.width,height:scanSize.height)
            self.scanRectView.center = CGPoint( x:UIScreen.main.bounds.midX,y:UIScreen.main.bounds.midY)
            self.scanRectView.layer.borderColor = UIColor.red.cgColor
            self.scanRectView.layer.borderWidth = 1
            
            let _view:UIView = UIView()
            _view.frame = self.view.frame
            _view.backgroundColor = UIColor.black
            self.view.addSubview(_view)
            
            let mask = CAShapeLayer()
            let path = UIBezierPath()
            mask.fillColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5).cgColor
            
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: self.scanRectView.frame.origin.y))
            path.addLine(to: CGPoint(x: self.view.frame.width, y: self.scanRectView.frame.origin.y))
            path.addLine(to: CGPoint(x: self.view.frame.width, y: 0))
            
            path.move(to: CGPoint(x: 0, y: self.scanRectView.frame.origin.y))
            path.addLine(to: CGPoint(x: 0, y: self.scanRectView.frame.maxY))
            path.addLine(to: CGPoint(x: self.scanRectView.frame.origin.x, y: self.scanRectView.frame.maxY))
            path.addLine(to: CGPoint(x: self.scanRectView.frame.origin.x, y: self.scanRectView.frame.origin.y))
            
            path.move(to: CGPoint(x: self.view.frame.width-self.scanRectView.frame.origin.x, y: self.scanRectView.frame.origin.y))
            path.addLine(to: CGPoint(x: self.view.frame.width-self.scanRectView.frame.origin.x, y: self.scanRectView.frame.maxY))
            path.addLine(to: CGPoint(x: self.view.frame.width, y: self.scanRectView.frame.maxY))
            path.addLine(to: CGPoint(x: self.view.frame.width, y: self.scanRectView.frame.origin.y))
            
            path.move(to: CGPoint(x: 0, y: self.scanRectView.frame.maxY))
            path.addLine(to: CGPoint(x: 0, y: self.view.frame.height))
            path.addLine(to: CGPoint(x: self.view.frame.width, y: self.view.frame.height))
            path.addLine(to: CGPoint(x: self.view.frame.width, y: self.scanRectView.frame.maxY))
            
            path.move(to: CGPoint(x: self.scanRectView.frame.origin.x-5, y: self.scanRectView.frame.origin.y-5))
            path.addLine(to: CGPoint(x: self.scanRectView.frame.origin.x-5, y: self.scanRectView.frame.origin.y))
            path.addLine(to: CGPoint(x: self.scanRectView.frame.origin.x+55, y: self.scanRectView.frame.origin.y))
            path.addLine(to: CGPoint(x: self.scanRectView.frame.origin.x+55, y: self.scanRectView.frame.origin.y-5))
            
            path.close()
            mask.path = path.cgPath
            _view.layer.mask = mask
            /*
            let mask = CALayer()
            mask.frame = self.scanRectView.frame
            mask.backgroundColor = UIColor.clear.cgColor//UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1).cgColor
            _view.layer.mask = mask
            */
            
            let _line_1:UIView = UIView()
            _line_1.backgroundColor = UIColor.white
            _line_1.frame.size = CGSize(width: 50, height: 7)
            _line_1.frame.origin = CGPoint(x: self.scanRectView.frame.origin.x-7, y: self.scanRectView.frame.origin.y-7)
            self.view.addSubview(_line_1)
            let _line_2:UIView = UIView()
            _line_2.backgroundColor = UIColor.white
            _line_2.frame.size = CGSize(width: 7, height: 43)
            _line_2.frame.origin = CGPoint(x: self.scanRectView.frame.origin.x-7, y: self.scanRectView.frame.origin.y)
            self.view.addSubview(_line_2)
            
            let _line_3:UIView = UIView()
            _line_3.backgroundColor = UIColor.white
            _line_3.frame.size = CGSize(width: 50, height: 7)
            _line_3.frame.origin = CGPoint(x: self.scanRectView.frame.maxX-43, y: self.scanRectView.frame.origin.y-7)
            self.view.addSubview(_line_3)
            let _line_4:UIView = UIView()
            _line_4.backgroundColor = UIColor.white
            _line_4.frame.size = CGSize(width: 7, height: 43)
            _line_4.frame.origin = CGPoint(x: self.scanRectView.frame.maxX, y: self.scanRectView.frame.origin.y)
            self.view.addSubview(_line_4)
            
            let _line_5:UIView = UIView()
            _line_5.backgroundColor = UIColor.white
            _line_5.frame.size = CGSize(width: 50, height: 7)
            _line_5.frame.origin = CGPoint(x: self.scanRectView.frame.origin.x-7, y: self.scanRectView.frame.maxY)
            self.view.addSubview(_line_5)
            let _line_6:UIView = UIView()
            _line_6.backgroundColor = UIColor.white
            _line_6.frame.size = CGSize(width: 7, height: 43)
            _line_6.frame.origin = CGPoint(x: self.scanRectView.frame.origin.x-7, y: self.scanRectView.frame.maxY-43)
            self.view.addSubview(_line_6)
            
            let _line_7:UIView = UIView()
            _line_7.backgroundColor = UIColor.white
            _line_7.frame.size = CGSize(width: 50, height: 7)
            _line_7.frame.origin = CGPoint(x: self.scanRectView.frame.maxX-43, y: self.scanRectView.frame.maxY)
            self.view.addSubview(_line_7)
            let _line_8:UIView = UIView()
            _line_8.backgroundColor = UIColor.white
            _line_8.frame.size = CGSize(width: 7, height: 43)
            _line_8.frame.origin = CGPoint(x: self.scanRectView.frame.maxX, y: self.scanRectView.frame.maxY-43)
            self.view.addSubview(_line_8)
            
            
            self._img = UIImageView()
            self.view.addSubview(self._img)
            
            let _tips:UILabel = UILabel()
            _tips.frame.size = CGSize(width: scanSize.width, height: 30)
            _tips.frame.origin = CGPoint(x: self.scanRectView.frame.minX, y: self.scanRectView.frame.maxY+30)
            _tips.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
            _tips.textAlignment = .center
            _tips.textColor = UIColor.white
            _tips.text = self._msgStr
            _tips.layer.cornerRadius = 5
            _tips.layer.masksToBounds = true
            self.view.addSubview(_tips)
            
            let _cancelBtn:UIButton = UIButton()
            _cancelBtn.frame.size = CGSize(width: 70, height: 40)
            _cancelBtn.frame.origin = CGPoint(x: 0, y: 30)
            _cancelBtn.backgroundColor = UIColor.clear
            _cancelBtn.setTitle( "取消", for: UIControlState.normal)//普通狀態下的文字
            _cancelBtn.setTitleColor( UIColor.white, for: .normal) //普通狀態下文字的顏色
            _cancelBtn.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
            self.view.addSubview(_cancelBtn)
            
            //開始捕獲
            self.session.startRunning()
            
        }catch _ {
            //打印錯誤消息
            let alertController = UIAlertController(title: "提醒",message: "請在iPhone的\"設置 - 隱私 - 相機\"選項中,允許訪問您的相機",preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "確定", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func cancelAction() {
        //print(self.parent?.childViewControllers)
        self.parent?.childViewControllers[0].view.removeFromSuperview()
        self.parent?.childViewControllers[0].removeFromParentViewController()
    }
    
    //攝像頭捕獲
    func metadataOutput(_ output: AVCaptureMetadataOutput,didOutput metadataObjects: [AVMetadataObject],from connection: AVCaptureConnection) {
        var stringValue:String?
        if metadataObjects.count > 0 {
            let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            stringValue = metadataObject.stringValue
            
            if stringValue != nil{
                self.session.stopRunning()
            }
        }
        self.session.stopRunning()
        //輸出結果
        /*
        let alertController = UIAlertController(title: "QRCode", message: stringValue, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default, handler: {
            action in
            //繼續掃描
            self.session.startRunning()
        })
 
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        */
        self._completeFunc(stringValue ?? "")
        self.cancelAction()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//連線HTTP
enum httpMethod:String {
    case post = "POST"
    case get = "GET"
    case put = "PUT"
    case delete = "DELETE"
}
enum returnType {
    case JSON
    case Data
}
class Brook_LinkHTTP {
    
    fileprivate var _task:URLSessionDataTask!
    fileprivate var _dispatch:Brook_Dispatch!
    //var _alert:UIAlertView!
    
    var _loadingView:Brook_LoadingView!
    //var _testSpeed:CFTimeInterval!
    
    deinit{
        self._task = nil
        self._dispatch = nil
        self._loadingView = nil
        //self._testSpeed = nil
        //self._alert = nil
    }
    
    init() {
        self._dispatch = Brook_Dispatch()
        //self._alert = UIAlertView(title: nil, message: nil, delegate: nil, cancelButtonTitle: nil)
        //print("======= \(UIApplication.shared.windows)")
        
    }
    
    func cancel() {
        self._task.cancel()
    }
    
    func link(_delay:Double?=20, _httpMethod:httpMethod, _returnType:returnType, _url:String, _headers:[String]?=nil, _postStr:String?=nil, _userAgentBool:Bool?=true, _alertShow:Bool, _testSpeedBool:Bool?=false, _errorFunc:(()->())?=nil, _completefFunc:@escaping (_ _anyObj:AnyObject)->()) {
        
        //let userAgent = UIWebView().stringByEvaluatingJavaScript(from: "navigator.userAgent")!// + "mobile"
        //print("userAgent = \(userAgent)")
        //UserDefaults.standard.register(defaults: ["UserAgent": userAgent])
        
        let _start:CFTimeInterval = CACurrentMediaTime()
        var _end:CFTimeInterval = _start
        //print("測量時間：\(_end-_start)")
        
        print("_url = \(_url)")
        
        if _alertShow == true {
            //self._alert.show()
            self._loadingView = Brook_LoadingView(_view: UIApplication.shared.windows[0])
            self._loadingView.show()
        }
        
        var _checkBol = false
        let _request = NSMutableURLRequest(url: NSURL(string: _url)! as URL)
        
        _request.httpMethod = _httpMethod.rawValue
        
        print("_postStr = \(String(describing: _postStr))")
        _request.httpBody = _postStr?.data(using: String.Encoding.utf8)
        
        if _headers != nil {
            print("_headers = \(String(describing: _headers))")
            let _count = _headers!.count
            for _i in 0..<_count {
                if _i % 2 == 0 {
                    _request.addValue((_headers![_i+1]), forHTTPHeaderField: (_headers![_i]))
                }
            }
            //UserDefaults.standard.register(defaults: ["UserAgent": "Mobile"])
            //let userAgent = UIWebView().stringByEvaluatingJavaScript(from: "navigator.userAgent")!// + "mobile"
            //print("userAgent = \(userAgent)")
            //UserDefaults.standard.register(defaults: ["UserAgent": userAgent])
            //_request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        }
        //_request.addValue("zh-TW", forHTTPHeaderField: "localize")
        //_request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if _userAgentBool == true {
            let _userAgent = UIWebView().stringByEvaluatingJavaScript(from: "navigator.userAgent")!
            _request.addValue(_userAgent, forHTTPHeaderField: "User-Agent")
        }
        
        self._task = URLSession.shared.dataTask(with: _request as URLRequest) { data, response, error in
            
            if error != nil {
                print(">>>>> error_1 <<<<<")
                _checkBol = true
                //print("error = \(String(describing: error))")
                self._dispatch.one {
                    if self._loadingView != nil {
                        self._loadingView.notShow()
                        self._loadingView = nil
                    }
                    _errorFunc!()
                }
                //if _alertShow == true { self._alert.dismiss(withClickedButtonIndex: -1, animated: true) }
                return
            }
            
            //print("self._task = \(self._task.originalRequest?.allHTTPHeaderFields)")
            //print("self._task = \(self._task.currentRequest?.allHTTPHeaderFields)")
            //print("response = \(response)")
            do {
                if _returnType == .JSON {
                    if let _jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                        //print("_jsonResult = \(_jsonResult)")
                        //self._alert.dismiss(withClickedButtonIndex: -1, animated: true)
                        _checkBol = true
                        self._dispatch.one {
                            if self._loadingView != nil {
                                self._loadingView.notShow()
                                self._loadingView = nil
                            }
                            //測量時間
                            if _testSpeedBool == true {
                                _end = CACurrentMediaTime()
                                let _testSpeed:CFTimeInterval = _end-_start
                                print("測量時間：\(_testSpeed)")
                                //_jsonResult[_url] = self._testSpeed
                                let _dict:NSDictionary = (_jsonResult as AnyObject) as! NSDictionary
                                var _dictionary:[String:AnyObject] = [String:AnyObject]()
                                for (_k, _v) in _dict {
                                    print(_k, _v)
                                    _dictionary[_k as! String] = _v as AnyObject
                                }
                                _dictionary["url"] = _url as AnyObject
                                _dictionary["timer"] = _testSpeed as AnyObject
                                _completefFunc(_dictionary as AnyObject)
                                return
                            }
                            _completefFunc(_jsonResult)
                        }
                    }
                }else if _returnType == .Data {
                    //self._alert.dismiss(withClickedButtonIndex: -1, animated: true)
                    _checkBol = true
                    self._dispatch.one {
                        if self._loadingView != nil {
                            self._loadingView.notShow()
                            self._loadingView = nil
                        }
                        _completefFunc(data as AnyObject)
                    }
                }
            } catch {
                print(">>>>> error_2 <<<<<")
                _checkBol = true
                //print("error = \(response, error)")
                self._dispatch.one {
                    if self._loadingView != nil {
                        self._loadingView.notShow()
                        self._loadingView = nil
                    }
                    _errorFunc!()
                }
                //if _alertShow == true { self._alert.dismiss(withClickedButtonIndex: -1, animated: true) }
                
            }
            
        }
        self._task.resume()
        
        //連線逾時
        
        self._dispatch.delay(_delay: _delay!, _func: {
            if _checkBol == false {
                print("---------- 連線逾時 ----------")
                self._task.cancel()
                _errorFunc!()
                //self._alert.dismiss(withClickedButtonIndex: -1, animated: true)
                //_ = Brook_Alert(_viewCtrl: _viewCtrl, _style: UIAlertControllerStyle.Alert, _drawIcon: 3, _title: " ", _message: "\n\n"+"连线逾时", _defaultTitle: "重新连线", _defaultTAction: _errorFunc)
            }
        })
        
    }
    
}

//讀取中頁面
class Brook_LoadingView {
    
    var _alphaView:UIView!
    var _actInd:UIActivityIndicatorView!
    
    deinit {
        self._alphaView = nil
        self._actInd = nil
    }
    
    //預設notShow
    init(_view:UIView) {
        let _width = UIScreen.main.bounds.width
        let _height = UIScreen.main.bounds.height
        
        self._alphaView = UIView(frame: CGRect(x: 0, y: 0, width: _width, height: _height))
        self._alphaView.center = _view.center
        self._alphaView.backgroundColor = UIColor.black
        //UIColor.greenColor().setFill()
        self._alphaView.alpha = 0.2
        self._alphaView.isHidden = true
        let _path = UIBezierPath(rect: self._alphaView.bounds)
        _path.fill()
        _view.addSubview(self._alphaView)
        //self._alphaView.layer.cornerRadius = 40 //圓角
        //view.layer.cornerRadius = view.frame.width/2.0
        
        self._actInd = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100)) as UIActivityIndicatorView
        self._actInd.center = _view.center
        self._actInd.hidesWhenStopped = true
        self._actInd.activityIndicatorViewStyle = UIActivityIndicatorView.Style.whiteLarge
        self._actInd.isHidden = true
        _view.addSubview(self._actInd)
        
    }
    
    func show() {
        self._actInd.isHidden = false
        self._actInd.startAnimating()
        self._alphaView.isHidden = false
        //self._touchView.hidden = false
    }
    
    func notShow() {
        self._actInd.isHidden = true
        self._actInd.stopAnimating()
        self._alphaView.isHidden = true
        //self._touchView.hidden = true
    }
    
}

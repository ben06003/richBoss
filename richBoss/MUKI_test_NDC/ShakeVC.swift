//
//  QRCodeVC.swift
//  HBuilder-Integrate-Swift
//
//  Created by KangShuo on 2018/9/30.
//  Copyright © 2018 EICAPITAN. All rights reserved.
//
import CoreMotion
import UIKit
import AVFoundation

class ShakeVC: UIViewController{
    
    var scanRectView:UIView!
    var shakeValue:Bool!
    var shakeIndex:Double!
    var shakeIndexList = [0.01,0.05,0.1,0.15,0.2]
    var _completeFunc:((String)->())!
    
    var _msgStr:String!
    var _image:UIImage!
    var _img:UIImageView!
    
    private let motionManager = CMMotionManager()
    private(set) var acceleration = Acceleration()
    private(set) var euclideanNormInASecond = [Double]()
    var lowPassFilterPercentage = 15.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        motionManager.accelerometerUpdateInterval = PS.Constant.accelerometerUpdateInterval.rawValue
        NotificationCenter.default.addObserver(self, selector: #selector(self.cancelAction), name: NSNotification.Name(rawValue: "closeShake"), object: nil)
    }
    
    func create(_imgURL:String, _msgStr:String, _level:Int){
        
        self.shakeIndex = self.shakeIndexList[_level]
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
                
                do {
                    try self._image = UIImage(data: _data as! Data)
                }
                catch{
                    self._image = UIImage()
                }
                
                // 圖片設定
                let windowSize = UIScreen.main.bounds.size
                let _size = CGSize(width: UIScreen.main.bounds.size.width*7/10, height: UIScreen.main.bounds.size.height*4/10)

                self._img.frame.size = _size
                self._img.center = CGPoint(x: self.view.center.x, y: self.view.center.y-20)
                self._img.image = self._image
            }
        )
    }
    
    //打開搖一搖
    func shakeOpen(_completeFunc:@escaping ((String)->())) {
        // 加入回傳值
        self._completeFunc = _completeFunc
    
        // 螢幕全SIZE
        let windowSize = UIScreen.main.bounds.size
        // 加入背景
        let _view:UIView = UIView()
        _view.frame = self.view.frame
        _view.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8)
        self.view.addSubview(_view)
        // 加入圖片
        self._img = UIImageView()
        self.view.addSubview(self._img)
        // 文字設置
        let _tips:UILabel = UILabel()
        // 不指定文字行數
        _tips.numberOfLines=0
        // 换行的模式我们选择文本自适应
        _tips.lineBreakMode = NSLineBreakMode.byWordWrapping
        _tips.frame.size = CGSize(width: windowSize.width*5/10, height: 120) // height與文字行數比1:30
        _tips.frame.origin = CGPoint(x: self.view.center.x-windowSize.width*5/20, y: self.view.center.y+windowSize.height*4/20-20)
        _tips.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0)
        _tips.textAlignment = .center
        _tips.textColor = UIColor.white
        _tips.text = self._msgStr
        _tips.layer.cornerRadius = 5
        _tips.layer.masksToBounds = true
        self.view.addSubview(_tips)
        // 取消按鈕設定
//        let _cancelBtn:UIButton = UIButton()
//        _cancelBtn.frame.size = CGSize(width: 70, height: 40)
//        _cancelBtn.frame.origin = CGPoint(x: 0, y: 30)
//        _cancelBtn.backgroundColor = UIColor.clear
//        _cancelBtn.setTitle( "Cancel", for: UIControlState.normal)//普通狀態下的文字
//        _cancelBtn.setTitleColor( UIColor.white, for: .normal) //普通狀態下文字的顏色
//        _cancelBtn.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
//        self.view.addSubview(_cancelBtn)
        
        //開始偵測
        self.start()
    }
    
    @objc func cancelAction() {
        //print(self.parent?.childViewControllers)
        self.stop()
        self.parent?.childViewControllers[0].view.removeFromSuperview()
        self.parent?.childViewControllers[0].removeFromParentViewController()
    }
    
    private func determinePedestrianStatusAndStepCount(from variance: Double) {
        if (self.shakeIndex < variance) {
            // 晃動判定通過
            self.parent?.childViewControllers[0].view.removeFromSuperview()
            self.parent?.childViewControllers[0].removeFromParentViewController()
            self.stop()
            self._completeFunc("True")
        }
    }
    
    func start() {
        motionManager.startAccelerometerUpdates(to: .main) { [unowned self] (accelerometerData, error) in
            guard let accelerometerData = accelerometerData
                else {
                    if let error = error { print(error) }
                    
                    return
            }
            self.feedAccelerationData(accelerometerData.acceleration)
        }
    }
    
    func stop() {
        motionManager.stopAccelerometerUpdates()
    }
    
    func resetStepCount() {
        
    }
    
    private func feedAccelerationData(_ acceleration: CMAcceleration) {
        (self.acceleration.xRaw, self.acceleration.yRaw, self.acceleration.zRaw) = retrieveRawAccelerationData(from: acceleration)
        
        (self.acceleration.xFiltered, self.acceleration.yFiltered, self.acceleration.zFiltered) = applyLowPassFilter(self.acceleration.xRaw, self.acceleration.yRaw, self.acceleration.zRaw)
        
        let euclideanNorm = calculateEuclideanNorm(self.acceleration.xFiltered, self.acceleration.yFiltered, self.acceleration.zFiltered)
        collectEuclideanNorm(euclideanNorm)
    }
    
    private func retrieveRawAccelerationData(from acceleration: CMAcceleration) -> (Double, Double, Double) {
        let x = acceleration.x.round(to: 3)
        let y = acceleration.y.round(to: 3)
        let z = acceleration.z.round(to: 3)
        
        return (x, y, z)
    }
    
    private func applyLowPassFilter(_ x: Double, _ y: Double, _ z: Double) -> (Double, Double, Double) {
        let filteredXAcceleration = x.lowPassFilter(using: 15, with: x)
        let filteredYAcceleration = y.lowPassFilter(using: 15, with: y)
        let filteredZAcceleration = z.lowPassFilter(using: 15, with: z)
        
        return (filteredXAcceleration, filteredYAcceleration, filteredZAcceleration)
    }
    
    private func calculateEuclideanNorm(_ x: Double, _ y: Double, _ z: Double) -> Double {
        return sqrt(x.squared().round(to: 3) + y.squared().round(to: 3) + z.squared().round(to: 3)).round(to: 3)
    }
    
    private func collectEuclideanNorm(_ euclideanNorm: Double) {
        guard euclideanNormInASecond.count < 10
            else {
                let variance = calculateVariance()
                euclideanNormInASecond.removeAll(keepingCapacity: false)
                determinePedestrianStatusAndStepCount(from: variance)
                return
        }
        
        euclideanNormInASecond.append(euclideanNorm)
    }
    
    private func calculateVariance() -> Double {
        let totalEuclideanNorm = euclideanNormInASecond.reduce(0, +)
        let euclideanNormInASecondCount = Double(euclideanNormInASecond.count)
        let euclideanNormMean = (totalEuclideanNorm / euclideanNormInASecondCount).round(to: 3)
        
        var total = 0.0
        for euclideanNorm in euclideanNormInASecond {
            total += ((euclideanNorm - euclideanNormMean) * (euclideanNorm - euclideanNormMean)).round(to: 3)
        }
        total = total.round(to: 3)
        
        return (total / euclideanNormInASecondCount).round(to: 3)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

struct Acceleration {
    var xRaw = 0.0
    var xFiltered = 0.0
    
    var yRaw = 0.0
    var yFiltered = 0.0
    
    var zRaw = 0.0
    var zFiltered = 0.0
}

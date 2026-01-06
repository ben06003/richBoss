//
//  MainViewController.swift
//  MUKI_test_NDC
//
//  Created by YUAN JUNG LI on 2023/1/8.
//  Copyright © 2023 EICAPITAN. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth


class MainViewController: UIViewController,Transform, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    var centralManager: CBCentralManager!
    var discoveredPeripherals = [CBPeripheral]()
    var connectedPeripheral: CBPeripheral?
    var dataCharacteristic: CBCharacteristic!
    var writeDataCharacteristic: CBCharacteristic!
    var devices = [String: [String: Any]]()
    var devicePeripherals = [String: CBPeripheral]()
    
    
    // display launchScreen animation
    var shouldShowLaunchAnimation = true // 避免pop回rootVC時，在viewWillAppear重複顯示launchScreen。
    
    // MARK: - loadingAnimatingView event
    private var mask: UIView!
    private var baseView: UIView!
    private var loadingAnimatingView: LoadingAnimatingView!
    var _orientation:UIInterfaceOrientationMask = .portrait
    var _rotateOrientation:UIInterfaceOrientation = .portrait
    var fristKey = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.initUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotateView), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    @objc func rotateView() {
        switch UIDevice.current.orientation {
        case .portrait:
            // rotate view to portrait
            view.transform = CGAffineTransform(rotationAngle: 0)
        case .landscapeLeft:
            // rotate view to landscape left
            view.transform = CGAffineTransform(rotationAngle: .pi / 2)
        case .landscapeRight:
            // rotate view to landscape right
            view.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        default:
            break
        }
    }

    override func viewWillAppear(_ animated: Bool) {
       print("viewWillAppear")
        if fristKey == 1 {
            UIUtils.lockOrientation(_orientation, andRotateTo: _rotateOrientation)
        }
        fristKey = 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewDiviewWillDisappeardAppear")
    }
    
    var itemCategorys = [
            "畫面顯示","藍芽"
        ]
    
    var items = [
            ["setUpdateWBVCache","Alert","Confirm","Toast","sProgress","sProgressC","getAppInfo","setSPValue","getSPValue","setUpdateWBVCache","setOrientation1","setOrientation2","setOrientation3"],
            ["isDeviceConnected","startScan","cancelScan","getScanDeviceMap","connectDevice","disConnectDevice","sendMsg","sendMsgJOB","stopGetMsg"]
        ]
    
    
    var myTableView:UITableView?
    
    // 有幾組 section
    func numberOfSections(in tableView: UITableView) -> Int {
        return itemCategorys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 取得 tableView 目前使用的 cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // 顯示的內容
        if let myLabel = cell.textLabel {
            myLabel.text =
              "\(items[indexPath.section][indexPath.row])"
        }
    
        return cell
        
        
    }

   
    // 點選 cell 後執行的動作
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 取消 cell 的選取狀態
        tableView.deselectRow(
            at: indexPath as IndexPath, animated: true)
        let name = items[indexPath.section][indexPath.row]
        
        switch name {
        //MARK :: 畫面顯示
        case "setUpdateWBVCache":
            var _DownloadHelper = DownloadHelper()
            var urls = [String]()
          print("setUpdateWBVCache")
            let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            let url = URL(string: "https://v2.glasscontrol.yentek.tk/api/api_files.php")!
            NetworkHelper().getJSON(from: url) { (result) in
                switch result {
                case .success(let fileJA):
                    let domain = fileJA.domain
                    for item in fileJA.fileJA {
                        do {
                            try urls.append(item.path)
                        }
                        catch{
                            print("轉換URL失敗\(item.path)")
                        }
                       
//                        if UserDefaults.standard.string(forKey: item.path) != item.md5 {

//                            UserDefaults.standard.set(item.md5, forKey: item.path)
                            
//                            print("filePath:\(FileHandler.shared.path(folder: .files))")
                            
//                        }
                    }
                    print("urls:\(urls)")
                    if urls.count != 0 {
                        print("任務開始")
                        _DownloadHelper.downloadFiles(from: urls,domain: domain)
                    }
                case .failure(let error):
                    print(error)
                }
            }
            break
        case "Alert":
            showAlert(_title: "標題", _message: "內容", _type: .alert,
                      _noAction: nil,
                      _yesAction: UIAlertAction(title: "是", style: .default, handler: nil)
            )
            break
        case "Confirm":
            showAlert(_title: "標題", _message: "內容", _type: .alert,
                      _noAction: UIAlertAction(title: "否", style: .cancel, handler: nil),
                      _yesAction: UIAlertAction(title: "是", style: .default, handler: nil)
                      )
            break
        case "Toast":
            alertToast()
            break
        case "":
            alertToast()
            break
        case "sProgress":
            self.startAnimating()
            DispatchQueue.global().async {
                for i in 0...5 {
                    sleep(1)
                }
                DispatchQueue.main.async {
                    self.stopAnimating()
                }
            }
            break
        case "sProgressC":
            self.stopAnimating()
            break
        case "getAppInfo":
            getAppInfo()
            break
        case "setSPValue":
            UserDefaults.standard.set("set", forKey: "SP")
            break
        case "getSPValue":
            print("SPValue:\(UserDefaults.standard.string(forKey: "SP") ?? "noSetSP")")
            break
        case "setOrientation1":
            rotate(rotate: "top")
            break
        case "setOrientation2":
            rotate(rotate: "right")
            break
        case "setOrientation3":
            rotate(rotate: "left")
            break
        //MARK :: 藍芽
        case "isDeviceConnected":
            if connectedPeripheral?.state == .connected {
                    print("Peripheral is connected.")
            } else {
                print("Peripheral is not connected.")
            }
            break
        case "startScan":
            centralManager = CBCentralManager(delegate: self, queue: nil)
            break
        case "cancelScan":
            centralManager.stopScan()
            break
        case "getScanDeviceMap":
            print("devices:\(devices)")
            break
        case "connectDevice":
            if devicePeripherals["6E607F6F-91B0-174D-5E2D-1AA0765FD4F2"] != nil {
                centralManager.stopScan()
                connectedPeripheral = devicePeripherals["6E607F6F-91B0-174D-5E2D-1AA0765FD4F2"]
                centralManager.connect(connectedPeripheral!, options: nil)
            }
            break
        case "disConnectDevice":
            centralManager.cancelPeripheralConnection(connectedPeripheral!)
            break
        case "sendMsg":
            
            break
        case "sendMsgJOB":
          
            break
        case "stopGetMsg":
            stopReceivingData()
            break
        default:
            print("\(name) todo")
            break
        }
       
    }
    
    // 每個 section 的標題
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return itemCategorys[section]
    }
    
    
    //MARK: - fcuntion
    func initUI() {
        self.mask = UIView(frame: UIScreen.main.bounds)
        self.mask.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        self.view.addSubview(self.mask)
        self.baseView = UIView()
        self.baseView.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        self.baseView.center = self.view.center
        self.baseView.backgroundColor = UIColor.white
        self.baseView.alpha = 0.95
        self.baseView.layer.cornerRadius = 10
        self.mask.addSubview(self.baseView)
        self.loadingAnimatingView = LoadingAnimatingView()
        self.loadingAnimatingView.style = .white
        self.view.addSubview(self.loadingAnimatingView)
        
        // 取得螢幕的尺寸
        let fullScreenSize = UIScreen.main.bounds.size
        
        myTableView = UITableView(frame: CGRect(
          x: 0, y: 20,
          width: fullScreenSize.width,
          height: fullScreenSize.height - 20),
                                  style: .grouped)
        
        // 註冊 cell
        myTableView?.register(
          UITableViewCell.self, forCellReuseIdentifier: "Cell")

        // 設置委任對象
        myTableView?.delegate = self
        myTableView?.dataSource = self

        // 分隔線的樣式
        myTableView?.separatorStyle = .singleLine

        // 分隔線的間距 四個數值分別代表 上、左、下、右 的間距
        myTableView?.separatorInset =
          UIEdgeInsetsMake(0, 20, 0, 20)

        // 是否可以點選 cell
        myTableView?.allowsSelection = true

        // 是否可以多選 cell
        myTableView?.allowsMultipleSelection = false

        // 加入到畫面中
        self.view.addSubview(myTableView!)
        
        if UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) {
            var stRect =  self.view.frame
            myTableView!.frame = stRect
            if UIApplication.shared.statusBarOrientation.rawValue == 4 {
                _rotateOrientation = .landscapeLeft
                UIUtils.lockOrientation(_orientation, andRotateTo: .landscapeLeft)
            }
            if UIApplication.shared.statusBarOrientation.rawValue == 3 {
                _rotateOrientation = .landscapeRight
                UIUtils.lockOrientation(_orientation, andRotateTo: .landscapeRight)
            }
        }
        if UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) {
            var stRect =  self.view.frame
            if self.view.frame.size.height >= 812 && self.view.frame.size.height < 1024 {
                // 瀏海機
                if DeviceInfoManager.shared.specification == "iPhone 12 mini"{
                    stRect.origin.y = 50
                    stRect.size.height -= 40
                }else{
                    stRect.origin.y = 44
                    stRect.size.height -= 34
                }
            } else {
                // others
                stRect.origin.y = 20
            }
            stRect.size.height -= stRect.origin.y
            myTableView!.frame = stRect
            _rotateOrientation = .portrait
            UIUtils.lockOrientation(_orientation, andRotateTo: .portrait)
        }
    }
}


// MARK:: 其他

extension MainViewController {
    func showAlert(_title:String, _message:String, _type:UIAlertControllerStyle, _noAction:UIAlertAction?, _yesAction:UIAlertAction?) {
        let alertController = UIAlertController(title: _title, message: _message, preferredStyle: _type)
        
        if _noAction != nil {
            alertController.addAction(_noAction!)
        }
        if _yesAction != nil {
            alertController.addAction(_yesAction!)
        }
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func alertToast() {
        let _content = "Toast"
        let _position = "center"
        let _showTime:Double = 5
       
        let _contentSize:CGSize = _content.size(OfFont: UIFont.systemFont(ofSize: 14))

        let _showView:UILabel = UILabel()
        _showView.frame.size = CGSize(width: _contentSize.width+20, height: _contentSize.height+10)
        _showView.center = (_position == "center") ? self.view.center : CGPoint(x: self.view.center.x, y: self.view.frame.height-90)
        _showView.backgroundColor = UIColor.darkGray
        _showView.textColor = UIColor.white
        _showView.textAlignment = .center
        _showView.font = UIFont.systemFont(ofSize: 14)
        _showView.text = _content
        _showView.layer.cornerRadius = 5
        _showView.layer.masksToBounds = true
        //self.view.addSubview(_showView)
        self.myTableView?.addSubview(_showView)
        _showView.tag = self.myTableView!.subviews.count
        
        let _delayTime:Double = _showTime
        
      
        for _i in 0..<self.myTableView!.subviews.count {
            let _current = self.myTableView!.subviews[_i]
            if _current is UILabel && _current.tag == _showView.tag {
                _ = Brook_Dispatch().delay(_delay: _delayTime, _func: {
                    _current.removeFromSuperview()
                })
            }
        }
    }
    
    func starLoad() {
        self.startAnimating()
        sleep(5)
        stopLoad()
    }
    
    
    func stopLoad() {
        self.stopAnimating()
    }
    
    func getAppInfo() {
        print(DeviceInfoManager.shared.applicationShortVersion)
        print(DeviceInfoManager.shared.applicationVersion)
    }
    
    func rotate(rotate: String) {
        switch rotate {
            case "top":
                // rotate view to portrait
                view.transform = CGAffineTransform(rotationAngle: 0)
                break;
            case "right":
                // rotate view to landscape right
                view.transform = CGAffineTransform(rotationAngle: -.pi / 2)
                break;
            case "left":
                // rotate view to landscape left
                view.transform = CGAffineTransform(rotationAngle: .pi / 2)
                break;
            default:
                break;
        }
        switch rotate {
        
        case "top":
            _orientation = .portrait
            break;
        case "right":
            _orientation = .landscapeRight
            break;
        case "left":
            _orientation = .landscapeLeft
            break;
        case "landscape":
            _orientation = .landscape
        default:
            _orientation = .allButUpsideDown
            break;
        }
        UIUtils.lockOrientation(_orientation)
    }
}

extension MainViewController {
  
    
    func triggerLaunchAnimation() {
        let launchVC = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateViewController(withIdentifier: "LaunchScreen") // 要記得在storyboard設定id啊
        var launchView = launchVC.view
        launchView?.frame = UIScreen.main.bounds
        self.view.addSubview(launchView!) // 加到UIWindow可能在尺寸上會更好，下列方法無法實現，待研究。
        UIView.animate(withDuration: 1.8, animations: {
            UIView.setAnimationCurve(.easeInOut)
            launchView?.alpha = 0.0
            launchView?.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
        }, completion: { _ in
            launchView?.removeFromSuperview()
            launchView = nil
        })
    }
    
   
    
    func startAnimating() {
        self.view.bringSubview(toFront: self.mask)
        self.view.bringSubview(toFront: self.loadingAnimatingView)
        self.mask.isHidden = false
        self.baseView.isHidden = false
        UIView.animate(withDuration: 0, animations: {
            self.mask.alpha = 0.75
            self.baseView.alpha = 0.95
        }) { _ in
            self.loadingAnimatingView.start()
        }
        self.view.isUserInteractionEnabled = false
    }
    
    func stopAnimating() {
        UIView.animate(withDuration: 0, animations: {
            
        }) { _ in
            self.loadingAnimatingView.stop()
        }
        self.mask.isHidden = true
        self.baseView.isHidden = true
        self.view.isUserInteractionEnabled = true
    }
}

extension MainViewController {
    
    // 藍芽掃描狀態變更
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .unknown:
                print("Bluetooth status is UNKNOWN")
                break
            case .resetting:
                print("Bluetooth status is RESETTING")
                break
            case .unsupported:
                print("Bluetooth status is UNSUPPORTED")
                break
            case .unauthorized:
                print("Bluetooth status is UNAUTHORIZED")
                break
            case .poweredOff:
                print("Bluetooth status is POWERED OFF")
                break
            case .poweredOn:
                print("Bluetooth status is POWERED ON")
                centralManager.scanForPeripherals(withServices: nil, options: nil)
                break
        default:
                break
        }
    }
    
    // 掃描到藍芽裝置
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // 生成裝置物件陣列
        if !discoveredPeripherals.contains(peripheral) {
            discoveredPeripherals.append(peripheral)
            let device = ["name": peripheral.name, "identifier": peripheral.identifier.uuidString, "RSSI": RSSI] as [String : Any]
            devices[peripheral.identifier.uuidString] = device
            devicePeripherals[peripheral.identifier.uuidString] = peripheral
        }
    }
    
    // 藍芽裝置連接
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        connectedPeripheral?.delegate = self
        peripheral.discoverServices(nil)
        print("Connected to \(peripheral.name ?? "")")
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
                print("接收到DiscoverServices")
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print("characteristic:\(characteristic)")
                print("characteristic read:\(characteristic.properties.contains(.read))")
                print("characteristic write:\(characteristic.properties.contains(.write))")
                if characteristic.properties.contains(.read) {
                    print("接收到讀取Characteristics")
                    dataCharacteristic = characteristic
                    peripheral.readValue(for: characteristic)
                }
                if characteristic.properties.contains(.write) {
                    print("接收到寫入Characteristics")
                    writeDataCharacteristic = characteristic
                   
                }
            }
        }
    }
    
    // 藍芽裝置回傳Data
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Error: \(error!)")
            return
        }
        guard let data = characteristic.value else {
            print("No data received")
            return
        }
        let receivedData = String(data: data, encoding: .utf8)
        print("Received data: \(receivedData ?? "")")
    }
    
    
    // 藍芽停止掃描Data
    func stopReceivingData() {
        print("44444")
        guard let dataCharacteristic = dataCharacteristic else {
            print("No data characteristic found.")
            return
        }
        connectedPeripheral!.setNotifyValue(false, for: dataCharacteristic)
    }
    
}




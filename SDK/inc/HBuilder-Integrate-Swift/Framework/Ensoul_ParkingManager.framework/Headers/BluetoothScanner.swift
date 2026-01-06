//
//  BluetoothScanner.swift
//  EnsoulParkingManagerSample-IOS
//
//  Created by Mac2010 on 2018/4/2.
//  Copyright © 2018年 Mac2010. All rights reserved.
//

import CoreBluetooth

public class BluttoothLeDevice{
    private let MAX_RSSI_LOG_SIZE = 5
    let uuidString:String
    let peripheral: CBPeripheral
    var advertisementData: [String : Any];
    var rssiLog:[Date:NSNumber] = [:]
    var currentTimestamp:Date;
    
    init(uuidString:String,peripheral: CBPeripheral,advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.uuidString = uuidString
        self.peripheral = peripheral
        self.advertisementData = advertisementData
        rssiLog[Date()] = RSSI
        currentTimestamp = Date()
    }
    
    func updata(advertisementData: [String : Any], rssi RSSI: NSNumber){
        currentTimestamp = Date()
        self.advertisementData = advertisementData
        rssiLog[Date()] = RSSI
        if rssiLog.count > MAX_RSSI_LOG_SIZE {
            var list =  rssiLog.sorted(by: {first, second in
                return first.key < second.key
            })
            let removeData = list.remove(at: list.startIndex).key
            let removeValue = rssiLog.removeValue(forKey: removeData)
        }
    }
    
    public func getRunningAverageRssi()->Double {
        var sum = 0.0
        var count = 0.0
        print("currentTimestamp = \(currentTimestamp)")
        for rssi in rssiLog {
            print("rssi.key+10 = \(rssi.key+10) : \(rssi.value)")
            if rssi.key + 10 >= currentTimestamp{
                sum += Double(truncating: rssi.value)
                count += 1
            }
        }
        if(count>0){
            return sum/count
        }
        return 0
    }
}

public class BluetoothScanner{
    public typealias OnStateUpdate = (CBManagerState)->Void
    public typealias OnScannedSubject = (BluttoothLeDevice)->Void
    public typealias OnModelUpdateSubject = (BluttoothLeDevice)->Void
    public typealias OnLostSubject = (BluttoothLeDevice)->Void
    private let INFO_OPTIONS = [CBCentralManagerOptionShowPowerAlertKey:true]
    private let SCAN_OPTIONS = [CBCentralManagerScanOptionAllowDuplicatesKey:true]
    let bluetoothInteractor:BluetoothInteractor
    let centralManager:CBCentralManager
    
    public var onStateUpdate:OnStateUpdate?
    public var onScannedSubject:OnScannedSubject?
    public var onModelUpdateSubject:OnModelUpdateSubject?
    public var onLostSubject:OnLostSubject?
    public var isScanning = false
    private var bleDictionary:[String:BluttoothLeDevice] = [:]
    
    private lazy var _onStateUpdate:((CBManagerState)->Void) = {state in
        switch state {
        case .poweredOn:
            if !self.isScanning {
                self.startScan()
            }
            break
        default:
            break
        }
    }
    
    lazy var _onScannedSubject:((CBPeripheral,[String : Any],NSNumber)->Void) = {peripheral,advertisementData,rssi in
        let uuidString = peripheral.identifier.uuidString
        if (self.bleDictionary[uuidString] == nil) {
            let device = BluttoothLeDevice(uuidString: uuidString, peripheral: peripheral, advertisementData:advertisementData, rssi:rssi)
            self.bleDictionary[uuidString] = device
            self.onScannedSubject?(device)
        } else {
            guard let device = self.bleDictionary[uuidString] else { return }
            device.updata(advertisementData:advertisementData, rssi:rssi)
            self.onModelUpdateSubject?(device)
        }
    }
    
    lazy var checkRemoveTask:(()->Void) = {
        if !self.isScanning { return }
        for entry in self.bleDictionary {
            guard let bluttoothLeDevice = entry.value as? BluttoothLeDevice else { continue }
            if bluttoothLeDevice.currentTimestamp+10 < Date() {
                self.bleDictionary.removeValue(forKey: bluttoothLeDevice.uuidString)
                self.onLostSubject?(bluttoothLeDevice)
            }
        }
        DispatchQueue.global().asyncAfter(deadline: .now()+5, execute: self.checkRemoveTask)
    }
    
    init() {
        bluetoothInteractor = BluetoothInteractor()
        centralManager = CBCentralManager(delegate: bluetoothInteractor, queue: .none, options: INFO_OPTIONS)
        bluetoothInteractor.onStateUpdate = _onStateUpdate
        bluetoothInteractor.onScannedSubject = _onScannedSubject
    }
    
    public func startScan(){
        if centralManager.state == .poweredOn && !isScanning {
            centralManager.scanForPeripherals(withServices: nil, options: SCAN_OPTIONS)
            isScanning = true
            DispatchQueue.global().async(execute: checkRemoveTask)
        }
    }
    
    public func stopScen(){
        centralManager.stopScan()
        isScanning = false
    }
}

class BluetoothInteractor: NSObject, CBCentralManagerDelegate{
    var onStateUpdate:((CBManagerState)->Void)?
    var onScannedSubject:((CBPeripheral,[String : Any],NSNumber)->Void)?
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        onStateUpdate?(central.state)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        onScannedSubject?(peripheral,advertisementData,RSSI)
    }
}

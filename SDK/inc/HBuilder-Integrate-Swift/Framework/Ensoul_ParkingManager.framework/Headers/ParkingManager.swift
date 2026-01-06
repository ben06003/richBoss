//
//  ParkingManager.swift
//  EnsoulParkingManagerSample-IOS
//
//  Created by Mac2010 on 2018/4/2.
//  Copyright © 2018年 Mac2010. All rights reserved.
//

import CoreBluetooth

public class Parkinglot{
    let bluttoothLeDevice:BluttoothLeDevice
    let macAddress:String
    
    init(bluttoothLeDevice:BluttoothLeDevice, macAddress:String) {
        self.bluttoothLeDevice = bluttoothLeDevice
        self.macAddress = macAddress
    }
    
    public func getBluttoothLeDevice()->BluttoothLeDevice{
        return bluttoothLeDevice
    }
    
    public func getMacAddress()->String{
        return macAddress
    }
}

public protocol ParkingDelegate{
    func onParkinglotResponse(parkinglot:Parkinglot)
    func onFailure(code:Int, message:String)
}

public protocol ParkingManager{
    var parkingDelegate:ParkingDelegate?{set get}
    func requestParkinglot()
    func start()
    func stop()
}

class ParkingManagerImpl:ParkingManager{
    private let APPLE_ID:[Int16] = [0x4C,0x00]
    private let TBM1_UUID:[Int16] = [0xFD,0xA5,0x06,0x93,0xA4,0xE2,0x4F,0xB1,0xCF,0xC6,0xEB,0x07,0x64,0x78,0x25]
    private let session_key:String
    let bluetoothScanner:BluetoothScanner
    
    var parkingDelegate: ParkingDelegate?
    var bleDictionary:[String:Parkinglot] = [:]
    
    lazy var onScannedSubject:BluetoothScanner.OnScannedSubject = {bluttoothLeDevice in
        guard let uuidString = bluttoothLeDevice.peripheral.identifier.uuidString as? String else { return }
        guard let name = bluttoothLeDevice.peripheral.name else { return }
        if "TB-M1" != name { return }
        guard let advData = bluttoothLeDevice.advertisementData["kCBAdvDataServiceData"] as? NSDictionary else { return }
        self.bleDictionary[uuidString] = Parkinglot(bluttoothLeDevice: bluttoothLeDevice, macAddress: self.parseAddress(bluttoothLeDevice.advertisementData))
    }
    
    lazy var onModelUpdateSubject:BluetoothScanner.OnModelUpdateSubject = {bluttoothLeDevice in
        guard let uuidString = bluttoothLeDevice.peripheral.identifier.uuidString as? String else { return }
        guard let name = bluttoothLeDevice.peripheral.name else { return }
        if "TB-M1" != name { return }
        guard let advData = bluttoothLeDevice.advertisementData["kCBAdvDataServiceData"] as? NSDictionary else { return }
        self.bleDictionary[uuidString] = Parkinglot(bluttoothLeDevice: bluttoothLeDevice, macAddress: self.parseAddress(bluttoothLeDevice.advertisementData))
    }
    
    lazy var onLostSubject:BluetoothScanner.OnLostSubject = {bluttoothLeDevice in
        guard let uuidString = bluttoothLeDevice.peripheral.identifier.uuidString as? String else { return }
        guard let name = bluttoothLeDevice.peripheral.name else { return }
        if "TB-M1" != name { return }
        guard let advData = bluttoothLeDevice.advertisementData["kCBAdvDataServiceData"] as? NSDictionary else { return }
        self.bleDictionary.removeValue(forKey: uuidString)
    }
    
    lazy var requestTask:(()->Void) = {
        guard let parkinglot = self.bleDictionary.min(by: {e1,e2 in
            let rssi1 = e1.value.bluttoothLeDevice.getRunningAverageRssi()
            let rssi2 = e2.value.bluttoothLeDevice.getRunningAverageRssi()
            print("device(\(self.parseAddress(e1.value.bluttoothLeDevice.advertisementData)) rssi is \(rssi1)")
            print("device(\(self.parseAddress(e2.value.bluttoothLeDevice.advertisementData)) rssi is \(rssi2)")
            return abs(rssi1) < abs(rssi2)
        })?.value else {
            self.parkingDelegate?.onFailure(code: Ensoul.ERROR_CODE_NOT_FIND_PARKINGLOT, message: Ensoul.ERROR_MESSAGE_NOT_FIND_PARKINGLOT)
            return }
        DispatchQueue.main.async {
            self.parkingDelegate?.onParkinglotResponse(parkinglot: parkinglot)
        }
    }
    
    init(session_key:String) {
        self.session_key = session_key
        bluetoothScanner = BluetoothScanner()
        bluetoothScanner.onScannedSubject = onScannedSubject
        bluetoothScanner.onModelUpdateSubject = onModelUpdateSubject
        bluetoothScanner.onLostSubject = onLostSubject
    }
    
    private func parseAddress(_ advertisementData:[String:Any])->String{
        guard let advData = advertisementData["kCBAdvDataServiceData"] as? NSDictionary else { return "" }
        var macAddress = "";
        for data in advData {
            let key = "\(data.key)"
            let scond = key.index(key.startIndex,offsetBy:2)
            macAddress += "\(key[scond...]):\(key[...scond]):"
            if let value = data.value as? Data {
                for i in 0...3{
                    macAddress += String(format: "%02X", value[i])
                    if i < 3 {
                        macAddress += ":"
                    }
                }
            }
        }
        return macAddress
    }
    
    func requestParkinglot() {
        if bluetoothScanner.isScanning {
            DispatchQueue.global().asyncAfter(deadline: .now()+3, execute: requestTask)
        }else {
            parkingDelegate?.onFailure(code: Ensoul.ERROR_CODE_MANAGER_NOT_START, message: Ensoul.ERROR_MESSAGE_MANAGER_NOT_START)
        }
    }
    
    func start() {
        bluetoothScanner.startScan()
    }
    
    func stop() {
        bluetoothScanner.stopScen()
    }
}

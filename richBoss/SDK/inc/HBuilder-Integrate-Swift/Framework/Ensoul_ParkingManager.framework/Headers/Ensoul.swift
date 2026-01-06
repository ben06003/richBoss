//
//  Ensoul.swift
//  EnsoulParkingManagerSample-IOS
//
//  Created by Mac2010 on 2018/4/2.
//  Copyright © 2018年 Mac2010. All rights reserved.
//

import Foundation


public class Ensoul{
    public static let ERROR_CODE_MANAGER_NOT_START = 0x00010002
    public static let ERROR_MESSAGE_MANAGER_NOT_START = "manager not start"
    public static let ERROR_CODE_NOT_FIND_PARKINGLOT = 0x00040001
    public static let ERROR_MESSAGE_NOT_FIND_PARKINGLOT = "not find parkinglot"
    public static func getParkingManager(session_key:String) -> ParkingManager{
        return ParkingManagerImpl(session_key:session_key)
    }
}

//
//  SHLogPrinter.swift
//  MUKI_Shipgo17
//
//  Created by smallHappy on 2018/6/16.
//  Copyright © 2018年 EICAPITAN. All rights reserved.
//

import Foundation

func SHPrint(doPrint: () -> Void) {
    #if DEBUG
    print("===", #file.components(separatedBy: "/").last!, #line, Date(), "===")
    doPrint()
    #endif
}

func SHPrint(_ logs: Any ...) {
    #if DEBUG
    print("===", #file.components(separatedBy: "/").last!, #line, Date(), "===")
    for log in logs {
        print(log, terminator: "")
        print(" ", terminator: "")
    }
    print()
    #endif
}

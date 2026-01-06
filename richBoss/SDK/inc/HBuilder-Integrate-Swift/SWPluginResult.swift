//
//  SWPluginResult.swift
//  HBuilder-Integrate-Swift
//
//  Created by EICAPITAN on 17/6/8.
//  Copyright © 2017年 EICAPITAN. All rights reserved.
//

import Foundation

class SWPluginResult
{
    static let strStatus  = "status";
    static let strMessage = "message";
    static let strisKeep = "keepCallback";
    
    static func CallBackCommand(status: PDRCommandStatus, message: Any) -> String
    {
        var nstate = 0;
        if(status == PDRCommandStatusOK){
            nstate = 1;
        }
        else if(status == PDRCommandStatusError){
            nstate = 2;
        }
        
        let resultJsonDic:NSDictionary? = [strStatus:nstate,
                                           g_pdr_string_message:message as Any,
                                           strisKeep:false];
        if((resultJsonDic) != nil)
        {
            let retData =  try? JSONSerialization.data(withJSONObject: resultJsonDic as Any,
                                                       options: JSONSerialization.WritingOptions.prettyPrinted) as NSData?;
            
            return String.init(data: retData!! as Data, encoding: String.Encoding.utf8)!;
        }
        return "";
        
    }
}

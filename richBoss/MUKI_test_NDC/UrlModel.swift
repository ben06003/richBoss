//
//  UrlModel.swift
//  MUKI_test_NDC
//
//  Created by smallHappy on 2018/6/28.
//  Copyright © 2018年 EICAPITAN. All rights reserved.
//

import Foundation

let basePostURL = "https://geturl.muki001.com/website/geturl"
var postFormData:[String:Any]?
var postNum:Int = 0

// baseURL
var baseUrl: String?
var app_store_baseUrl:String = "https://ivendor.com.tw"

let apple_id = "1298998245"
let app_store = "https://itunes.apple.com/app/id" + apple_id

var urlKey: String {
    return "yioushen_formal" //noya-dev
}

class UrlModel {
    var _baseUrl:((String)->())!
    
    func processData(data: Data){
        let fetchedDictionary = data.parseData()
        if fetchedDictionary["res_code"]as! Int == 0 {
            if postNum < 2{
                postNum += 1
                sleep(1)
                APIManager().requestWithFormData(urlString: basePostURL, parameters: postFormData!, completion: { (data) in
                    DispatchQueue.main.async {
                        self.processData(data: data)
                    }
                })
            }else{
                self._baseUrl("nil")
                
            }
        }
        guard let dataDic_res_data = fetchedDictionary["res_data"] as? NSDictionary else {return}
        print("dataDic_res_data:\(dataDic_res_data)")
        let url = dataDic_res_data["project_url"] as! String
        self._baseUrl("https://yadog.com/?code=oDxpw5")
    }
    
    func getApiUrl(_baseUrl:@escaping ((String)->())) {
        // 加入回傳值
        self._baseUrl = _baseUrl
        let project_code = urlKey
        let value = "{\"project_code\":\"\(project_code)\"}"
        postFormData = ["json_data":value]
        APIManager().requestWithFormData(urlString: basePostURL, parameters: postFormData!, completion: { (data) in
            DispatchQueue.main.async {
                self.processData(data: data)
            }
        })
    }
}


//
//  JsonManager.swift
//  JsonManager
//
//  Created by smallHappy Mac on 2016/12/2.
//  Copyright © 2016年 smallHappy. All rights reserved.
//

import UIKit

class JsonManager: NSObject {
    
    private static let instance = JsonManager()
    static var sharedInstance: JsonManager {
        return self.instance
    }
    
    enum HTTPMethod: String {
        case get = "GET", post = "POST"
    }
    
    enum Mimetype: String {
        case jpg = "image/jpeg"
    }
    
    var boundary: String {
        return "Boundary-\(UIDevice.current.identifierForVendor!.uuidString)"
    }
    
    func toBool<T>(_ parameter: T) -> Bool? {
        if let result = parameter as? String {
            if result.lowercased() == "true" {
                return true
            } else if result.lowercased() == "false" {
                return false
            } else if let value = Int(result) {
                return value != 0
            } else {
                return nil
            }
        } else if let result = parameter as? Int {
            return result != 0
        } else if let result = parameter as? Double {
            return result != 0
        } else if let result = parameter as? Float {
            return result != 0
        } else {
            return nil
        }
    }
    
}

extension JsonManager {
    
    func getJsonObject(method: HTTPMethod = .post, url: URL, body: Data? = nil, sec:Double = 20, finish: ((_ object:Any?) -> Void)? = nil) {
        var request: URLRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: sec)
        request.httpMethod = method.rawValue
        request.setValue("multipart/form-data; boundary=" + self.boundary, forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        request.httpShouldHandleCookies = false
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
            if error != nil {
                print("post nil error: \(error!.localizedDescription)")
                finish?(nil)
                return
            }
            do{
                finish?(try JSONSerialization.jsonObject(with: data!, options: .mutableContainers))
            }catch let error as NSError {
                print("post catch error: \(error.description)")
                finish?(nil)
            }
        })
        task.resume()
    }
    
    func getImageObject(imageURL url: URL, timeoutInterval sec: Double = 20, finish: @escaping (_ image: UIImage?) -> Void) {
        let request: URLRequest = URLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: sec)
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
            if error != nil {
                print((error! as NSError).description)
                finish(nil)
                return
            }
            if data == nil {
                print("data is nil")
                finish(nil)
                return
            }
            finish(UIImage(data: data!))
        })
        task.resume()
    }
    
    func getFileData(fileURL url: URL, timeoutInterval sec: Double = 20, finish: @escaping (_ data: Data?) -> Void) {
        let request: URLRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: sec)
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
            if error != nil {
                print((error! as NSError).description)
                finish(nil)
                return
            }
            finish(data)
        })
        task.resume()
    }
    
}

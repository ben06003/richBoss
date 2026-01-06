import Foundation
import CommonCrypto

struct PurchaseInfo {
    let orderNo: String      // billingOrderId 自訂單號
    let platform = "AppStore"
    let token: String        // 交易憑證 (receipt base64)
    let packageName: String  // bundle identifier
    let productId: String
}

protocol VerifyCallback {
    func onSuccess(orderId: String)
    func onFailure(message: String)
}

class IAPVerifier {
    private let md5Key = "Bw7$myVk@MJtdy^q"
    private let apiUrl = "https://goapi.richboss.net/v4/CashFlow/IAP/Order"
    
    func verifyPurchaseWithBackend(purchase: PurchaseInfo, completion: @escaping (Bool) -> Void) {
        let authorization = md5("\(md5Key):\(purchase.orderNo)")
        
        let jsonBody: [String: Any] = [
            "OrderNo": purchase.orderNo,
            "Platform": purchase.platform,
            "Token": purchase.token,
            "PackageName": purchase.packageName,
            "ProductID": purchase.productId
        ]
        
//        print("jsonBody:\(jsonBody)");
//
        
        guard let url = URL(string: apiUrl),
              let httpBody = try? JSONSerialization.data(withJSONObject: jsonBody, options: []) else {
            print("內購驗證參數錯誤")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        print("內購驗證執行")
        let notification = Notification(name: startLoadingNotification, object: nil, userInfo: nil)
        NotificationCenter.default.post(notification)
        // loading
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print("內購驗證返回")
            if let error = error {
                print("內購驗證參數error:\(error)")
                completion(false)
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("內購驗證參數無法分析")
                completion(false)
                return
            }
//            print("json:\(json)")
            let success = json?["Success"] as? Bool ?? false
            let errorMessage = json?["ErrorMessage"] as? String ?? "未知錯誤"
            print("success:\(success)")
            print("errorMessage:\(errorMessage)")
            if success {
                completion(true)
                
            } else {
//                completion(true)
                completion(false)
           
            }
        }
        task.resume()
    }

    private func md5(_ string: String) -> String {
        let data = Data(string.utf8)
        var digest = Data(count: Int(CC_MD5_DIGEST_LENGTH))

        _ = digest.withUnsafeMutableBytes { digestBytes in
            data.withUnsafeBytes { messageBytes in
                CC_MD5(messageBytes.baseAddress, CC_LONG(data.count), digestBytes.bindMemory(to: UInt8.self).baseAddress)
            }
        }

        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}

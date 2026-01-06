//
//  IAPManager.swift
//  IAPDemo
//
//  Created by SHIH-YING PAN on 2020/4/28.
//  Copyright © 2020 SHIH-YING PAN. All rights reserved.
//

import StoreKit


class IAPManager: NSObject {
    
    static let shared = IAPManager()
    var products = [SKProduct]()
    var cbid:String?
    var memberID:Int?
    var orderID:String?
    var timestamp:Int?
    var ip:String?
    private var transaction_json:[String:Any]?
    fileprivate var productRequest: SKProductsRequest!
    //        ["3000coin","100coin","300coin","500coin","900coin","1500coin","50coin"]

//    func getProductIDs() -> [String] {
//        ["test30","richboss.33.test","richboss.170.test","richboss.330.test","richboss.670.test","richboss.1090.test","richboss.1690.test","richboss.3290.test","richboss.week.card.test","richboss.month.card.test","richboss.super.month.card.test"]
//    }
    func getProductIDs() -> [String] {
        ["richboss.33","richboss.170","richboss.330","richboss.670","richboss.1090","richboss.1690","richboss.3290","richboss.week.card","richboss.month.card","richboss.super.month.card"]
    }
    
    var productIndexs:[String] = []
    
    func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func getProducts() {
        let productIds = getProductIDs()
        let productIdsSet = Set(productIds)
        productRequest = SKProductsRequest(productIdentifiers: productIdsSet)
        productRequest.delegate = self
        productRequest.start()
    }
 
    
    func buy(product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            print("buyerror")
            // show error
        }
       
    }
    
    
}

extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
//         invalidProductIdentifiers.description 會印出不合法的內購項目，例如：沒有設定價錢、已停用的等等
       print("invalidProductIdentifiers： \(response.invalidProductIdentifiers.description)")
       print("response： \(response.products)")
        
        response.products.forEach {
            productIndexs.append($0.productIdentifier)
            
            
//            productIndexs.push($0.productIdentifier)
            print($0.localizedTitle, $0.price, $0.productIdentifier)
        }
        DispatchQueue.main.async {
            print("products:\(self.productIndexs)")
            self.products = response.products
        }
        
       
    }
    
}
extension IAPManager: SKPaymentTransactionObserver {
    
    func processData(data: Data){
        let fetchedDictionary = data.parseData()
        print("fetchedDictionary:\(fetchedDictionary)")
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach {
            print("paymentQueue:\($0)")
            switch $0.transactionState {
            case .purchased:
                print("Transaction completed successfully.\($0.payment.productIdentifier)");
                let notification2 = Notification(name: stopLoadingNotification, object: nil, userInfo: nil)
                NotificationCenter.default.post(notification2)
                let AA = $0;
                
                if let receiptData = getReceiptData() {
                    orderID = UserDefaults.standard.string(forKey: "IAPOrderId")
                    if (UserDefaults.standard.string(forKey: $0.transactionIdentifier!) != nil) {
                        orderID = UserDefaults.standard.string(forKey: $0.transactionIdentifier!)
                    }else{
                        UserDefaults.standard.set(orderID, forKey: $0.transactionIdentifier!)
                    }
//                    print("orderID:\(orderID)")
                  
//                    let productId = transaction.payment.productIdentifier
                    let purchase = PurchaseInfo(
                        orderNo: orderID ?? "",
                        token: receiptData,
                        packageName: "com.soga.richboss",
                        productId: $0.payment.productIdentifier
                    )
//                    print("purchase:\(purchase)")
//                    SKPaymentQueue.default().finishTransaction(AA)
                    print("嘗試完成內購驗證")
                    
                    
                    
                    let verifier = IAPVerifier()
                    verifier.verifyPurchaseWithBackend(purchase: purchase){ [self] (isValid) in
                        let notification = Notification(name: stopLoadingNotification, object: nil, userInfo: nil)
                        NotificationCenter.default.post(notification)
                        if (isValid) {
                            UserDefaults.standard.removeObject(forKey: "IAPOrderId")
                            UserDefaults.standard.removeObject(forKey: "IAPProductId")
                            UserDefaults.standard.removeObject(forKey: AA.transactionIdentifier!)
                            print("後端內購驗證成功")
                            let result = ["res_code": "1"]
                            let _jsonData = try? JSONSerialization.data(withJSONObject: result, options: [])
                            let _jsonString:String = String(data: _jsonData!, encoding: .utf8)!
                            var resultInfo: [String:Any] = [:]
                            resultInfo["_jsonString"] = _jsonString
                            let notification2 = Notification(name: evaluateJavaScriptNotification, object: nil, userInfo: resultInfo)
                            NotificationCenter.default.post(notification2)
                            SKPaymentQueue.default().finishTransaction(AA)
                        }else{
//                            SKPaymentQueue.default().finishTransaction(AA)
                            print("後端內購驗證失敗")
                        }
                    }
                }
              
            case .failed:
                print("Transaction completed failed.");
                let notification2 = Notification(name: stopLoadingNotification, object: nil, userInfo: nil)
                NotificationCenter.default.post(notification2)
                UserDefaults.standard.removeObject(forKey: "IAPOrderId")
                UserDefaults.standard.removeObject(forKey: "IAPProductId")
                SKPaymentQueue.default().finishTransaction($0)
            case .restored:
                print("Transaction completed restored.");
                UserDefaults.standard.removeObject(forKey: "IAPOrderId")
                UserDefaults.standard.removeObject(forKey: "IAPProductId")
                SKPaymentQueue.default().finishTransaction($0)
            case .purchasing, .deferred:
                let notification = Notification(name: startLoadingNotification, object: nil, userInfo: nil)
                NotificationCenter.default.post(notification)
                print("Transaction completed purchasing.");
                break
            @unknown default:
                break
            }
            
        }
    }
    
    // 获取收据数据
    func getReceiptData() -> String? {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
           FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                let receiptString = receiptData.base64EncodedString(options: [])
                return receiptString
            } catch {
                print("Couldn't read receipt data: \(error.localizedDescription)")
                return nil
            }
        }
        return nil
    }
    
    func isRunningInTestFlight() -> Bool {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL else { return false }
        return appStoreReceiptURL.lastPathComponent == "sandboxReceipt"
    }
    
    func getReceiptValidationURL() -> String {
        if isRunningInTestFlight() {
            return "https://sandbox.itunes.apple.com/verifyReceipt"
        } else {
#if DEBUG
            return "https://sandbox.itunes.apple.com/verifyReceipt"
#else
            return "https://buy.itunes.apple.com/verifyReceipt"
#endif
        }
    }
    
    
    // 向 Apple 验证收据
    func verifyReceipt(receiptData: String, completion: @escaping (Bool) -> Void) {
        self.transaction_json = nil
        // 创建请求URL，沙盒环境
        guard let url = URL(string: getReceiptValidationURL()) else {
            completion(false)
            return
        }
        // 创建请求数据
        let requestBody: [String: Any] = [
            "receipt-data": receiptData
        ]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            completion(false)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        // 发送请求
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to verify receipt: \(error?.localizedDescription ?? "No data")")
                completion(false)
                return
            }
            do {
                // 解析返回的数据
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("jsonResponse:\(jsonResponse)")
                    if let status = jsonResponse["status"] as? Int, status == 0 {
                        self.transaction_json = jsonResponse
                        // 验证成功
                        completion(true)
                    } else {
                        // 验证失败
                        print("Receipt verification failed with status: ")
                        completion(false)
                    }
                }
            } catch {
                print("Failed to parse receipt verification response: \(error.localizedDescription)")
                completion(false)
            }
        }
        task.resume()
    }
    
    func parseReceipt(response: [String: Any]) -> (
        bundleId: String,
        status: Int,
        productId: String,
        quantity: Int,
        transactionId: String,
        requestDateMs: Int64
    ) {
        // 取得外層值
        let status = response["status"] as? Int ?? 0
        
        
        // 取得 receipt 字典
        guard let receipt = response["receipt"] as? [String: Any] else {
            fatalError("Receipt not found")
        }
        
        // 取得 request_date_ms
        let requestDateMs: Int64
        if let requestDateMsValue = receipt["receipt_creation_date_ms"] as? NSNumber {
            requestDateMs = requestDateMsValue.int64Value
        } else if let requestDateMsValue = receipt["receipt_creation_date_ms"] as? String,
                  let intValue = Int64(requestDateMsValue) {
            requestDateMs = intValue
        } else {
            requestDateMs = 0
        }
        
        // 取得 bundle_id
        let bundleId = receipt["bundle_id"] as? String ?? ""
        
        // 取得 in_app 陣列中的第一筆交易資料
        guard let inApp = (receipt["in_app"] as? [[String: Any]])?.first else {
            fatalError("In-app purchase info not found")
        }
        
        // 從 in_app 交易資料中取得所需資訊
        let productId = inApp["product_id"] as? String ?? ""
        let quantity = inApp["quantity"] as? Int ?? 1
        let transactionId = inApp["transaction_id"] as? String ?? ""
        
        return (
            bundleId: bundleId,
            status: status,
            productId: productId,
            quantity: quantity,
            transactionId: transactionId,
            requestDateMs: requestDateMs
        )
    }
    
}



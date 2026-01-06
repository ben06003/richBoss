import UIKit

protocol Transform {
    func toJson(data: Data?) -> Any?
    func toObject<T: Codable>(data: Data?) -> T?
    func toDictionary<T>(_ parameter: T) -> Dictionary<String, Any>
    func toArray<T>(_ parameter: T) -> Array<Any>
    func toString<T>(_ parameter: T) -> String
    func toInt<T>(_ parameter: T) -> Int?
    func toDouble<T>(_ parameter: T) -> Double?
    func toFloat<T>(_ parameter: T) -> Float?
    func toBool<T>(_ parameter: T) -> Bool?
}

extension Transform {
    
    func toJson(data: Data?) -> Any? {
        guard let data = data else {
            print("parse json fail")
            return nil
        }
        do{
            return try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        } catch {
            print("parse json catch error:", error)
            return nil
        }
    }
    
    func toObject<T: Codable>(data: Data?) -> T? {
        guard let data = data else {
            print("parse json fail")
            return nil
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("parse json catch error:", error)
            return nil
        }
    }
    
    func toDictionary<T>(_ parameter: T) -> Dictionary<String, Any> {
        if let result = parameter as? Dictionary<String, Any> {
            return result
        } else if let result = parameter as?  Array<Any> {
            var temp = Dictionary<String, Any>()
            for (index, content) in result.enumerated() {
                temp["\(index)"] = content
            }
            return temp
        } else {
            return Dictionary<String, Any>()
        }
    }
    
    func toArray<T>(_ parameter: T) -> Array<Any> {
        if let result = parameter as? Dictionary<String, Any> {
            return result.map({ $0.value })
        } else if let result = parameter as? Array<Any> {
            return result
        } else {
            return Array<Any>()
        }
    }
    
    func toString<T>(_ parameter: T) -> String {
        if let result = parameter as? String {
            return result
        } else if let result = parameter as? Int {
            return String(result)
        } else if let result = parameter as? Double {
            return String(result)
        } else if let result = parameter as? Float {
            return String(result)
        } else {
            return ""
        }
    }
    
    func toInt<T>(_ parameter: T) -> Int? {
        if let result = parameter as? String {
            return Int(result)
        } else if let result = parameter as? Int {
            return result
        } else if let result = parameter as? Double {
            return Int(result)
        } else if let result = parameter as? Float {
            return Int(result)
        } else {
            return nil
        }
    }
    
    func toDouble<T>(_ parameter: T) -> Double? {
        if let result = parameter as? String {
            return Double(result)
        } else if let result = parameter as? Int {
            return Double(result)
        } else if let result = parameter as? Double {
            return result
        } else if let result = parameter as? Float {
            return Double(result)
        } else {
            return nil
        }
    }
    
    func toFloat<T>(_ parameter: T) -> Float? {
        if let result = parameter as? String {
            return Float(result)
        } else if let result = parameter as? Int {
            return Float(result)
        } else if let result = parameter as? Double {
            return Float(result)
        } else if let result = parameter as? Float {
            return result
        } else {
            return nil
        }
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

class ClientManager: Transform {
    
    private static let instance = ClientManager()
    static var shared: ClientManager {
        return self.instance
    }
    
    // MARK: -  get json
    enum HTTPMethod: String {
        case get = "GET", post = "POST", head = "HEAD"
    }
    
    enum Mimetype: String {
        case jpg = "image/jpeg"
        case mp4 = "video/mp4"
    }
    
    func getJsonData(method: HTTPMethod = .post, url: URL, body: Data? = nil, sec: TimeInterval = 10, finish: ((Data?) -> Void)? = nil) {
        var request: URLRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: sec)
        request.httpMethod = method.rawValue
        request.setValue("multipart/form-data; boundary=" + Data().boundary, forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        request.httpShouldHandleCookies = false
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request, completionHandler: {
            if let response = $1 as? HTTPURLResponse, response.statusCode != 200 {
                print("status code:", response.statusCode)
                finish?(nil)
                return
            }
            if let error = $2 {
                print("post error:", error)
                finish?(nil)
                return
            }
            finish?($0)
        })
        task.resume()
    }
    
    func getJsonObject(method: HTTPMethod = .post, url: URL, body: Data? = nil, sec: TimeInterval = 10, finish: ((Any?) -> Void)? = nil) {
        self.getJsonData(method: method, url: url, body: body, sec: sec) {
            finish?(self.toJson(data: $0))
        }
    }
    
    // MARK: - get image
    func getImageObject(imageURL url: URL, timeoutInterval sec: Double = 35, finish: @escaping (_ image: UIImage?) -> Void) {
        let request: URLRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: sec)
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if error != nil {
                print(error!)
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
    
    // MARK: - get file size
    func getHTTPHeaderContentLength(url: URL, sec: TimeInterval = 10, finish: ((Int64) -> Void)? = nil) {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: sec)
        request.httpMethod = HTTPMethod.head.rawValue
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            finish?(response?.expectedContentLength ?? 0)
        }
        task.resume()
    }
    
    // MARK: - check verion
    struct Version {
        var first = 0
        var second = 0
        var third = 0
        init() {
            
        }
        init(_ version: String) {
            let componets = version.components(separatedBy: ".")
            if let componet = componets.component(0), let first = Int(componet) {
                self.first = first
            }
            if let componet = componets.component(1), let second = Int(componet) {
                self.second = second
            }
            if let componet = componets.component(2), let third = Int(componet) {
                self.third = third
            }
        }
        // 判斷是否需要更新
        func compare(comparison: Version) -> Bool {
            if comparison.first > self.first {
                return true
            } else if comparison.first == self.first, comparison.second > self.second {
                return true
            } else if comparison.first == self.first, comparison.second == self.second, comparison.third > self.third {
                return true
            } else {
                return false
            }
        }
    }
    
    struct ApiResponse {
        enum UpdateType: Int {
            case notForced = 0
            case forced = 1
            case noHint = 2
        }
        enum VersionSource: Int {
            case appStore = 0
            case api = 1
        }
        var is_update: UpdateType
        var is_api_ver: VersionSource
        var version: Version
        var message: String
        init(_ jsonObject: Any?) {
            let dictionary = ClientManager.shared.toDictionary(jsonObject)
            let res_data = ClientManager.shared.toDictionary(dictionary["res_data"])
            if let _is_update = ClientManager.shared.toInt(res_data["is_update"]), let is_update = UpdateType(rawValue: _is_update) {
                self.is_update = is_update
            } else {
                self.is_update = .notForced
            }
            if let _is_api_ver = ClientManager.shared.toInt(res_data["is_api_ver"]), let is_api_ver = VersionSource(rawValue: _is_api_ver) {
                self.is_api_ver = is_api_ver
            } else {
                self.is_api_ver = .appStore
            }
            let version = ClientManager.shared.toString(res_data["version"])
            self.version = Version(version)
            let message = ClientManager.shared.toString(res_data["message"])
            if message.isEmpty {
                self.message = "您的App並非最新版本，請至「App Store」下載最新版本。"
            } else {
                self.message = message
            }
        }
    }
    
    struct AppleResponse: Transform {
        var version: Version
        init(_ jsonObject: Any?) {
            let dictionary = ClientManager.shared.toDictionary(jsonObject)
            let results = ClientManager.shared.toArray(dictionary["results"])
            guard let first = results.first else {
                self.version = Version()
                return
            }
            let result = ClientManager.shared.toDictionary(first)
            let version = ClientManager.shared.toString(result["version"])
            self.version = Version(version)
        }
    }
    
    func checkVersion(target: UIViewController) {
        // 取得infoDictionary，若為nil則無法比對，也就什麼都不用做了！
        guard let shortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return }
        let bundleVersion = Version(shortVersion)
        // 取得後端設定值。
        let path = ""
        guard let apiUrl = URL(string: path) else { return }
        self.getJsonObject(url: apiUrl) {
            let apiResponse = ApiResponse($0)
            guard apiResponse.is_update == .forced || apiResponse.is_update == .notForced else { return }
            switch apiResponse.is_api_ver {
            case .appStore:
                self.compareWithAppStore(target: target, apiResponse: apiResponse, bundleVersion: bundleVersion)
            case .api:
                self.compareWithApi(target: target, apiResponse: apiResponse, bundleVersion: bundleVersion)
            }
        }
    }
    
    private func compareWithAppStore(target: UIViewController, apiResponse: ApiResponse, bundleVersion: Version) {
        guard let identifier = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String else { return }
        guard let appleUrl = URL(string: "http://itunes.apple.com/lookup?bundleId=" + identifier) else { return }
        self.getJsonObject(url: appleUrl) {
            let appleResponse = AppleResponse($0)
            if !bundleVersion.compare(comparison: appleResponse.version) { return }
            self.showHint(message: apiResponse.message, isUpdate: apiResponse.is_update, target: target)
        }
    }
    
    private func compareWithApi(target: UIViewController, apiResponse: ApiResponse, bundleVersion: Version) {
        if !bundleVersion.compare(comparison: apiResponse.version) { return }
        self.showHint(message: apiResponse.message, isUpdate: apiResponse.is_update, target: target)
    }
    
    private func showHint(message: String, isUpdate: ApiResponse.UpdateType, target: UIViewController) {
        let path = "http://itunes.apple.com/app/id1234567"
        let alertController = UIAlertController (title: nil, message: message, preferredStyle: .alert)
        let noAction = UIAlertAction(title: "否", style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: "是", style: .default) { _ in
            guard let url = URL(string: path) else { return }
            DispatchQueue.main.async { UIApplication.shared.open(url: url); exit(0) }
        }
        let recognizeAction = UIAlertAction(title: "知道了", style: .default) { _ in
            guard let url = URL(string: path) else { return }
            DispatchQueue.main.async { UIApplication.shared.open(url: url); exit(0) }
        }
        switch isUpdate {
        case .forced:
            alertController.addAction(recognizeAction)
            DispatchQueue.main.async { target.present(alertController, animated: true, completion: nil) }
        case .notForced:
            alertController.addAction(noAction)
            alertController.addAction(yesAction)
            DispatchQueue.main.async { target.present(alertController, animated: true, completion: nil) }
        case .noHint:
            break
        }
    }
    
}

extension Data {
    
    var boundary: String {
        return "Boundary-\(UIDevice.current.identifierForVendor!.uuidString)"
    }
    
    mutating private func appendString(_ string: String) {
        self.append(string.data(using: String.Encoding.utf8)!)
    }
    
    mutating func appendPOSTParameter(name: String?, value: String?) {
        if name == nil || value == nil { return }
        if name!.isEmpty || value!.isEmpty { return }
        var data = Data()
        data.appendString("--\(self.boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(name!)\"\r\n\r\n")
        data.appendString("\(value!)\r\n")
        self.append(data)
    }
    
    mutating func appendPOSTFile(name: String?, filename: String?, mimetype: ClientManager.Mimetype, fileData: Data?) {
        if name == nil || filename == nil || fileData == nil { return }
        if name!.isEmpty || filename!.isEmpty { return }
        var data = Data()
        data.appendString("--\(self.boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(name!)\"; filename=\"\(filename!)\"\r\n")
        data.appendString("Content-Type: \(mimetype.rawValue)\r\n\r\n")
        /*
         jpg -> UIImageJPEGRepresentation(UIImage(named: "xxx.jpg")!, 1.0)!
         */
        data.append(fileData!)
        data.appendString("\r\n")
        self.append(data)
    }
    
    mutating func appendEndingBoundary() {
        self.append("--\(self.boundary)--\r\n".data(using: String.Encoding.utf8)!)
    }
    
}

extension UIImageView {
    
    private func replaceImage(image: UIImage) {
        DispatchQueue.main.async {
            self.image = image
        }
    }
    
    func loadFromWeb(default _default: UIImage, url: URL?) {
        self.replaceImage(image: _default)
        guard let url = url else { return }
        ClientManager.shared.getImageObject(imageURL: url) { object in
            guard let image = object else { return }
            self.replaceImage(image: image)
        }
    }
    
}

extension UIApplication {
    
    func open(url: URL) { // openUrl
        if #available(iOS 10, *) {
            self.open(url, options: [:], completionHandler: nil)
        } else {
            self.openURL(url)
        }
    }
    
}

extension Array {
    
    func component(_ index: Int) -> Element? {
        if self.count <= index {
            return nil
        } else {
            return self[index]
        }
    }
    
}

//
//  VersionManager.swift
//  TWETK
//
//  Created by MUKI on 2017/12/8.
//  Copyright © 2017年 羅祐昌. All rights reserved.
//

import UIKit

class VersionManager: NSObject {

    private static let instance = VersionManager()
    static var shared: VersionManager {
        return self.instance
    }
    
    enum VersionError: Error {
        case invalidResponse, invalidBundleInfo
    }
    
    struct Version {
        var first = 0
        var second = 0
        var third = 0
        init(_ version: String) {
            let model = version.components(separatedBy: ".")
            if model.count != 3 { return }
            guard let first = Int(model[0]), let second = Int(model[1]), let third = Int(model[2]) else { return }
            self.first = first
            self.second = second
            self.third = third
        }
    }
    
    func isUpdateAvailable(completion: @escaping (Bool?, Error?) -> Void) throws -> URLSessionDataTask {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=" + identifier) else {
                throw VersionError.invalidBundleInfo
        }
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                if let error = error { throw error }
                guard let data = data else { throw VersionError.invalidResponse }
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
                guard let result = (json?["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String else {
                    throw VersionError.invalidResponse
                }
                let bundleVersion = Version(currentVersion)
                let appstoreVersion = Version(version)
                SHPrint("bundleVersion:", bundleVersion, "appstoreVersion:", appstoreVersion)
                if appstoreVersion.first > bundleVersion.first {
                    completion(true, nil)
                } else if appstoreVersion.first == bundleVersion.first, appstoreVersion.second > bundleVersion.second {
                    completion(true, nil)
                } else if appstoreVersion.first == bundleVersion.first, appstoreVersion.second == bundleVersion.second, appstoreVersion.third > bundleVersion.third {
                    completion(true, nil)
                } else {
                    completion(false, nil)
                }
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
        return task
    }
    
}

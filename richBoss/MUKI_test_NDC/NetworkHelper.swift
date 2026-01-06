//
//  NetworkHelper.swift
//  MUKI_test_NDC
//
//  Created by YUAN JUNG LI on 2023/1/15.
//  Copyright © 2023 EICAPITAN. All rights reserved.
//

import Foundation

struct fileJAC: Codable {
    let md5: String
    let path: String
}

struct fileJA: Codable {
    let fileJA: [fileJAC]
    let domain: String
}

class NetworkHelper {
    func getJSON(from url: URL, completion: @escaping (Result<fileJA, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(NSError(domain: "response error", code: 0, userInfo: nil)))
                    return
            }
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let user = try decoder.decode(fileJA.self, from: data)
                    completion(.success(user))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}


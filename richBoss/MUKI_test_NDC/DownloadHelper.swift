//
//  DownloadHelper.swift
//  MUKI_test_NDC
//
//  Created by YUAN JUNG LI on 2023/1/15.
//  Copyright © 2023 EICAPITAN. All rights reserved.
//


import Foundation

class DownloadHelper: NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    var downloadTasks = [URLSessionDownloadTask]()
    var downloadProgress = [Float]()
    var downloadUrls = [String]()
    var localDownloadUrls = [String]()
    let fileManager = FileManager.default
    let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

    func downloadFiles(from urls: [String], domain: String) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)

        self.downloadUrls = urls

        for i in 0..<urls.count {
            let thisUrl = urls[i]
            let destinationUrl = documentsUrl!.appendingPathComponent(String(thisUrl.dropFirst()))
            print("destinationUrl1:\(destinationUrl)")
            if fileManager.fileExists(atPath: destinationUrl.path) {
                print("File exists")
            } else {
               let request = try! URLRequest(url: URL(string: "https://" + domain + urls[i])!)
               let task = session.downloadTask(with: request)
               downloadTasks.append(task)
               downloadProgress.append(0.0)
               task.resume()
            }
        }
    }

    // URLSessionDownloadDelegate
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let index = downloadTasks.firstIndex(of: downloadTask) {
            do {
                // 處理下載完成後的檔案
                let thisUrl = downloadUrls[index]
                let destinationUrl = documentsUrl!.appendingPathComponent(String(thisUrl.dropFirst()))
                print("destinationUrl2:\(destinationUrl)")
                self.createFolder(url: destinationUrl.deletingLastPathComponent()) // 若資料夾不存在，檔案建立失敗。
                try? FileManager.default.moveItem(at: location, to: destinationUrl)
            } catch (let writeError) {
                print("error writing file \(downloadUrls[index]) : \(writeError)")
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if let index = downloadTasks.firstIndex(of: downloadTask) {
            print("下載index:\(index)")
            downloadProgress[index] = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            print("Download \(index + 1) progress: \(downloadProgress[index])")
            // Update progress bar here
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("Download completed with error: \(error?.localizedDescription ?? "")")
    }
    
    func createFolder(url: URL) -> Bool {
        /*
         createIntermediates
         If true, this method creates any non-existent parent directories as part of creating the directory in url. If false, this method fails if any of the intermediate parent directories does not exist.
         */
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            print("資料夾" + url.lastPathComponent + "建立成功")
            return true
        } catch {
            print("資料夾" + url.lastPathComponent + "建立失敗")
            return false
        }
        //資料夾若已存在，重複建立資料夾並不會刪除裡面原有之檔案
    }
    
}

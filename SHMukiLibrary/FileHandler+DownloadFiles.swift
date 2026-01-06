//
//  FileHandler+DownloadFiles.swift
//  MUKI_Shipgo17
//
//  Created by smallHappy on 2018/6/15.
//  Copyright © 2018年 EICAPITAN. All rights reserved.
//

import Foundation

extension FileHandler {
    
    func downloadFiles(files: [String], _downloadVC:DownloadVC) {
        
        var fileModel = files.map({ URL(string: $0) }).compactMap({ $0 })
        
        _downloadVC.create(_files: files)
        _downloadVC._progressView.progress = 0
        _downloadVC._allCountTitle.text = "0"+" / "+String(_downloadVC._allCount)
        
        // 開始遞迴下載檔案
        func recursive() {
            guard let file = fileModel.first else { return }
            //print(file.path)
            //print()
            //_downloadVC._downloadTitle.text = //_downloadValue
//            _downloadVC._downloadValue = (file.path).disString(_indexStr: "/").last
            
            self.downloadFile(AtServer: file, _downloadVC: _downloadVC) {
                //print("------------------------ = \(_downloadVC._comCount)")
                _downloadVC._comCount = _downloadVC._comCount+1
                DispatchQueue.main.async {
                    _downloadVC._progressView.progress = Float(_downloadVC._comCount/_downloadVC._allCount)
                    _downloadVC._allCountTitle.text = String(_downloadVC._comCount)+" / "+String(_downloadVC._allCount)
                    _downloadVC._percentTitle.text = String(Int(_downloadVC._comCount/_downloadVC._allCount)*100)+"%"
                    if _downloadVC._comCount == _downloadVC._allCount {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            _downloadVC.cancelAction()
                        }
                    }
                }
                
                fileModel.removeFirst()
                recursive()
            }
        }
        recursive()
    }
    
    func downloadFile(AtServer url: URL, _downloadVC:DownloadVC, finish: (() -> Void)? = nil) {
        // 產生server_url與device_url
        guard let model = self.retrieveURLs(AtServer: url) else { return }
        let server_url = model.server_url
        let device_url = model.device_url
        // 若無法從伺服器取得檔案大小，其實也不需要下載了...
        ClientManager.shared.getHTTPHeaderContentLength(url: server_url) { server_size in
            // 取得本機檔案尺寸，若為nil，則代表找不到檔案，則需下載。
            guard let size = self.getFileSize(path: device_url.path), size != 0 else {
                self.download(server_url: server_url, device_url: device_url) {
                    finish?()
                }
                return
            }
            let device_size = Int64(size)
            // 將本機檔案尺寸與伺服器檔案尺寸做比對
            if device_size == server_size {
                // 檔案尺寸相等，不需下載
                finish?()
            } else {
                // 檔案尺寸不相等，需下載
                FileHandler.shared.deleteFile(path: device_url)
                self.download(server_url: server_url, device_url: device_url) {
                    finish?()
                }
            }
            /*
             SHPrint {
             print("📁📁📁📁📁")
             print("server_url:", server_url)
             print("device_url:", device_url.path)
             print("server_size:", server_size, "device_size:", device_size)
             }
             */
        }
    }
    
    private func retrieveURLs(AtServer url: URL) -> (server_url: URL, device_url: URL)? {
        let fileName = url.lastPathComponent
        let device_url = FileHandler.shared.path(folder: .files).appendingPathComponent(fileName)
        return (url, device_url)
    }
    
    private func download(server_url: URL, device_url: URL, finish: (() -> Void)? = nil) {
        JsonManager.sharedInstance.getFileData(fileURL: server_url, timeoutInterval: 600) {
            if let data = $0 {
                try? data.write(to: device_url)
            }
            finish?()
            //SHPrint("💯💯💯", "檔案已下載(或無法下載)")
        }
    }
    
}

//
//  FileHandler.swift
//  FileHandling1
//
//  Created by smallHappy on 2017/9/20.
//  Copyright © 2017年 SmallHappy. All rights reserved.
//

import UIKit


class FileHandler: NSObject {

    private static let instance = FileHandler()
    static var shared: FileHandler {
        return self.instance
    }
    
    /*
     參考資料： http://www.jianshu.com/p/de591f5389e1
     */
    
    // 假設專案需要有這些資料夾。(請依實際狀況調整為自己所需要的名稱)
    enum Folder: String {
        case files = "files"
    }
    
    var documentPath: URL {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return URL(fileURLWithPath: path)
    }
    
    func path(folder: Folder) -> URL {
        return self.documentPath.appendingPathComponent(folder.rawValue)
    }
    
    func path2(string: String) -> URL {
        return self.documentPath.appendingPathComponent(string)
    }
    
    @discardableResult
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
    
    @discardableResult
    func createFileByString(content: String, url: URL) -> Bool {
        self.createFolder(url: url.deletingLastPathComponent()) // 若資料夾不存在，檔案建立失敗。
        do {
            try content.write(toFile: url.path, atomically: true, encoding: .utf8)
            print("檔案" + url.lastPathComponent + "建立成功")
            return true
        } catch {
            print("檔案" + url.lastPathComponent + "建立失敗")
            return false
        }
        //若檔案已存在，將複寫其內容。
    }
    
    @discardableResult
    func readTxtFile(url: URL) -> Bool {
        do {
            let content = try String(contentsOf: url)
            print("====== content ======\n" + content)
            return true
        } catch {
            print("檔案" + url.lastPathComponent + "讀取失敗")
            return false
        }
    }
    
    @discardableResult
    func contentsOfDirectory(url: URL) -> (dirArray: [String], fileArray: [String])? {
        do {
            let contentArray = try FileManager.default.contentsOfDirectory(atPath: url.path)
            var dirArray = [String]()
            var fileArray = [String]()
            var isDir: ObjCBool = false
            print("=========")
            print("路徑資料夾內的檔案：\(contentArray)")
            for file in contentArray {
                let subPath = url.appendingPathComponent(file)
                if FileManager.default.fileExists(atPath: subPath.path, isDirectory: &isDir) {
                    if isDir.boolValue {
                        print(file + "是資料夾")
                        dirArray.append(file)
                    } else {
                        print(file + "非資料夾")
                        fileArray.append(file)
                    }
                }
            }
            print("資料夾共有：\(dirArray.count)個")
            print("檔案共有：\(fileArray.count)個")
            print("=========")
            return (dirArray, fileArray)
        } catch {
            print("無法解析路徑資料夾：" + url.path)
            return nil
        }
    }
    
    @discardableResult
    func copyBundleFileToFolder(path: URL, name: String, extensionString: String) -> Bool {
        let file = path.appendingPathComponent(name + "." + extensionString)
        if FileManager.default.fileExists(atPath: file.path) {
            print("資源檔(" + file.lastPathComponent + ")已存在，不需複製。")
            return false
        }
        guard let bundle = Bundle.main.path(forResource: name, ofType: extensionString) else {
            print("資源檔(" + file.lastPathComponent + ")不存在，複製失敗。")
            return false
        }
        self.createFolder(url: path)
        do {
            try FileManager.default.copyItem(atPath: bundle, toPath: file.path)
            print("資源檔(" + file.lastPathComponent + ")複製成功")
            return true
        } catch {
            print("資源檔(" + file.lastPathComponent + ")複製失敗")
            return false
        }
    }
    
    @discardableResult
    func deleteFile(path: URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: path)
            print("刪除檔案" + path.lastPathComponent + "成功")
            return true
        } catch {
            print("刪除檔案" + path.lastPathComponent + "失敗")
            return false
        }
    }
    
    @discardableResult
    func getFileSize(path: String) -> UInt64? {
        guard let attribute = try? FileManager.default.attributesOfItem(atPath: path) else { return nil }
        return attribute[FileAttributeKey.size] as? UInt64
    }
    
}

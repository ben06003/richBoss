//
//  ViewModel.swift
//  HBuilder-Integrate-Swift
//
//  Created by smallHappy on 2018/3/26.
//  Copyright © 2018年 EICAPITAN. All rights reserved.
//

import Foundation

class ViewModel {
    
    private static let instance = ViewModel()
    static var shared: ViewModel = {
        return self.instance
    }
    
    var array = [DCloudWebView]()
    
    func receivePage(name: String, url: String, frame: CGRect, style: PagingStyle, property: WebViewProperty = .main) -> DCloudWebView? {
        #if DEBUG
        defer {
            print("======", #file.components(separatedBy: "/").last ?? "unknown file", "======")
            for page in self.array {
                let info1 = page.name ?? "unknown page name"
                let info2 = page.webViewProperty
                print(info1, info2)
            }
        }
        #endif
        if let index = self.array.index(where: { $0.name == name }) {
            let view = self.array.component(index)
            switch style {
            case .push:
                view?.frame.origin.x = UIScreen.main.bounds.width
            case .pop:
                view?.frame.origin.x = -UIScreen.main.bounds.width   
            case .tab:
                break
            }
            if view?.webViewProperty == .main {
                self.clear()
            } else if view?.webViewProperty == .sub {
                self.array.removeLast()
            }
            UIView.animate(withDuration: 0.2, delay: 0.2, animations: {
                view?.frame.origin.x = 0
            })
            return view
        } else {
            let view = DCloudWebView(name: name, loadURL: url, frame: frame)
            view?.name = name
            view?.webViewProperty = property
            if let view = view {
                self.array.append(view)
            }
            return view
        }
    }
    
    func clear() {
        for (offset, element) in self.array.enumerated() {
            if element.webViewProperty == .main { continue }
            self.array.component(offset)?.removeFromSuperview()
        }
        self.array = self.array.filter({ $0.webViewProperty == .main })
    }
    
}

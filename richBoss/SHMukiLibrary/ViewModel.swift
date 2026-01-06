//
//  ViewModel.swift
//  MUKI_Shipgo17
//
//  Created by smallHappy on 2018/3/26.
//  Copyright © 2018年 EICAPITAN. All rights reserved.
//

import Foundation

protocol ViewModelDelegate {
    func viewModel()
}

class ViewModel {
    
    private static let instance = ViewModel()
    static var shared: ViewModel {
        return self.instance
    }
    
    var delegate: ViewModelDelegate?
    
    var array = [DCloudWebView]()
    
    func receivePage(name: String, url: String, frame: CGRect, style: PagingStyle, property: WebViewProperty = .sub) -> DCloudWebView? {
        #if DEBUG
        defer {
            print("👻👻👻👻", #file.components(separatedBy: "/").last ?? "unknown file", "👻👻👻👻")
            for page in self.array {
                let info1 = page.name ?? "unknown page name"
                let info2 = page.webViewProperty
                print(info1, info2)
            }
        }
        #endif
        //print(self.array.index(where: { $0.name == name && $0.url == url }))
        
        //print("----------")
        /*
        for _i in 0..<self.array.count {
            print(self.array[_i].name)
            print(name)
            print(self.array[_i].url)
            print(url)
        }
        */
        if let index = self.array.index(where: { $0.name == name && $0.url == url && $0.url != "https://drink.muki001.com/website/set_list" && $0.url != "https://drink.muki001.com/website/logout_check" }) {
            let view = self.array.component(index)
         print(index)
            switch style {
            case .push:
                view?.frame.origin.x = UIScreen.main.bounds.width
            case .pop:
                view?.frame.origin.x = -UIScreen.main.bounds.width
            case .tab:
                view?.frame.origin.x = 0
            case .normal:
                break
            }
            UIView.animate(withDuration: 0.2, delay: 0.2, animations: {
                view?.frame.origin.x = 0
            }, completion: { _ in
                self.delegate?.viewModel()
            })
            if view?.webViewProperty == .main {
                self.clear()
            }
            if (style == .pop || style == .tab), view?.webViewProperty == .sub {
                let last = self.array.removeLast()
                last.removeFromSuperview()
            }
            view?.url = url
            return view
        } else {
            for _view in self.array {
                if _view.name != name && _view.url != url { continue }
                _view.removeFromSuperview()
            }
            self.array = self.array.filter({ $0.name != name && $0.url != url })
            let view = DCloudWebView(name: name, loadURL: url, frame: frame)
            
            view?.name = name
            view?.url = url
            view?.webViewProperty = property
    
            if let view = view {
                self.array.append(view)
            }
            if property == .main {
                self.clear()
            }
    
            view?.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                //print("----- isHidden isHidden isHidden isHidden-----")
                view?.isHidden = false
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
    
    func remove(_ name: String) {
        
        for (offset, element) in self.array.enumerated() {
            if element.name != name { continue }
            self.array.component(offset)?.removeFromSuperview()
        }
        self.array = self.array.filter({ $0.name != name })
    }
    
}

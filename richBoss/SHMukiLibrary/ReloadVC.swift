//
//  ReloadVC.swift
//  MUKI_Shipgo17
//
//  Created by smallHappy on 2018/6/14.
//  Copyright © 2018年 EICAPITAN. All rights reserved.
//

import UIKit

protocol ReloadVCDelegate {
    
    func reloadVC()
    
}

class ReloadVC: UIViewController {
    var delegate: ReloadVCDelegate?
    lazy var imageView: UIImageView = {
        let _view = UIImageView(image: UIImage(named: "noNet"))
        _view.contentMode = .scaleAspectFit
        self.view.addSubview(_view)
        return _view
    }()
    
    override func loadView() {
        super.loadView()
        self.view = UIView(frame: UIScreen.main.bounds)
        self.view.backgroundColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setUI()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if DeviceInfoManager.shared.connectedToNetwork {
            self.dismiss(animated: true, completion: nil)
            self.delegate?.reloadVC()
//        } else {
//            self.imageView.vibrate()
//            exit(0)
//        }
    }
    
    private func setUI() {
        let imageS = frameW * 2 / 3
        self.imageView.setFrame(width: imageS, height: imageS)
        self.imageView.center = self.view.center
    }

}

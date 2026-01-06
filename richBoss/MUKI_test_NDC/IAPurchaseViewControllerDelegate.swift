//
//  IAPurchaseViewControllerDelegate.swift
//  MUKI_test_NDC
//
//  Created by YUAN JUNG LI on 2022/5/14.
//  Copyright © 2022 EICAPITAN. All rights reserved.
//

import Foundation

protocol IAPurchaseViewControllerDelegate {
    func didBuySomething(_ iapViewController: WebViewController, _ product: Product)
}

enum Product {
    case consumable
    case nonConsumable
    case restore
}

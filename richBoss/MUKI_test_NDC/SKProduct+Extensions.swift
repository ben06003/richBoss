//
//  SKProduct+Extensions.swift
//  MUKI_test_NDC
//
//  Created by YUAN JUNG LI on 2022/5/14.
//  Copyright © 2022 EICAPITAN. All rights reserved.
//

import StoreKit

extension SKProduct {
    var regularPrice: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)
    }
}

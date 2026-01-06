//
//  DateManager.swift
//  DemoDateFormatter
//
//  Created by smallHappy on 2017/8/3.
//  Copyright © 2017年 SmallHappy. All rights reserved.
//

import UIKit

class DateManager: NSObject {
    
    private static let instance = DateManager()
    static var shared: DateManager {
        return self.instance
    }
    
    var formatterString = "yyyyMMddHHmmss"
    // 參考資料： - http://nsdateformatter.com
    
    enum Zone: String {
        case taiwan = "GMT+8"
        case hawaii = "GMT-10"
        case Iindia = "GMT+05"
    }
    
    func getNowWithFormatter(zone: Zone = .taiwan) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: zone.rawValue)
        dateFormatter.dateFormat = self.formatterString
        return dateFormatter.date(from: dateFormatter.string(from: Date()))
    }
    
    func string2Date(zone: Zone = .taiwan, _ string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: zone.rawValue)
        dateFormatter.dateFormat = self.formatterString
        return dateFormatter.date(from: string)
    }
    
    func date2String(zone: Zone = .taiwan, _ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: zone.rawValue)
        dateFormatter.dateFormat = self.formatterString
        return dateFormatter.string(from: date)
    }
    
    func compare(baseline: Date, comparison: Date, ascending: @escaping () -> (), same: @escaping () -> (), descending: @escaping () -> ()) {
        switch comparison.compare(baseline) {
        case .orderedAscending:
            ascending()
        case .orderedSame:
            same()
        case .orderedDescending:
            descending()
        }
    }
    
}

extension Date {
    
    var toString: String {
        return DateManager.shared.date2String(self)
    }
    
}

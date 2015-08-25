//
//  NSDate.swift
//  Pokebu
//
//  Created by Yusuke Aono on 8/25/15.
//  Copyright © 2015 Yusuke Aono. All rights reserved.
//

import Foundation

extension NSDate {
    class func jpDateFromString(dateStr: String) -> NSDate {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja")
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return dateFormatter.dateFromString(dateStr)!
    }
}
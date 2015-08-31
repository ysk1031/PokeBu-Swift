//
//  CustomUiApplication.swift
//  Pokebu
//
//  Created by Yusuke Aono on 8/30/15.
//  Copyright © 2015 Yusuke Aono. All rights reserved.
//

import Foundation
import UIKit

@objc(CustomUiApplication) class CustomUiApplication: UIApplication {
    override func openURL(url: NSURL) -> Bool {
        if let host = url.host {
            if host == "getpocket.com" {
                NSNotificationCenter.defaultCenter().postNotificationName("PocketAuthStartNotification",
                    object: url
                )
                return false
            }
        }
        
        return super.openURL(url)
    }
}
//
//  UIAlertController.swift
//  Pokebu
//
//  Created by Yusuke Aono on 8/22/15.
//  Copyright © 2015 Yusuke Aono. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    static func setRequestFailureMessage(message: String) -> UIAlertController {
        let alertView = self.init(title: "エラー", message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: { action in return })
        alertView.addAction(okAction)
        return alertView
    }
}
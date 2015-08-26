//
//  UILabel.swift
//  Pokebu
//
//  Created by Yusuke Aono on 8/26/15.
//  Copyright © 2015 Yusuke Aono. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    class func heightForLabelText(text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let label: UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.font = font
        label.text = text
        label.sizeToFit()
        
        return label.frame.height
    }
}
//
//  HatenaBookmark.swift
//  Pokebu
//
//  Created by Yusuke Aono on 8/25/15.
//  Copyright © 2015 Yusuke Aono. All rights reserved.
//

import Foundation

class HatenaBookmark {
    var comment: String?
    var userName: String?
    var userImage: String?
    var addedTime: NSDate?
    
    init(userName: String?, comment: String?, userImage: String?, addedTime: NSDate?) {
        self.userName = userName
        self.comment = comment
        self.userImage = userImage
        self.addedTime = addedTime
    }
}
//
//  HatenaApiAccess.swift
//  Pokebu
//
//  Created by Yusuke Aono on 8/25/15.
//  Copyright © 2015 Yusuke Aono. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class HatenaApiAccess {
    let apiBaseUrl: String = "http://b.hatena.ne.jp/entry/jsonlite/"
    let HAAFetchCompleteNotification: String = "HAAFetchCompleteNotification"
    
    var bookmarks: [HatenaBookmark] = [HatenaBookmark]()
    
    init() {}

    func fetchBookmarkDataOf(url: String) {
        let requestParams: Dictionary = [
            "url": url
        ]
        
        Alamofire.request(.GET, apiBaseUrl, parameters: requestParams).response(
            completionHandler: { request, response, data, error in
                if error != nil {
                    var message = "不明なエラーが発生しました。"
                    if let description = error?.localizedDescription {
                        message = description
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName(
                        self.HAAFetchCompleteNotification + "_\(url)",
                        object: nil,
                        userInfo: ["error": message]
                    )
                }
                
                if data == nil { return }
                
                let json = JSON(data: data!)
                for (_, bookmark) in json["bookmarks"] {
                    let userName = bookmark["user"].string
                    let comment = bookmark["comment"].string
                    let biliteralUserName: String = (userName! as NSString).substringToIndex(2)
                    let userImage = "http://cdn1.www.st-hatena.com/users/\(biliteralUserName)/\(userName!)/profile.gif"
                    let timestampStr = bookmark["timestamp"].string
                    let addedTime = NSDate.jpDateFromString(timestampStr!)
                    
                    let bookmark: HatenaBookmark = HatenaBookmark(userName: userName, comment: comment, userImage: userImage, addedTime: addedTime)
                    self.bookmarks.append(bookmark)
                }
                
                NSNotificationCenter.defaultCenter().postNotificationName(
                    self.HAAFetchCompleteNotification + "_\(url)",
                    object: nil
                )
            }
        )
    }
}
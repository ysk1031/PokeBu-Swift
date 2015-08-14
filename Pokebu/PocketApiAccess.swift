//
//  PocketApiAccess.swift
//  Pokebu
//
//  Created by Yusuke Aono on 8/13/15.
//  Copyright © 2015 Yusuke Aono. All rights reserved.
//

import Foundation
import PocketAPI
import Keys
import Alamofire
import SwiftyJSON

class PocketApiAccess {
    let apiBaseUrl = "https://getpocket.com/v3/"
    let accessToken = PocketAPI.sharedAPI().pkt_getToken
    let consumerKey = PokebuKeys().pocketSdkConsumerKey()
    
    let PAAFetchStartNotification = "PAAFetchStartNotification"
    let PAAFetchCompleteNotification = "PAAFetchCompleteNotification"
    
    var items = [PocketItem]()
    
    init() {}
    
    func fetchData() {
        let methodUrl = apiBaseUrl + "get"
        let requestParams: Dictionary = [
            "consumer_key": consumerKey,
            "access_token": accessToken,
            "detailType": "complete",
            "count": "20"
        ]
        Alamofire.request(.GET, methodUrl, parameters: requestParams).response { (request, response, data, error) in
            if error != nil {
                var message = "不明なエラーが発生しました。"
                if let description = error?.description {
                    message = description
                }
                print(message)
                return
            }
            
            var json = JSON.null
            if data == nil { return }
            json = JSON(data: data!)
            for (_, elem) in json["list"] {
                let id = Int(elem["item_id"].string!)                
                var title: String?
                if let resolvedTitle = elem["resolved_title"].string {
                    title = resolvedTitle
                } else {
                    if let givenTitle = elem["given_title"].string {
                        title = givenTitle
                    }
                }
                let url = elem["resolved_url"].string
                let excerpt = elem["excerpt"].string
                let imgSrc = elem["image"]["src"].string
                let timestamp = Int(elem["time_added"].string!)
                
                let item = PocketItem(id: id!, title: title, url: url!, excerpt: excerpt, imgSrc: imgSrc, timestamp: timestamp!)
                self.items.append(item)
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(self.PAAFetchCompleteNotification, object: nil)
        }
    }
}
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
    let itemCountPerPage = 20
    
    let PAAFetchStartNotification = "PAAFetchStartNotification"
    let PAAFetchCompleteNotification = "PAAFetchCompleteNotification"
    
    var items = [PocketItem]()
    var fetching = false
    var fetchingFullList = false
    var totalItemCount = 0
    
    init() {}
    
    func fetchData() {
        // 読み込み中ならreturn
        if fetching { return }
        
        let methodUrl = apiBaseUrl + "get"
        let requestParams: Dictionary = [
            "consumer_key": consumerKey,
            "access_token": accessToken,
            "detailType": "complete",
            "offset": String(totalItemCount),
            "count": String(itemCountPerPage)
        ]
        // 読み込み開始
        fetching = true
        Alamofire.request(.GET, methodUrl, parameters: requestParams).response { (request, response, data, error) in
            if error != nil {
                var message = "不明なエラーが発生しました。"
                if let description = error?.localizedDescription {
                    message = description
                }
                // エラーで読み込み終了
                self.fetching = false
                NSNotificationCenter.defaultCenter().postNotificationName(self.PAAFetchCompleteNotification,
                    object: nil,
                    userInfo: ["error": message]
                )
                return
            }
            
            var json = JSON.null
            if data == nil {
                self.fetching = false
                return
            }
            json = JSON(data: data!)
            
            for (_, elem) in json["list"] {
                let id = Int(elem["item_id"].string!)                

                var title: String = elem["resolved_title"].string!
                if title.isEmpty {
                    title = elem["given_title"].string!
                }
                let url = elem["resolved_url"].string
                let excerpt = elem["excerpt"].string
                let imgSrc = elem["image"]["src"].string
                let timestamp = Int(elem["time_added"].string!)
                let sortId = elem["sort_id"].int! + self.totalItemCount
                
                let item = PocketItem(id: id!, title: title, url: url!, excerpt: excerpt, imgSrc: imgSrc, timestamp: timestamp!, sortId: sortId)
                self.items.append(item)
            }

            // sort_id順にソート
            self.items = self.items.sort { (elem1: PocketItem, elem2: PocketItem) -> Bool in
                return elem1.sortId < elem2.sortId
            }
            
            // totalItemCountに現在取得済のアイテム数を格納
            self.totalItemCount = self.items.count
            
            // 取得したアイテム数が itemCountPerPage 未満なら、全てのアイテムを取得し終えたと判断
            if json["list"].count < 20 { self.fetchingFullList = true }
            
            // 読み込み終了
            self.fetching = false
            NSNotificationCenter.defaultCenter().postNotificationName(self.PAAFetchCompleteNotification, object: nil)
        }
    }
}
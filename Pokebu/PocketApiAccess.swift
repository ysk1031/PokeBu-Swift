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
    let itemCountPerPage = 50
    let dummyItem = PocketItem(id: 0, title: "", url: "", excerpt: nil, imgSrc: nil, timestamp: 0)
    
    let PAAFetchCompleteNotification = "PAAFetchCompleteNotification"
    let PAAArchiveStartNotification = "PAAArchiveStartNotification"
    let PAAArchiveCompletionNotification = "PAAArchiveCompletionNotification"
    
    var items = [PocketItem]()
    var fetching = false
    var fetchingFullList = false
    var totalItemCount = 0
    var lastFetchTime: Double = 0.0
    
    init() {}
    
    func fetchData(refresh refresh: Bool = false) {
        // 読み込み中ならreturn
        if fetching { return }
        
        let methodUrl = apiBaseUrl + "get"
        var requestParams: Dictionary = [
            "consumer_key": consumerKey,
            "access_token": accessToken,
            "detailType": "complete",
            "state": "unread"
        ]
        if refresh {
            requestParams["since"] = String(lastFetchTime)
        } else {
            requestParams["offset"] = String(totalItemCount)
            requestParams["count"] = String(itemCountPerPage)
        }
        
        // 読み込み開始
        fetching = true
        Alamofire.request(.GET, methodUrl, parameters: requestParams).response { (request, response, data, error) in
            if error != nil {
                var message = "不明なエラーが発生しました。"
                if let error = error as? NSError {
                    message = error.localizedDescription
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
            
            var fetchListLength = json["list"].count
            var fetchedItems: [PocketItem] = [PocketItem](count: fetchListLength, repeatedValue: self.dummyItem)
            for (_, elem) in json["list"] {
                let idStr = elem["item_id"].string
                var title = elem["resolved_title"].string
                if title == nil || title!.isEmpty {
                    title = elem["given_title"].string
                }
                var url = elem["resolved_url"].string
                if url == nil || url!.isEmpty {
                    url = elem["given_url"].string
                }
                let excerpt = elem["excerpt"].string
                let imgSrc = elem["image"]["src"].string
                let timestampStr = elem["time_added"].string
                let sortId = elem["sort_id"].int
                
                let item = PocketItem(id: Int(idStr!)!, title: title!, url: url!, excerpt: excerpt, imgSrc: imgSrc, timestamp: Int(timestampStr!)!)
                fetchedItems[sortId!] = item
            }
            if refresh {
                fetchedItems += self.items
                self.items = fetchedItems
            } else {
                self.items += fetchedItems
            }
            // セルに入るインスタンスが重複する可能性があるので、ユニークにする
            // FIX: やり方がイケてない
            self.items = self.filterUniqueItems(self.items)
            // 新規取得件数が減ったかもしれないので再代入
            fetchListLength = self.items.count - self.totalItemCount
 
            
            // totalItemCountに現在取得済のアイテム数を格納
            self.totalItemCount = self.items.count
            
            // lastFetchTimeに最終取得時間を格納
            self.lastFetchTime = NSDate().timeIntervalSince1970
            
            // 取得したアイテム数が itemCountPerPage 未満なら、全てのアイテムを取得し終えたと判断 (P2Rじゃないとき）
            if !refresh && fetchListLength < 1 {
                self.fetchingFullList = true
            }
            
            // 読み込み終了
            self.fetching = false
            NSNotificationCenter.defaultCenter().postNotificationName(self.PAAFetchCompleteNotification,
                object: nil,
                userInfo: ["newFetchedCount": fetchListLength]
            )
        }
    }
    
    func filterUniqueItems(items: [PocketItem]) -> [PocketItem] {
        var alreadyFetchedItemIds = [Int]()
        var uniqueItems = [PocketItem]()
        for item in items {
            if !alreadyFetchedItemIds.contains(item.id) {
                uniqueItems.append(item)
                alreadyFetchedItemIds.append(item.id)
            }
        }
        return uniqueItems
    }
    
    func archiveItemAtIndex(index: Int, itemId: Int) {
        NSNotificationCenter.defaultCenter().postNotificationName(PAAArchiveStartNotification,
            object: nil,
            userInfo: ["archivedItemIndex": index]
        )
        
        // APIに実際にアクセス
        let methodUrl = apiBaseUrl + "send"
        var requestParams: Dictionary = [
            "consumer_key": consumerKey,
            "access_token": accessToken
        ]
        let json = JSON(["action": "archive", "item_id": itemId])
        requestParams["actions"] = String([json])
        
        Alamofire.request(.GET, methodUrl, parameters: requestParams).response {
            request, response, data, error in
            if error != nil {
                var message = "不明なエラーが発生しました。"
                if let error = error as? NSError {
                    message = error.localizedDescription
                }
                NSNotificationCenter.defaultCenter().postNotificationName(self.PAAArchiveCompletionNotification,
                    object: nil,
                    userInfo: ["error": message]
                )
                return
            }
        }
    }
}
//
//  PocketItemOperation.swift
//  Pokebu
//
//  Created by Yusuke Aono on 8/25/15.
//  Copyright © 2015 Yusuke Aono. All rights reserved.
//

import Foundation
import UIKit
import HatenaBookmarkSDK

class PocketItemOperation {
    var item: PocketItem?
    var itemIndex: Int?
    var encodedUrl: String?
    var apiAccess: PocketApiAccess?
    
    init() {}
    
    init(item: PocketItem?, itemIndex: Int?, encodedUrl: String?, apiAccess: PocketApiAccess?) {
        self.item = item
        self.itemIndex = itemIndex
        self.encodedUrl = encodedUrl
        self.apiAccess = apiAccess
    }
    
    // ブックマーク
    func hatenaBookmarkOnViewController(vc: UIViewController) {
        let hatenaBookmarkViewController = HTBHatenaBookmarkViewController()
        hatenaBookmarkViewController.URL = NSURL(string: encodedUrl!)
        vc.presentViewController(hatenaBookmarkViewController, animated: true, completion: nil)
    }
    
    // アーカイブ
    func archiveOnViewController(vc: UIViewController) {
        let alert = UIAlertController(
            title: "確認",
            message: "この記事をアーカイブしますか？",
            preferredStyle: UIAlertControllerStyle.ActionSheet
        )
        let okAction = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.Default,
            handler: { action in
                vc.navigationController?.popToRootViewControllerAnimated(true)
                self.apiAccess!.archiveItemAtIndex(self.itemIndex!, itemId: self.item!.id)
            }
        )
        let cancelAction = UIAlertAction(
            title: "キャンセル",
            style: UIAlertActionStyle.Cancel,
            handler: { action in return }
        )
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        vc.presentViewController(alert, animated: true, completion: nil)
    }
    
    // シェアボタン
    func showActionSheetOnViewController(vc: UIViewController) {
        let activityController = UIActivityViewController(
            activityItems: [item!.title, encodedUrl!],
            applicationActivities: nil
        )
        vc.presentViewController(activityController, animated: true, completion: nil)
    }
}
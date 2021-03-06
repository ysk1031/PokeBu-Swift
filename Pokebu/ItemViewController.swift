//
//  ItemViewController.swift
//  Pokebu
//
//  Created by Yusuke Aono on 8/18/15.
//  Copyright © 2015 Yusuke Aono. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import SDWebImage
import DateTools
import HatenaBookmarkSDK
import SafariServices

class ItemViewController: UIViewController, TTTAttributedLabelDelegate, SFSafariViewControllerDelegate {
    @IBOutlet weak var favicon: UIImageView!
    @IBOutlet weak var itemTitle: TTTAttributedLabel!
    @IBOutlet weak var excerpt: UILabel!
    @IBOutlet weak var url: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var bookmarkViewButton: UIButton!
    
    @IBOutlet weak var excerptLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var urlTopMargin: NSLayoutConstraint!
    
    var encodedUrl: String?
    var item: PocketItem = PocketItem(id: 0, title: "", url: "", excerpt: nil, imgSrc: nil, timestamp: 0) {
        didSet {
            encodedUrl = item.url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        }
    }
    var index: Int?
    var apiAccess: PocketApiAccess = PocketApiAccess()
    var itemOperation: PocketItemOperation = PocketItemOperation()
    var bookmarkCount: Int = 0
    var bookmarkCountFetchCompleteObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        itemTitle.delegate = self
        setItemView()
        updateBookmarkCount()
        
        itemTitle.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "actionButtonTapped:"))
        
        itemOperation = PocketItemOperation(item: item, itemIndex: index, encodedUrl: encodedUrl, apiAccess: apiAccess)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(bookmarkCountFetchCompleteObserver!)
    }
    
    // MARK: - Application logic
    
    func setItemView() {
        // ファビコン
        let domain = NSURL(string: encodedUrl!)?.host
        favicon.sd_setImageWithURL(
            NSURL(string: "http://www.google.com/s2/favicons?domain=\(domain!)")
        )
        
        // 記事タイトル
        var displayTitle: String
        if item.title != "" {
            displayTitle = item.title
        } else {
            displayTitle = encodedUrl!
        }
        itemTitle.setText(displayTitle)
        itemTitle.linkAttributes = [
            kCTForegroundColorAttributeName : UIColor.themeColorLightGreen(),
            NSUnderlineStyleAttributeName : NSNumber(integer: NSUnderlineStyle.StyleNone.rawValue)
        ]
        itemTitle.activeLinkAttributes = [kCTForegroundColorAttributeName : UIColor.themeColorRed()]
        let titleRange: NSRange = (displayTitle as NSString).rangeOfString(displayTitle)
        itemTitle.addLinkToURL(NSURL(string: encodedUrl!), withRange: titleRange)
        
        // 抜粋
        excerpt.text = item.excerpt
        
        // URL
        url.text = item.url
        
        // 追加日
        let addedDate = NSDate(timeIntervalSince1970: Double(item.timestamp) as NSTimeInterval)
        date.text = "\(addedDate.timeAgoSinceNow())に追加"
        
        // ブックマーク閲覧ボタン
        bookmarkViewButton.setAttributedTitle(bookmarkCountButtonText(),
            forState: UIControlState.Normal
        )
    }
    
    func bookmarkCountButtonText() -> NSMutableAttributedString {
        let boldTextRange = NSMakeRange(0, NSAttributedString(string: String(bookmarkCount)).length)
        let mutableText: NSMutableAttributedString = NSMutableAttributedString(
            string: String(bookmarkCount) + " ブックマーク"
        )
        mutableText.addAttribute(NSForegroundColorAttributeName,
            value: UIColor.grayColor(),
            range: NSMakeRange(0, mutableText.length)
        )
        mutableText.addAttribute(NSForegroundColorAttributeName,
            value: UIColor.blackColor(),
            range: boldTextRange
        )
        mutableText.addAttribute(NSFontAttributeName,
            value: UIFont.boldSystemFontOfSize(16.0),
            range: boldTextRange
        )
        
        return mutableText
    }
    
    func updateBookmarkCount() {
        bookmarkCountFetchCompleteObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            item.BookmarkCountFetchCompleteNotification + "_\(item.id)",
            object: nil,
            queue: nil,
            usingBlock: { notification in
                if notification.userInfo != nil {
                    if let userInfo = notification.userInfo as? [String: Int] {
                        if let bookmarkCount = userInfo["bookmarkCount"] {
                            self.bookmarkCount = bookmarkCount
                            let bookmarkCountButtonText = self.bookmarkCountButtonText()
                            
                            // アニメーションをオフにしてから、ブックマーク数の表示更新
                            UIView.setAnimationsEnabled(false)
                            self.bookmarkViewButton.setAttributedTitle(bookmarkCountButtonText,
                                forState: UIControlState.Normal
                            )
                            self.bookmarkViewButton.layoutIfNeeded()
                            UIView.setAnimationsEnabled(true)
                        }
                    }
                }
            }
        )
        item.fetchHatenaBookmarkCountOf(item.url)
    }
    
    // MARK: - TTTAttributedLabel delegate
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        // performSegueWithIdentifier("PushItemWebView", sender: url)
        
        let safariViewController: SFSafariViewController = SFSafariViewController(URL: url)
        safariViewController.delegate = self
        presentViewController(safariViewController, animated: true, completion: nil)
    }
    
    // MARK: - SFSafariViewController delegate
    
    func safariViewController(controller: SFSafariViewController, activityItemsForURL URL: NSURL, title: String?) -> [UIActivity] {
        let hatenaBookmarkActivity: HTBHatenaBookmarkActivity = HTBHatenaBookmarkActivity()
        return [hatenaBookmarkActivity]
    }
    
    // MARK: - IBAction
    
    @IBAction func bookmarkCommentViewButtonTapped(sender: UIButton) {
        performSegueWithIdentifier("PresentBookmarkComment", sender: encodedUrl)
    }
    
    @IBAction func bookmarkButtonTapped(sender: UIBarButtonItem) {
        itemOperation.hatenaBookmarkOnViewController(self)
    }
    
    @IBAction func archiveButtonTapped(sender: UIBarButtonItem) {
        itemOperation.archiveOnViewController(self)
    }
    
    @IBAction func actionButtonTapped(sender: UIBarButtonItem) {
        itemOperation.showActionSheetOnViewController(self)
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushItemWebView" {
            let webViewController = segue.destinationViewController as! ItemWebViewController
            if let url = sender as? NSURL {
                webViewController.item = item
                webViewController.url = url
                webViewController.itemOperation = itemOperation
            }
        }
        if segue.identifier == "PresentBookmarkComment" {
            let viewController = segue.destinationViewController.childViewControllers.first as! BookmarkTableViewController
            if let url = sender as? String {
                viewController.url = url
            }
        }
    }

}

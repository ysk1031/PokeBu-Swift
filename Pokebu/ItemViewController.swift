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
//import SafariServices

class ItemViewController: UIViewController, TTTAttributedLabelDelegate {
    @IBOutlet weak var favicon: UIImageView!
    @IBOutlet weak var itemTitle: TTTAttributedLabel!
    @IBOutlet weak var excerpt: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var url: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var bookmarkViewButton: UIButton!
    
    @IBOutlet weak var excerptLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var photoWidth: NSLayoutConstraint!
    @IBOutlet weak var photoHeight: NSLayoutConstraint!
    @IBOutlet weak var photoLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var photoRightMargin: NSLayoutConstraint!
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

    override func viewDidLoad() {
        super.viewDidLoad()

        itemTitle.delegate = self
        setItemView()
        
        itemOperation = PocketItemOperation(item: item, itemIndex: index, encodedUrl: encodedUrl, apiAccess: apiAccess)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        // 写真がない時のAutoLayoutの値を変更
        if item.imgSrc == nil {
            photoWidth.constant = 0
            photoHeight.constant = 0
            photoRightMargin.constant = 0
        }
        
        // excerptラベルの高さ算出
        let excerptLabelHeight: CGFloat = heightForLabelText(excerpt.text!,
            font: excerpt.font,
            width: view.bounds.size.width - excerptLeftMargin.constant -
                (photoLeftMargin.constant + photoWidth.constant + photoRightMargin.constant)
        )
        
        // 写真があってexcerptラベルの高さが写真より低い時は、urlの表示位置を変更
        if item.imgSrc != nil && excerptLabelHeight < photo.frame.size.height {
            urlTopMargin.constant = 10 + photo.frame.size.height - excerptLabelHeight
        }
    }
    
    // MARK: - Application logic
    
    func setItemView() {
        // ファビコン
        let domain = NSURL(string: encodedUrl!)?.host
        favicon.sd_setImageWithURL(
            NSURL(string: "http://www.google.com/s2/favicons?domain=\(domain!)")
        )
        
        // 記事タイトル
        itemTitle.setText(item.title)
        itemTitle.linkAttributes = [
            kCTForegroundColorAttributeName : UIColor(red: 0.314, green: 0.737, blue: 0.714, alpha: 1.0),
            NSUnderlineStyleAttributeName : NSNumber(integer: NSUnderlineStyle.StyleNone.rawValue)
        ]
        itemTitle.activeLinkAttributes = [kCTForegroundColorAttributeName : UIColor(red: 0.929, green: 0.251, blue: 0.333, alpha: 1.0)]
        let titleRange: NSRange = (item.title as NSString).rangeOfString(item.title)
        itemTitle.addLinkToURL(NSURL(string: encodedUrl!), withRange: titleRange)
        
        // 抜粋
        excerpt.text = item.excerpt
        
        // 写真
        if let imageUrl = item.imgSrc {
            let encodedImageUrl: String? = imageUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            photo.sd_setImageWithURL(NSURL(string: encodedImageUrl!))
        }
        
        // URL
        url.text = item.url
        
        // 追加日
        let addedDate = NSDate(timeIntervalSince1970: Double(item.timestamp) as NSTimeInterval)
        date.text = "\(addedDate.timeAgoSinceNow())に追加"
        
        // ブックマーク閲覧ボタン
        bookmarkViewButton.setAttributedTitle(bookmarkCountButtonText(),
            forState: UIControlState.Normal
        )
        updateBookmarkCount()
    }
    
    func heightForLabelText(text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let label: UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.font = font
        label.text = text
        label.sizeToFit()
        
        return label.frame.height
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
        NSNotificationCenter.defaultCenter().addObserverForName(item.BookmarkCountFetchCompleteNotification,
            object: nil,
            queue: nil,
            usingBlock: { notification in
                NSNotificationCenter.defaultCenter().removeObserver(self.item.BookmarkCountFetchCompleteNotification)
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
        performSegueWithIdentifier("PushItemWebView", sender: url)
        
//        if #available(iOS 9.0, *) {
//            let safariViewController: SFSafariViewController = SFSafariViewController(URL: url)
//            presentViewController(safariViewController, animated: true, completion: nil)
//        } else {
            // Fallback on earlier versions
//        }
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

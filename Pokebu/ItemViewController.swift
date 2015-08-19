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

class ItemViewController: UIViewController, TTTAttributedLabelDelegate {
    @IBOutlet weak var favicon: UIImageView!
    @IBOutlet weak var itemTitle: TTTAttributedLabel!
    @IBOutlet weak var excerpt: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var url: UILabel!
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var excerptLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var excerptRightMargin: NSLayoutConstraint!
    @IBOutlet weak var photoWidth: NSLayoutConstraint!
    @IBOutlet weak var photoHeight: NSLayoutConstraint!
    @IBOutlet weak var urlTopMargin: NSLayoutConstraint!
    
    var encodedUrl: String?
    var item: PocketItem = PocketItem(id: 0, title: "", url: "", excerpt: nil, imgSrc: nil, timestamp: 0) {
        didSet {
            encodedUrl = item.url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        itemTitle.delegate = self
        setItemView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        itemTitle.linkAttributes = [NSUnderlineStyleAttributeName : NSNumber(integer: NSUnderlineStyle.StyleNone.rawValue)]
        itemTitle.activeLinkAttributes = [kCTForegroundColorAttributeName : UIColor(red: 0.929, green: 0.251, blue: 0.333, alpha: 1.0)]
        let titleRange: NSRange = (item.title as NSString).rangeOfString(item.title)
        itemTitle.addLinkToURL(NSURL(string: encodedUrl!), withRange: titleRange)
        
        // 抜粋
        excerpt.text = item.excerpt
        
        // 抜粋文ラベルの高さ算出
        let excerptLabelHeight: CGFloat
        if item.imgSrc == nil {
            excerptLabelHeight = heightForLabelText(excerpt.text!,
                font: excerpt.font,
                width: view.bounds.size.width - excerptLeftMargin.constant - excerptRightMargin.constant
            )
        } else {
            excerptLabelHeight = heightForLabelText(excerpt.text!,
                font: excerpt.font,
                width: view.bounds.size.width - excerptLeftMargin.constant - excerptRightMargin.constant
            )
        }
        
        // 写真
        if let imageUrl = item.imgSrc {
            let encodedImageUrl: String? = imageUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            photo.sd_setImageWithURL(NSURL(string: encodedImageUrl!))
        } else {
            excerptRightMargin.constant = 10
            photoWidth.constant = 0
            photoHeight.constant = 0
        }
        
        // URL
        if photoHeight.constant > 0 && excerptLabelHeight < photo.frame.size.height {
            urlTopMargin.constant = 10 + photo.frame.size.height - excerptLabelHeight
        }
        url.text = item.url
        
        // 追加日
        let addedDate = NSDate(timeIntervalSince1970: Double(item.timestamp) as NSTimeInterval)
        date.text = "\(addedDate.timeAgoSinceNow())に追加"
    }
    
    func heightForLabelText(text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let label: UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.font = font
        label.text = text
        label.sizeToFit()
        
        return label.frame.height
    }
    
    func presentShareActionSheet() {
        let hatenaBookmarkActivity: HTBHatenaBookmarkActivity = HTBHatenaBookmarkActivity()
        let activityController = UIActivityViewController(
            activityItems: [item.title, encodedUrl!],
            applicationActivities: [hatenaBookmarkActivity]
        )

        presentViewController(activityController, animated: true, completion: nil)
    }
    
    // MARK: - TTTAttributedLabel delegate
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        print(1)
    }
    
    // MARK: - IBAction
    
    @IBAction func bookmarkButtonTapped(sender: UIBarButtonItem) {
    }
    
    @IBAction func archiveButtonTapped(sender: UIBarButtonItem) {
    }
    
    @IBAction func actionButtonTapped(sender: UIBarButtonItem) {
        presentShareActionSheet()
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

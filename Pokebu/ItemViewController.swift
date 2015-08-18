//
//  ItemViewController.swift
//  Pokebu
//
//  Created by Yusuke Aono on 8/18/15.
//  Copyright © 2015 Yusuke Aono. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class ItemViewController: UIViewController, TTTAttributedLabelDelegate {
    @IBOutlet weak var itemTitle: TTTAttributedLabel!
    @IBOutlet weak var excerpt: UILabel!
    
    
    var item: PocketItem = PocketItem(id: 0, title: "", url: "", excerpt: nil, imgSrc: nil, timestamp: 0)

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
        // 記事タイトル
        itemTitle.setText(item.title)
        itemTitle.linkAttributes = [NSUnderlineStyleAttributeName : NSNumber(integer: NSUnderlineStyle.StyleNone.rawValue)]
        itemTitle.activeLinkAttributes = [kCTForegroundColorAttributeName : UIColor(red: 0.929, green: 0.251, blue: 0.333, alpha: 1.0)]
        let encodedUrl: String? = item.url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        let titleRange: NSRange = (item.title as NSString).rangeOfString(item.title)
        itemTitle.addLinkToURL(NSURL(string: encodedUrl!), withRange: titleRange)
        
        // 抜粋
        excerpt.text = item.excerpt
    }
    
    // MARK: - TTTAttributedLabel delegate
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        print(1)
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

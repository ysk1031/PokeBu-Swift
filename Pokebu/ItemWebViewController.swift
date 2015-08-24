//
//  ItemWebViewController.swift
//  Pokebu
//
//  Created by Yusuke Aono on 8/24/15.
//  Copyright © 2015 Yusuke Aono. All rights reserved.
//

import UIKit

class ItemWebViewController: UIViewController {
    @IBOutlet weak var webView: UIWebView!
    
    var item: PocketItem?
    var url: NSURL?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = item?.title
        
        let urlRequest: NSURLRequest = NSURLRequest(URL: url!)
        webView.loadRequest(urlRequest)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        NSURLCache.sharedURLCache().diskCapacity = 0
        NSURLCache.sharedURLCache().memoryCapacity = 0
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

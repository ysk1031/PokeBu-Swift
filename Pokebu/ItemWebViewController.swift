//
//  ItemWebViewController.swift
//  Pokebu
//
//  Created by Yusuke Aono on 8/24/15.
//  Copyright © 2015 Yusuke Aono. All rights reserved.
//

import UIKit
import NJKWebViewProgress

class ItemWebViewController: UIViewController, UIWebViewDelegate, NJKWebViewProgressDelegate {
    @IBOutlet weak var webView: UIWebView!
    
    var item: PocketItem?
    var url: NSURL?
    var progressView: NJKWebViewProgressView = NJKWebViewProgressView()
    var progressProxy: NJKWebViewProgress = NJKWebViewProgress()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = item?.title
        
        setNjkProgressView()
        
        let urlRequest: NSURLRequest = NSURLRequest(URL: url!)
        webView.loadRequest(urlRequest)
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBar.addSubview(progressView)
    }
    
    override func viewWillDisappear(animated: Bool) {
        progressView.removeFromSuperview()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        NSURLCache.sharedURLCache().diskCapacity = 0
        NSURLCache.sharedURLCache().memoryCapacity = 0
    }
    
    // MARK: - Application logic
    
    func setNjkProgressView() {
        webView.delegate = progressProxy
        progressProxy.webViewProxyDelegate = self
        progressProxy.progressDelegate = self
        
        let progressBarHeight: CGFloat = 2.0
        let navigationBarBounds: CGRect = (navigationController?.navigationBar.bounds)!
        let barFrame: CGRect = CGRectMake(
            0,
            navigationBarBounds.size.height - progressBarHeight,
            navigationBarBounds.size.width,
            progressBarHeight
        )
        progressView = NJKWebViewProgressView(frame: barFrame)
    }
    
    // MARK: - NJKWebViewProgress delegate
        
    func webViewProgress(webViewProgress: NJKWebViewProgress!, updateProgress progress: Float) {
        progressView.setProgress(progress, animated: true)
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

//
//  IntroViewController.swift
//  Pokebu
//
//  Created by Yusuke Aono on 8/30/15.
//  Copyright © 2015 Yusuke Aono. All rights reserved.
//

import UIKit
import PocketAPI
import SVWebViewController

class IntroViewController: UIViewController {
    @IBOutlet weak var appName: UILabel!
    @IBOutlet weak var appDescription: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    var window: UIWindow?
    var authStartObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDescription.text = "Pocketに保存した記事のリーダーです。\n\n" +
            "保存してある未読記事を消化・アーカイブしながら、" +
            "はてなブックマークのコメントを閲覧したり、ブックマーク追加したりできます。"
        let greenColor = UIColor(red: 0.306, green: 0.722, blue: 0.698, alpha: 1.0)
        appName.textColor = greenColor
        appDescription.textColor = greenColor
        loginButton.setTitleColor(greenColor, forState: UIControlState.Normal)
    }
    
    override func viewDidAppear(animated: Bool) {
        setAnimation()
        
        authStartObserver = NSNotificationCenter.defaultCenter().addObserverForName("PocketAuthStartNotification",
            object: nil,
            queue: nil,
            usingBlock: { notification in
                self.openPocketLoginScreenBy(notification)
            }
        )
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(authStartObserver!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Application logic
    
    func setAnimation() {
        let animation = CATransition()
        animation.type = kCATransitionFade
        animation.duration = 0.7
        
        let whiteColor = UIColor.whiteColor()
        appName.layer.addAnimation(animation, forKey: nil)
        appName.textColor = whiteColor
        appDescription.layer.addAnimation(animation, forKey: nil)
        appDescription.textColor = whiteColor
        loginButton.layer.addAnimation(animation, forKey: nil)
        loginButton.setTitleColor(whiteColor, forState: UIControlState.Normal)
    }
    
    func openPocketLoginScreenBy(notification: NSNotification) {
        let url: NSURL = notification.object as! NSURL
        let webViewController: SVWebViewController = SVWebViewController(address: url.absoluteString)
        
        let navigationController: UINavigationController = UINavigationController(rootViewController: webViewController)
        navigationController.navigationBar.barTintColor = UIColor(red:0.306, green:0.722, blue:0.698, alpha:1.0)
        navigationController.navigationBar.tintColor = UIColor.whiteColor()
        navigationController.navigationBar.translucent = false
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - IBAction
    
    @IBAction func loginButtonTapped(sender: UIButton) {
        // Pocketログイン
        PocketAPI.sharedAPI().loginWithHandler { (api, error) in
            if error != nil {
                let alertView = UIAlertController.setRequestFailureMessage(error.localizedDescription)
                self.presentViewController(alertView, animated: true, completion: nil)
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainNavigationController: UINavigationController = storyboard.instantiateInitialViewController() as! UINavigationController
                self.window!.rootViewController = mainNavigationController
            }
        }
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

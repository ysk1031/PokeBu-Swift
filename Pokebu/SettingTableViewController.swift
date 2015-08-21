//
//  SettingTableViewController.swift
//  Pokebu
//
//  Created by Yusuke Aono on 8/18/15.
//  Copyright © 2015 Yusuke Aono. All rights reserved.
//

import UIKit
import HatenaBookmarkSDK

class SettingTableViewController: UITableViewController {
    let sectionNumber: Int = 2
    let sectionNames: Array = ["サービス連携", "その他"]
    let menusInSection: [String: Array] = [
        "サービス連携": [
            "Pocket",
            "はてなブックマーク"
        ],
        "その他": [
            "このアプリについて"
        ]
    ]
    let hatenaOauthLoginNavigationController: UINavigationController = UINavigationController(
        navigationBarClass: HTBNavigationBar.self,
        toolbarClass: nil
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setStyleForHatenaOauthLoginNavigationBar()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Application logic
    
    func setStyleForHatenaOauthLoginNavigationBar() {
        hatenaOauthLoginNavigationController.navigationBar.translucent = false
        hatenaOauthLoginNavigationController.navigationBar.barTintColor = UIColor(
            red: 0.306,
            green: 0.722,
            blue: 0.698,
            alpha: 1.0
        )
        hatenaOauthLoginNavigationController.navigationBar.tintColor = UIColor.whiteColor()
        hatenaOauthLoginNavigationController.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
    }
    
    func authorizePocket() {
    }
    
    func authorizeHatenaBookmark() {
        if HTBHatenaBookmarkManager.sharedManager().authorized {
            performSegueWithIdentifier("PushHatenaConfig", sender: nil)
        } else {
            NSNotificationCenter.defaultCenter().addObserver(self,
                selector: "showHatenaOauthLoginView:",
                name: kHTBLoginStartNotification,
                object: nil
            )
            HTBHatenaBookmarkManager.sharedManager().authorizeWithSuccess(
                { self.hatenaOauthLoginNavigationController.dismissViewControllerAnimated(true, completion: nil) },
                failure: { error in return }
            )
        }
    }
    
    func showAppInformation() {
    }
    
    func showHatenaOauthLoginView(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kHTBLoginStartNotification, object: nil)
        let request: NSURLRequest = notification.object as! NSURLRequest
        let viewController: HTBLoginWebViewController = HTBLoginWebViewController(authorizationRequest: request)
        hatenaOauthLoginNavigationController.viewControllers = [viewController]
        presentViewController(hatenaOauthLoginNavigationController, animated: true, completion: nil)
    }
    
    // MARK: - Table view data delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section < sectionNumber {
            if let menus = menusInSection[sectionNames[indexPath.section]] {
                switch menus[indexPath.row] {
                case "Pocket":
                    authorizePocket()
                case "はてなブックマーク":
                    authorizeHatenaBookmark()
                case "このアプリについて":
                    showAppInformation()
                default:
                    break
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionNumber
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < sectionNumber {
            let sectionName = sectionNames[section]
            if let menus = menusInSection[sectionName] {
                return menus.count
            }
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < sectionNumber {
            return sectionNames[section]
        }
        return nil
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section < sectionNumber {
            let cell = tableView.dequeueReusableCellWithIdentifier("Setting", forIndexPath: indexPath)
            if indexPath.section < sectionNumber {
                let sectionName = sectionNames[indexPath.section]
                if let menus = menusInSection[sectionName] {
                    cell.textLabel?.text = menus[indexPath.row]
                    cell.textLabel?.font = UIFont.systemFontOfSize(16.0)
                }
            }
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - IBAction
    
    @IBAction func closeButtonTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

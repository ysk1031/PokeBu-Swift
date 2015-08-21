//
//  HatenaConfigTableViewController.swift
//  Pokebu
//
//  Created by Yusuke Aono on 8/21/15.
//  Copyright © 2015 Yusuke Aono. All rights reserved.
//

import UIKit
import HatenaBookmarkSDK

class HatenaConfigTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let alert = UIAlertController(
            title: "確認",
            message: "はてなブックマークアカウントの連携を解除してもよろしいですか？",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        let okAction = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.Default,
            handler: { action in
                HTBHatenaBookmarkManager.sharedManager().logout()
                self.navigationController?.popViewControllerAnimated(true)
            }
        )
        let cancelAction = UIAlertAction(
            title: "キャンセル",
            style: UIAlertActionStyle.Default,
            handler: { action in return }
        )
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HatenaAccount", forIndexPath: indexPath)
        cell.textLabel?.text = "連携を解除"
        cell.detailTextLabel?.text = HTBHatenaBookmarkManager.sharedManager().username

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "はてなブックマークアカウント"
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

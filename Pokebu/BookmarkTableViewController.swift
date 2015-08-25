//
//  BookmarkTableViewController.swift
//  Pokebu
//
//  Created by Yusuke Aono on 8/25/15.
//  Copyright © 2015 Yusuke Aono. All rights reserved.
//

import UIKit

class BookmarkTableViewController: UITableViewController {
    var url: String?
    var apiAccess: HatenaApiAccess = HatenaApiAccess()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserverForName(apiAccess.HAAFetchCompleteNotification,
            object: nil,
            queue: nil, usingBlock: { (notification: NSNotification) in
                self.tableView.reloadData()
                
                if notification.userInfo != nil {
                    if let userInfo = notification.userInfo as? [String: String] {
                        if let errorMessage = userInfo["error"] {
                            let alertView = UIAlertController.setRequestFailureMessage(errorMessage)
                            self.presentViewController(alertView, animated: true, completion: nil)
                        }
                    }
                }
            }
        )
        
        apiAccess.fetchBookmarkDataOf(url!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return apiAccess.bookmarks.count
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("Bookmark", forIndexPath: indexPath) as! BookmarkTableViewCell
            cell.bookmark = apiAccess.bookmarks[indexPath.row]
            
            return cell
        }
        return UITableViewCell()
    }
    
    @IBAction func closeButtonTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
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

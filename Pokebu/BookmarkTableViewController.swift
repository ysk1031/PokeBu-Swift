//
//  BookmarkTableViewController.swift
//  Pokebu
//
//  Created by Yusuke Aono on 8/25/15.
//  Copyright © 2015 Yusuke Aono. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class BookmarkTableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    let baseCellHeight: CGFloat = 68.0
    let fetchingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    var url: String?
    var apiAccess: HatenaApiAccess = HatenaApiAccess()
    var emptyDataTitle: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        showIndicator()
        tableView.allowsSelection = false
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
                
        NSNotificationCenter.defaultCenter().addObserverForName(apiAccess.HAAFetchCompleteNotification,
            object: nil,
            queue: nil, usingBlock: { (notification: NSNotification) in
                self.hideIndicator()
                self.setEmptyDataDescriptionOnBookmarkCount(self.apiAccess.bookmarks.count)
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
    
    // MARK: - Application logic
    
    func showIndicator() {
        fetchingIndicator.frame = CGRectMake(0, 0, view.frame.size.width / 2, view.frame.size.height / 2)
        tableView.tableFooterView = fetchingIndicator
        fetchingIndicator.startAnimating()
    }
    
    func hideIndicator() {
        fetchingIndicator.stopAnimating()
    }
    
    func setEmptyDataDescriptionOnBookmarkCount(count: Int = 1) {
        if count < 1 {
            emptyDataTitle = "公開されているブックマークデータはありません。"
        } else {
            emptyDataTitle = ""
        }
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let bookmark = apiAccess.bookmarks[indexPath.row]
            if bookmark.comment != nil {
                // AutoLayoutの数値系を直書きしてるのでイマイチ
                let commentWidth: CGFloat = tableView.bounds.size.width - (10 + 48 + 6 + 10)
                let commentHeight: CGFloat = UILabel.heightForLabelText(bookmark.comment!,
                    font: UIFont.systemFontOfSize(14.0),
                    width: commentWidth
                )
                if commentHeight + 3 + 14 > 48 {
                    return baseCellHeight + (commentHeight + 3 + 14 - 48)
                }
            }
        }
        return baseCellHeight
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return baseCellHeight
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
    
    // MARK: - DZNEmptyDataSet delegate
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let textAttributes: Dictionary = [
            NSFontAttributeName: UIFont.boldSystemFontOfSize(18.0),
            NSForegroundColorAttributeName: UIColor.grayColor()
        ]
        return NSAttributedString(string: emptyDataTitle, attributes: textAttributes)
    }
    
    // MARK: - IBAction
    
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

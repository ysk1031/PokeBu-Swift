//
//  ItemListTableViewController.swift
//  Pokebu
//
//  Created by Yusuke Aono on 8/14/15.
//  Copyright © 2015 Yusuke Aono. All rights reserved.
//

import UIKit

class ItemListTableViewController: UITableViewController {
    let cellHeight: CGFloat = 75.0
    let fetchingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    var apiAccess = PocketApiAccess()
    var fetchItemListObserver: NSObjectProtocol?
    var refreshItemListObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshList:", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        tableView.alwaysBounceVertical = true
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        fetchItemListObserver = NSNotificationCenter.defaultCenter().addObserverForName(apiAccess.PAAFetchCompleteNotification,
            object: nil,
            queue: nil,
            usingBlock: { notification in
                self.hideIndicator()
                self.tableView.reloadData()
                
                // 通信エラー時の処理
                if notification.userInfo != nil {
                    if let userInfo = notification.userInfo as? [String: String] {
                        if let errorMessage = userInfo["error"] {
                            let alertView = UIAlertController(
                                title: "エラー",
                                message: errorMessage,
                                preferredStyle: .Alert
                            )
                            let alertAction = UIAlertAction(
                                title: "OK",
                                style: .Default,
                                handler: { action in
                                    return
                                }
                            )
                            alertView.addAction(alertAction)
                            self.presentViewController(alertView, animated: true, completion: nil)
                        }
                    }
                }
            }
        )
        
        displayIndicator()
        apiAccess.fetchData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Application logic
    
    func displayIndicator() {
        fetchingIndicator.frame = CGRectMake(0, 0, view.frame.size.width / 2, view.frame.size.height / 8)
        tableView.tableFooterView = fetchingIndicator
        fetchingIndicator.startAnimating()
    }
    
    func hideIndicator() {
        fetchingIndicator.stopAnimating()
    }
    
    func refreshList(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        
        refreshItemListObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            apiAccess.PAAFetchCompleteNotification,
            object: nil,
            queue: nil,
            usingBlock: { notification in
                NSNotificationCenter.defaultCenter().removeObserver(self.refreshItemListObserver!)
                refreshControl.endRefreshing()
                
                if notification.userInfo != nil {
                    if let userInfo = notification.userInfo as? [String: Int] {
                        if let newFetchedItemCount = userInfo["newFetchedCount"] {
                            if newFetchedItemCount > 0 {
                                // P2R後にviewが一番上に行ってしまうので、新しく追加されたセル数 x セルの高さ分 viewの位置を下げる
                                self.tableView.bounds.origin.y = self.cellHeight * CGFloat(newFetchedItemCount) - self.tableView.contentInset.top
                            }
                        }
                    }
                }
            }
        )
        
        apiAccess.fetchData(refresh: true)
    }
    
    // MARK: - Table view data delegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeight
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("PushItem", sender: indexPath)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return apiAccess.totalItemCount
        }
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row < apiAccess.totalItemCount {
                let cell = tableView.dequeueReusableCellWithIdentifier("Item", forIndexPath: indexPath) as! ItemListTableViewCell
                cell.item = apiAccess.items[indexPath.row]
                
                // 全てのアイテムを取得してない && 現在表示できる一番下のセルまで到達した時
                if !apiAccess.fetchingFullList && apiAccess.totalItemCount - indexPath.row <= 1 {
                    displayIndicator()
                    apiAccess.fetchData()
                }
                
                return cell
            }
        }
        return UITableViewCell()
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "PushItem" {
            let viewController = segue.destinationViewController as! ItemViewController
            if let indexPath = sender as? NSIndexPath {
                viewController.item = apiAccess.items[indexPath.row]
            }
        }
    }

}

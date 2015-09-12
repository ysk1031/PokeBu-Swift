//
//  ItemListTableViewController.swift
//  Pokebu
//
//  Created by Yusuke Aono on 8/14/15.
//  Copyright © 2015 Yusuke Aono. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import SWTableViewCell

class ItemListTableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, SWTableViewCellDelegate {
    let cellHeight: CGFloat = 75.0
    let fetchingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    var apiAccess = PocketApiAccess()
    var refreshItemListObserver: NSObjectProtocol?
    var emptyDataTitle: String = ""
    var emptyDataButtonTitle: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FIX: ステータスバーの文字を白に
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        
        addNotificationObservers()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshList:", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        tableView.alwaysBounceVertical = true
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        displayIndicator()
        apiAccess.fetchData()
        
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
    
    func addNotificationObservers() {
        // PAAFetchCompleteNotification
        NSNotificationCenter.defaultCenter().addObserverForName(apiAccess.PAAFetchCompleteNotification,
            object: nil,
            queue: nil,
            usingBlock: { notification in
                self.hideIndicator()
                self.setEmptyDataDescriptionOnItemCount(self.apiAccess.items.count)
                self.tableView.reloadData()
                
                // 通信エラー時の処理
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
        
        // PAAArchiveStartNotification
        NSNotificationCenter.defaultCenter().addObserverForName(apiAccess.PAAArchiveStartNotification,
            object: nil,
            queue: nil,
            usingBlock: { notification in
                if notification.userInfo != nil {
                    if let userInfo = notification.userInfo as? [String: Int] {
                        if let archivedItemIndex = userInfo["archivedItemIndex"] {
                            self.tableView.beginUpdates()
                            
                            // 0.5秒遅延
                            let delay = 0.5 * Double(NSEC_PER_SEC)
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay)), dispatch_get_main_queue(), {
                                // データからitem削除
                                self.apiAccess.items.removeAtIndex(archivedItemIndex)
                                self.apiAccess.totalItemCount -= 1
                                
                                // tableViewからセル削除
                                let deletedIndexPath: NSIndexPath = NSIndexPath(forRow: archivedItemIndex, inSection: 0)
                                self.tableView.deleteRowsAtIndexPaths([deletedIndexPath], withRowAnimation: .Left)
                                
                                self.setEmptyDataDescriptionOnItemCount(self.apiAccess.items.count)
                            })
                            
                            self.tableView.endUpdates()
                        }
                    }
                }
            }
        )
        
        // PAAArchiveCompleteNotification
        NSNotificationCenter.defaultCenter().addObserverForName(apiAccess.PAAArchiveCompletionNotification,
            object: nil,
            queue: nil,
            usingBlock: { notification in
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
    }
    
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
    
    func cellRightButtons() -> NSArray {
        let buttons: NSMutableArray = []
        buttons.sw_addUtilityButtonWithColor(UIColor.themeColorRed(), title: "Archive")
        return buttons
    }
    
    func setEmptyDataDescriptionOnItemCount(count: Int = 1) {
        if count < 1 {
            emptyDataTitle = "保存している記事はありません。"
            emptyDataButtonTitle = "再度読み込む"
        } else {
            emptyDataTitle = ""
            emptyDataButtonTitle = ""
        }
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
                
                // Setting for SWTableViewCell
                cell.rightUtilityButtons = cellRightButtons() as [AnyObject]
                cell.delegate = self
                
                return cell
            }
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
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let textAttributes: Dictionary = [
            NSFontAttributeName: UIFont.boldSystemFontOfSize(14.0),
            NSForegroundColorAttributeName: UIColor.darkGrayColor()
        ]
        return NSAttributedString(string: emptyDataButtonTitle, attributes: textAttributes)
    }

    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        // セルが空の時の表示をリセット
        setEmptyDataDescriptionOnItemCount()
        tableView.reloadData()
        
        // 再読み込み
        displayIndicator()
        apiAccess.fetchData()
    }
    
    // MARK: - SWTableViewCell delegate
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        switch index {
        case 0:
            let index: Int = (tableView.indexPathForCell(cell)?.row)!
            let itemId: Int = apiAccess.items[index].id
            apiAccess.archiveItemAtIndex(index, itemId: itemId)
        default:
            break
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "PushItem" {
            let viewController = segue.destinationViewController as! ItemViewController
            if let indexPath = sender as? NSIndexPath {
                // FIX: パラメータ渡し過ぎな気も
                viewController.item = apiAccess.items[indexPath.row]
                viewController.index = indexPath.row
                viewController.apiAccess = apiAccess
            }
        }
    }

}

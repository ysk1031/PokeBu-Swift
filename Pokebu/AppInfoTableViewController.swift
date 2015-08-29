//
//  AppInfoTableViewController.swift
//  Pokebu
//
//  Created by Yusuke Aono on 8/29/15.
//  Copyright © 2015 Yusuke Aono. All rights reserved.
//

import UIKit

class AppInfoTableViewController: UITableViewController {
    let sectionNumber: Int = 3
    let sectionNames: Array = ["", "情報", "フィードバック"]
    let menusInSection: [String: Array] = [
        "": [
            "バージョン"
        ],
        "情報": [
            "About",
            "LICENSE",
            "開発者ブログ"
        ],
        "フィードバック": [
            "App Store",
            "GitHub"
        ]
    ]
    let cellAccessoryTypes: [UITableViewCellAccessoryType] = [
        UITableViewCellAccessoryType.None,
        UITableViewCellAccessoryType.DisclosureIndicator,
        UITableViewCellAccessoryType.DisclosureIndicator
    ]

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

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section < sectionNumber {
            let cell = tableView.dequeueReusableCellWithIdentifier("AppInfo", forIndexPath: indexPath)
            cell.accessoryType = cellAccessoryTypes[indexPath.section]
            
            let sectionName = sectionNames[indexPath.section]
            if let menus = menusInSection[sectionName] {
                cell.textLabel?.text = menus[indexPath.row]
                if menus[indexPath.row] == "バージョン" {
                    cell.detailTextLabel?.text = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String
                }
            }

            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < sectionNumber {
            return sectionNames[section]
        }
        return nil
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

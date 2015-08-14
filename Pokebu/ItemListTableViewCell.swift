//
//  ItemListTableViewCell.swift
//  Pokebu
//
//  Created by Yusuke Aono on 8/14/15.
//  Copyright © 2015 Yusuke Aono. All rights reserved.
//

import UIKit

class ItemListTableViewCell: UITableViewCell {
    @IBOutlet weak var favicon: UIImageView!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var urlHost: UILabel!
    
    var item: PocketItem? {
        didSet {
            if item == nil { return }
            itemTitle.text = item!.title
            
            let nsURL = NSURL(string: item!.url)
            urlHost.text = nsURL?.host
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

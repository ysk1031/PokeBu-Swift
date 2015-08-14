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
    @IBOutlet weak var urlDomain: UILabel!
    
    var item: PocketItem?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if item != nil {
            itemTitle.text = item?.title
        }
    }

}

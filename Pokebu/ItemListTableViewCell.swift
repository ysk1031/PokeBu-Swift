//
//  ItemListTableViewCell.swift
//  Pokebu
//
//  Created by Yusuke Aono on 8/13/15.
//  Copyright © 2015 Yusuke Aono. All rights reserved.
//

import UIKit

class ItemListTableViewCell: UITableViewCell {
    @IBOutlet weak var favicon: UIImageView!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var urlDomain: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

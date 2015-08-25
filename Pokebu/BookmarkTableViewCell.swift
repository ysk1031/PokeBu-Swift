//
//  BookmarkTableViewCell.swift
//  Pokebu
//
//  Created by Yusuke Aono on 8/25/15.
//  Copyright © 2015 Yusuke Aono. All rights reserved.
//

import UIKit

class BookmarkTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    
    var bookmark: HatenaBookmark? {
        didSet {
            if bookmark == nil { return }
            
            name.text = bookmark?.userName
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

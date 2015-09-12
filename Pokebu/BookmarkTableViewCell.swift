//
//  BookmarkTableViewCell.swift
//  Pokebu
//
//  Created by Yusuke Aono on 8/25/15.
//  Copyright © 2015 Yusuke Aono. All rights reserved.
//

import UIKit

class BookmarkTableViewCell: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var addedTime: UILabel!
    @IBOutlet weak var comment: UILabel!
    
    var bookmark: HatenaBookmark? {
        didSet {
            if bookmark == nil { return }
            
            icon.sd_setImageWithURL(NSURL(string: (bookmark?.userImage)!))
            icon.layer.cornerRadius = 24.0
            icon.layer.borderColor = UIColor.lightGrayColor().CGColor
            icon.layer.borderWidth = 0.5
            userName.text = bookmark?.userName
            addedTime.text = bookmark?.addedTime?.timeAgoSinceNow()
            comment.text = bookmark?.comment
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

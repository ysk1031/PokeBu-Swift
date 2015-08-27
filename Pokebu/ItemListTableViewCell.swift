//
//  ItemListTableViewCell.swift
//  Pokebu
//
//  Created by Yusuke Aono on 8/14/15.
//  Copyright © 2015 Yusuke Aono. All rights reserved.
//

import UIKit
import SDWebImage
import SWTableViewCell

class ItemListTableViewCell: SWTableViewCell {
    @IBOutlet weak var favicon: UIImageView!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var urlHost: UILabel!
    
    var item: PocketItem? {
        didSet {
            if item == nil { return }
            
            itemTitle.text = item!.title
            
            let encodedUrl: String? = item!.url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            let domain = NSURL(string: encodedUrl!)?.host
            urlHost.text = domain
            
            favicon.sd_setImageWithURL(
                NSURL(string: "http://www.google.com/s2/favicons?domain=\(domain!)")
            )
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

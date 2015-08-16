//
//  PocketItem.swift
//  Pokebu
//
//  Created by Yusuke Aono on 8/13/15.
//  Copyright © 2015 Yusuke Aono. All rights reserved.
//

import Foundation

class PocketItem {
    let id: Int
    let title: String
    let url: String
    let excerpt: String
    let imgSrc: String?
    let timestamp: Int
    
    init(id: Int, title: String, url: String, excerpt: String, imgSrc: String?, timestamp: Int) {
        self.id = id
        self.title = title
        self.url = url
        self.excerpt = excerpt
        self.imgSrc = imgSrc
        self.timestamp = timestamp
    }
}
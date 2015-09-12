//
//  AppAboutViewController.swift
//  Pokebu
//
//  Created by Yusuke Aono on 8/29/15.
//  Copyright © 2015 Yusuke Aono. All rights reserved.
//

import UIKit

class AppAboutViewController: UIViewController {
    @IBOutlet weak var appDescription: UILabel!
    @IBOutlet weak var developer: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDescription.text = "Pocketに保存した記事のリーダーアプリです。" +
            "未読記事を消化・アーカイブしながら、はてなブックマークのコメントを閲覧したり、ブックマーク追加したりできます。\n\n" +
            "自分がよくやっている「Twitterで流れる情報をいったんPocketに保存 => 読了後、" +
            "はてブ追加・記事のアーカイブ」という作業の流れを、モバイル端末でもスムーズに行いたいと思って作りました。\n\n" +
            "元々はRubyMotion製のアプリでしたが、バージョン1.1からSwiftで書き直しています。\n\n" +
            "(c) 2015 Yusuke Aono"
        developer.text = "Twitter: @ysk_aono\n" +
            "GitHub: ysk1031"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

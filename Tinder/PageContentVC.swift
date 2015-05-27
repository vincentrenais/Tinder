//
//  PageContentVC.swift
//  Tinder
//
//  Created by Vincent Renais on 2015-05-26.
//  Copyright (c) 2015 Vincent Renais. All rights reserved.
//


import UIKit

class PageContentVC: UIViewController {

    @IBOutlet weak var bkImageView: UIImageView!
    @IBOutlet weak var heading: UILabel!
    
    var pageIndex: Int?
    var titleText : String!
    var imageName : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.bkImageView.image = UIImage(named: imageName)
        self.heading.text = self.titleText
        self.heading.alpha = 0.1
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.heading.alpha = 1.0
        })
        
    }

}

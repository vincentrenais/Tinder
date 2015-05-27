//
//  FindViewController.swift
//  Tinder
//
//  Created by Vincent Renais on 2015-05-27.
//  Copyright (c) 2015 Vincent Renais. All rights reserved.
//

import UIKit

class FindViewController: UIViewController {
    
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var query = PFUser.query()

        query!.findObjectsInBackgroundWithBlock {
            (users: [AnyObject]?, error: NSError?) -> Void in
            if let error = error {
                println(error.description)
            }
            else
            {
                for user in users!
                {
                    if user as? NSObject == PFUser.currentUser()
                    {
                        continue
                    }
                    else
                    {
                        let name = user["name"] as? String
                        self.userName.text = name!
                        let email = user["email"] as? String
                        self.userEmail.text = email!
                        let photo = user["photo"] as? String
                        let url = NSURL(string: photo!)
                        let imageData = NSData(contentsOfURL: url!)
                        self.userPhoto.image = UIImage(data: imageData!)
                    }
                }
            }
        }
    }
}

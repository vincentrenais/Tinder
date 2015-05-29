//
//  FindMatchesVC.swift
//  Tinder
//
//  Created by Vincent Renais on 2015-05-27.
//  Copyright (c) 2015 Vincent Renais. All rights reserved.
//

import UIKit

class FindMatchesVC: UIViewController {
    
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    
    @IBOutlet weak var nopeButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var goBackButton: UIButton!
    
    var listOfMatches = []
    var currentMatch = 0
    var listOfRequests = []
    var currentLocation: PFGeoPoint?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let user = PFUser.currentUser()
        {
           PFGeoPoint.geoPointForCurrentLocationInBackground
            {
                (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
                
                if (error != nil)
                {
                    // do something with the new geoPoint
                }
                
                self.currentLocation = geoPoint
                
                if let point = self.currentLocation
                {
                    user["currentLocation"] = geoPoint
                    user.saveInBackground()
                    self.iterateThroughListOfMatches(self.currentMatch, aroundGeoPoint: point)
                }
            }
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.nopeButton.setImage(UIImage(named: "nope.png") as UIImage!, forState: nil)
        self.okButton.setImage(UIImage(named: "ok.png") as UIImage!, forState: nil)
        self.goBackButton.setImage(UIImage(named: "goBack.png") as UIImage!, forState: nil)
        self.goBackButton.alpha = 0
    }

    
    func iterateThroughListOfMatches(i: Int, aroundGeoPoint:PFGeoPoint)
    {
        var kQuery = PFQuery(className: "_User")
        kQuery.whereKey("currentLocation", nearGeoPoint: aroundGeoPoint, withinKilometers: 10)
        kQuery.findObjectsInBackgroundWithBlock {
            (users: [AnyObject]?, error: NSError?) -> Void in
            if let error = error {
                println(error.description)
            }
            else
            {
                self.listOfMatches = users!
                let closestUser: AnyObject = self.listOfMatches[i]
                let name = closestUser["name"] as? String
                self.userName.text = name!
                let email = closestUser["email"] as? String
                self.userEmail.text = email!
                let photo = closestUser["photo"] as? String
                let url = NSURL(string: photo!)
                let imageData = NSData(contentsOfURL: url!)
                self.userPhoto.image = UIImage(data: imageData!)
                self.userPhoto.layer.cornerRadius = 8
                self.userPhoto.clipsToBounds = true
                self.currentMatch = i
            }
        }
    }

    @IBAction func nopeButtonPressed(sender: UIButton) {
        println("nope")
        self.iterateThroughListOfMatches(self.currentMatch + 1, aroundGeoPoint: self.currentLocation!)
        self.goBackButton.alpha = 1
    }
    
    @IBAction func okButtonPressed(sender: UIButton) {
        println("ok")
        
    }
    
    @IBAction func goBackButtonPressed(sender: UIButton) {
        self.iterateThroughListOfMatches(self.currentMatch - 1, aroundGeoPoint: self.currentLocation!)
        self.goBackButton.alpha = 0
    }

}

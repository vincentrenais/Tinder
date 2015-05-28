//
//  FindMatchesVC.swift
//  Tinder
//
//  Created by Vincent Renais on 2015-05-27.
//  Copyright (c) 2015 Vincent Renais. All rights reserved.
//

import UIKit

class FindMatchesVC: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    
    @IBOutlet weak var nopeButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var goBackButton: UIButton!
    
    var listOfMatch = []
    var currentMatch = 0
    var listOfRequest = []
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.iterateThroughListOfMatches(currentMatch)
        
        self.locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations[0] as! CLLocation
        println("Latitude: \(location.coordinate.latitude). Longitude: \(location.coordinate.longitude).")
    }
    
    
    func iterateThroughListOfMatches(i: Int)
    {
        var query = PFUser.query()
        
        query!.findObjectsInBackgroundWithBlock {
            (users: [AnyObject]?, error: NSError?) -> Void in
            if let error = error {
                println(error.description)
            }
            else
            {
                self.listOfMatch = users!
                let closestUser: AnyObject = self.listOfMatch[i]
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
        self.iterateThroughListOfMatches(self.currentMatch + 1)
        self.goBackButton.alpha = 1
    }
    
    @IBAction func okButtonPressed(sender: UIButton) {
        println("ok")
        
    }
    
    @IBAction func goBackButtonPressed(sender: UIButton) {
        self.iterateThroughListOfMatches(self.currentMatch - 1)
        self.goBackButton.alpha = 0
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        self.nopeButton.setImage(UIImage(named: "nope.png") as UIImage!, forState: nil)
        self.okButton.setImage(UIImage(named: "ok.png") as UIImage!, forState: nil)
        self.goBackButton.setImage(UIImage(named: "goBack.png") as UIImage!, forState: nil)
        self.goBackButton.alpha = 0
    }
    
}

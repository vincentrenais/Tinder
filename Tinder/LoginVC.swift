//
//  LoginVC.swift
//  Tinder
//
//  Created by Vincent Renais on 2015-05-25.
//  Copyright (c) 2015 Vincent Renais. All rights reserved.
//

import UIKit

class LoginVC: UIViewController, FBSDKLoginButtonDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var facebookLoginButton: FBSDKLoginButton!
    var locationManager = CLLocationManager()
    var userLatitude = 0.0
    var userLongitude = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        facebookLoginButton.delegate = self
        
        facebookLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        
        self.locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

    }
    
    
    override func viewDidAppear(animated: Bool) {
    
        if let user = PFUser.currentUser()
        {
            self.performSegueWithIdentifier("loginSegue", sender: self)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!)
    {
        let location = locations[0] as! CLLocation
        
        self.userLatitude = location.coordinate.latitude
        self.userLongitude = location.coordinate.longitude
    }
    
    // FACEBOOK DELEGATE METHOD
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
    {
        println("User Logged In")
                
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled
        {
            // Handle cancellations
        }
        else
        {
            PFFacebookUtils.logInInBackgroundWithAccessToken(result.token, block: { (user: PFUser?, error: NSError?) -> Void in
                if let parseUser = user
                {
                    println("User logged in through Facebook!");
                    
                    let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "/me?fields=email,name,picture.width(300).height(300)", parameters: nil)
                    graphRequest.startWithCompletionHandler({ (connection :FBSDKGraphRequestConnection!, result: AnyObject!, error :NSError!) -> Void in
                        println("lol")
                        if error != nil {
                            
                        } else {
                            println("\(result)")
                            if let name = result["name"] as? String{
                                parseUser["name"] = name
                            }
                            
                            if let email = result["email"] as? String{
                                parseUser["email"] = email
                            }
                            
                            if let pictureResult = result["picture"] as? NSDictionary,
                                pictureData = pictureResult["data"] as? NSDictionary,
                                picture = pictureData["url"] as? String {
                                       parseUser["photo"] = picture
                                 }
                            
                            parseUser["latitude"] = self.userLatitude
                            parseUser["longitude"] = self.userLongitude
                            
                            parseUser.saveInBackground()
                            
                            self.performSegueWithIdentifier("loginSegue", sender: self)
                        }
                    })
                } else
                {
                    println("Uh oh. There was an error logging in.")
                }
            })
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("User Logged Out")
    }

}
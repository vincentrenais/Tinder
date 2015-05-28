//
//  LoginVC.swift
//  Tinder
//
//  Created by Vincent Renais on 2015-05-25.
//  Copyright (c) 2015 Vincent Renais. All rights reserved.
//

import UIKit

class LoginVC: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet var facebookLoginButton: FBSDKLoginButton!
    
    let pageTitles = ["", "", "", ""]
    
    var images = ["long3.png","long4.png","long1.png","long2.png"]
    
    var count = 0
    
    var pageViewController : UIPageViewController!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        facebookLoginButton.delegate = self
        
        facebookLoginButton.readPermissions = ["public_profile", "email", "user_friends"]

    }
//    override func viewDidAppear(animated: Bool) {
//    
//        if let user = PFUser.currentUser()
//        {
//            self.performSegueWithIdentifier("loginSegue", sender: self)
//        }
//    }
    
    // Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
    {
        println("User Logged In")
        
//        self.performSegueWithIdentifier("loginSegue", sender: self)
        
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
//
//  ViewController.swift
//  Tinder
//
//  Created by Vincent Renais on 2015-05-25.
//  Copyright (c) 2015 Vincent Renais. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet var FacebookLoginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        FacebookLoginButton.delegate = self
        
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
        }
    }
    
    // Facebook Delegate Methods
    
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
                    
                    let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "/me?fields=email,name,picture", parameters: nil)
                    graphRequest.startWithCompletionHandler(
                        {
                            (connection, result, error) -> Void in
                        
                                if (error != nil)
                                {
                                    // Process error
                                    println("Error: \(error)")
                                } else
                                {
                                    parseUser["name"] = result["name"]
                                    parseUser["email"] = result["email"]
                                    if let pictureResult = result["picture"] as? NSDictionary
                                    {
                                        if let pictureData = pictureResult["data"] as? NSDictionary
                                        {
                                            if let picture = pictureData["url"] as? String
                                            {
                                                parseUser["photo"] = picture
                                            }
                                        }
                                    }
                                    parseUser.saveInBackground()
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
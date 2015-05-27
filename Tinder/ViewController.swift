//
//  ViewController.swift
//  Tinder
//
//  Created by Vincent Renais on 2015-05-25.
//  Copyright (c) 2015 Vincent Renais. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
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
        
        reset()
    }
    

    
    override func viewDidAppear(animated: Bool) {
    
        if let user = PFUser.currentUser()
        {
            self.performSegueWithIdentifier("loginSegue", sender: self)
        }
    }
    
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
                    
                    let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "/me?fields=email,name,picture", parameters: nil)
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
    
    @IBAction func swipeLeft(sender: AnyObject) {
        println("Swipe left")
    }
    @IBAction func swiped(sender: AnyObject) {
        
        self.pageViewController.view.removeFromSuperview()
        self.pageViewController.removeFromParentViewController()
        reset()
    }
    
    
    func reset() {
        /* Getting the page View controller */
        pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        
        let pageContentViewController = self.viewControllerAtIndex(0)
        self.pageViewController.setViewControllers([pageContentViewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        
        /* We are substracting 30 because we have a start again button whose height is 30*/
        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - 30)
        self.addChildViewController(pageViewController)
        self.view.addSubview(pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
    }
    
    @IBAction func start(sender: AnyObject) {
        let pageContentViewController = self.viewControllerAtIndex(0)
        self.pageViewController.setViewControllers([pageContentViewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! PageContentVC).pageIndex!
        index++
        if(index == self.images.count){
            return nil
        }
        return self.viewControllerAtIndex(index)
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! PageContentVC).pageIndex!
        if(index == 0){
            return nil
        }
        index--
        return self.viewControllerAtIndex(index)
        
    }
    
    func viewControllerAtIndex(index : Int) -> UIViewController? {
        if((self.pageTitles.count == 0) || (index >= self.pageTitles.count)) {
            return nil
        }
        let pageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageContentViewController") as! PageContentVC
        
        pageContentViewController.imageName = self.images[index]
        pageContentViewController.titleText = self.pageTitles[index]
        pageContentViewController.pageIndex = index
        return pageContentViewController
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }

}
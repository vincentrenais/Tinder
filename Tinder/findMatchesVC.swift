//
//  FindMatchesVC.swift
//  Tinder
//
//  Created by Vincent Renais on 2015-05-27.
//  Copyright (c) 2015 Vincent Renais. All rights reserved.
//

import UIKit

class FindMatchesVC: UIViewController {
    
    
    enum PictureSelectionState{
        case NoSelection
        case MakingSelection
        case SwipingLeft
        case SwipedLeft
        case SwipingRight
        case SwipedRight
    }
    
    var xFromCenter:CGFloat = 0
    
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    
    @IBOutlet weak var nopeButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var goBackButton: UIButton!
    
    var listOfMatches = []
    var currentMatchIndex = 1
    var currentMatch: String?
    var listOfRequests = []
    var currentLocation: PFGeoPoint?
    var frame:CGRect!
    
    
    var pictureSelectionState: PictureSelectionState = .NoSelection
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        frame = CGRectZero
        
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
                    self.iterateThroughListOfMatches(self.currentMatchIndex, aroundGeoPoint: point)
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
    
    @IBAction func profileWasDragged(sender: UIPanGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            frame = sender.view?.frame
        }
        let translation = sender.translationInView(self.view)
        // get was has been dragged
        var profile = sender.view!
        xFromCenter += translation.x
        var scale = min( 100 / abs(xFromCenter), 1)
        profile.center = CGPoint(x: profile.center.x + translation.x, y: profile.center.y)
        // reset translation
        sender.setTranslation(CGPointZero, inView: self.view)
        //rotate label
        var rotation:CGAffineTransform = CGAffineTransformMakeRotation(translation.x / 200)
        // stretch the current view
        var stretch:CGAffineTransform = CGAffineTransformScale(rotation, scale, scale)
        // check if chosen or not chosen
        if profile.center.x <  100 {
            //println("not chose")
            pictureSelectionState = .SwipingLeft
            // do nothing
            if profile.center.x <  20 {
                pictureSelectionState = .SwipedLeft
            }
        } else {
            //println("chosen")
            pictureSelectionState = .SwipingRight
            // Add to chosen list on parse
            if profile.center.x > 300 {
                pictureSelectionState = .SwipedRight
            }
        }
        if sender.state == UIGestureRecognizerState.Ended {
            
            UIView.animateWithDuration(0.3, animations:
                { () -> Void in
                    profile.frame = self.frame
                }, completion: {
                    (success) -> Void in
                    self.pictureSelectionState = .NoSelection
            })
            
            
        }
        // TODO: load next image

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
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                    let imageData = NSData(contentsOfURL: url!)
                        dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                            self.userPhoto.image = UIImage(data: imageData!)
                            self.userPhoto.layer.cornerRadius = 8
                            self.userPhoto.clipsToBounds = true
                            self.currentMatchIndex = i
                            self.currentMatch = closestUser.objectId
                        })
                })
            }
        }
    }

    @IBAction func nopeButtonPressed(sender: UIButton) {
        self.nopeSelected()
    }
    
    func nopeSelected(){
        if self.currentMatchIndex < self.listOfMatches.count - 1
        {
            self.iterateThroughListOfMatches(self.currentMatchIndex + 1, aroundGeoPoint: self.currentLocation!)
            self.goBackButton.alpha = 1
            
        }else{
            var alert = UIAlertController(title: "Alert", message: "Sorry, there are no more matches!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func okButtonPressed(sender: UIButton) {
        self.okSelected()
    }
    
    func okSelected(){
        if let user = PFUser.currentUser()
        {
            var request = PFObject(className: "requestPool")
            request.addObject(user.objectId!, forKey: "senderID")
            request.addObject(self.currentMatch!, forKey: "receiverID")
            request.addObject(false, forKey: "State")
            request.saveInBackground()
            
        }
    }
    
    @IBAction func goBackButtonPressed(sender: UIButton) {
        self.iterateThroughListOfMatches(self.currentMatchIndex - 1, aroundGeoPoint: self.currentLocation!)
        self.goBackButton.alpha = 0
    }

}

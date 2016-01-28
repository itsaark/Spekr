//
//  ComposeViewController.swift
//  Spekr
//
//  Created by Arjun Kodur on 12/28/15.
//  Copyright © 2015 Arjun Kodur. All rights reserved.
//

import UIKit
import Parse
import CoreLocation

class ComposeViewController: UIViewController, CLLocationManagerDelegate, UITextViewDelegate {
    
    
    //Displaying error/alert message through Alert
    func DisplayAert(title:String, errorMessage:String){
        
        let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

    var photoTakingHelper: PhotoTakingHelper?
    var currentUserLocation: PFGeoPoint?
    let locationManager = CLLocationManager()
    let postDetails = PostDetails()
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        for location in locations {
            
            currentUserLocation = PFGeoPoint(location: location)
        }
        
    }
    
    func attachImage() {
        
        photoTakingHelper = PhotoTakingHelper(viewController: self, callback: { (image: UIImage?) -> Void in
            
            print("received a callback")
            
            self.postDetails.image.value = image
            //TODO: Change Image icon to file name after image has been selected
            self.cameraButton.selected = true
        })
    }

    
    @IBOutlet weak var composeTextView: UITextView!
    
    @IBOutlet weak var placeHolderLabel: UILabel!

    
    
    
    func postButtonTapped() {
        
        print(currentUserLocation)
        
        if currentUserLocation == nil {
            
            //TODO: Redirect to settings pane
            let alert = UIAlertController(title: "Location Access Denied", message: "Please turn your Location Access ON to post", preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) -> Void in
                
                
                let url = NSURL(string: UIApplicationOpenSettingsURLString)
                
                UIApplication.sharedApplication().openURL(url!)
                
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
            
        }else if composeTextView.text == "" {
            
            DisplayAert("Empty Post", errorMessage: "Please enter text")
            
        }else {
            
            self.postDetails.locationCoordinates = currentUserLocation
            self.postDetails.postText = composeTextView.text
            self.postDetails.uploadPost()
            
            let alert = UIAlertController(title: "Posted Successfully", message: "", preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) -> Void in
                
                self.performSegueWithIdentifier("unwindToLocalFeed", sender: self)
                
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        
    }
  
    //Character limiting
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        
        //change the value of the label
        characterLabel.text =  String(140-newLength)
        
        //Placeholder and Post button animations
        if newLength == 0 {
            
             placeHolderLabel.text = "What's new around you?"
             postButton.selected = false
            
        }else {
            
            placeHolderLabel.text = ""
            postButton.selected = true
        }
        
        //return true to allow the change, if you want to limit the number of characters in the text field use something like
        return newLength < 140 // To just allow up to 140 characters
        
    }
    
    let postButton = UIButton(type: UIButtonType.Custom)
    let cameraButton = UIButton(type: UIButtonType.Custom)
    var characterLabel = UILabel()
    
    
    //Custom Toolbar
    lazy var inputToolbar: UIToolbar = {
        var toolbar = UIToolbar()
        toolbar.barStyle = .Default
        //toolbar.translucent = true
        toolbar.barTintColor = UIColor.whiteColor()
        toolbar.sizeToFit()
        toolbar.tintColor = UIColor(red: 176/255.0, green: 170/255.0, blue: 170/255.0, alpha: 1)
        toolbar.clipsToBounds = true
        
        self.postButton.setImage(UIImage(named: "PostButton"), forState: UIControlState.Normal)
        self.postButton.setImage(UIImage(named: "PostButtonActive"), forState: UIControlState.Selected)
        self.postButton.addTarget(self, action: "postButtonTapped", forControlEvents: .TouchUpInside)
        self.postButton.frame = CGRectMake(0, 0, 72, 27)
        
        self.cameraButton.setImage(UIImage(named: "CameraIcon"), forState: UIControlState.Normal)
        self.cameraButton.setImage(UIImage(named: "CameraIconActive"), forState: UIControlState.Selected)
        self.cameraButton.addTarget(self, action: "attachImage", forControlEvents: .TouchUpInside)
        self.cameraButton.frame = CGRectMake(0, 0, 28, 23)

        
        self.characterLabel.text = "140"
        self.characterLabel.textColor = UIColor(red: 176/255.0, green: 170/255.0, blue: 170/255.0, alpha: 1)
        self.characterLabel.frame = CGRectMake(0, 0, 40, 20)

        
        var postBarButton = UIBarButtonItem(customView: self.postButton)
        
        var characterLabelDisplayButton = UIBarButtonItem(customView: self.characterLabel)
        
        var flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        var fixedSpaceButton = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        
        var cameraBarButton  = UIBarButtonItem(customView: self.cameraButton)

        toolbar.setItems([fixedSpaceButton, cameraBarButton, flexibleSpaceButton, characterLabelDisplayButton, fixedSpaceButton, postBarButton], animated: false)
        toolbar.userInteractionEnabled = true
        
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        composeTextView.delegate = self
        
        //Setting custom toolbar as inputAccessory to composeTextView
        composeTextView.inputAccessoryView = inputToolbar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //setting view controller's title
        self.title = ""
        
        //Makes toolbar appear
        self.navigationController?.toolbarHidden = false
        
        //Setting Compose Text View as First Responder when the view appears
        self.composeTextView.becomeFirstResponder()
        
        //Check for location services
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
                
            case .AuthorizedAlways, .AuthorizedWhenInUse:
                print("Access")
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
                locationManager.startUpdatingLocation()
                
            default:
                print("No Access")
                
            }
        } else {
            DisplayAert("Location Access Disabled", errorMessage: "Please turn your Location Access ON to get feed around you")
        }


    }
    
    override func viewDidAppear(animated: Bool) {
        
        //Check for location services
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
                
            case .NotDetermined, .Restricted, .Denied:
                print("No access")
                
                //TODO: Redirect to settings pane
                let alert = UIAlertController(title: "Location Access Denied", message: "Please turn your Location Access ON to get feed around you", preferredStyle: .Alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) -> Void in
                    
                    
                    let url = NSURL(string: UIApplicationOpenSettingsURLString)
                    
                    UIApplication.sharedApplication().openURL(url!)
                    
                }))
                
                self.presentViewController(alert, animated: true, completion: nil)
                
            case .AuthorizedAlways, .AuthorizedWhenInUse:
                
                //Stop updating location once the view is appeared.
                if currentUserLocation != nil {
                    locationManager.stopUpdatingLocation()
                    print("Stopped updating location")
                }
                
            }
        }

    }
   
}



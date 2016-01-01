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

class ComposeViewController: UIViewController, CLLocationManagerDelegate {
    
    
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
            
            self.postDetails.image = image
            
            
        })
    }

    
    @IBOutlet weak var charLimitLabel: UILabel!
    
    @IBOutlet weak var composeTextView: UITextView!
    
    //User tapped attachImage button
    @IBAction func attachImageButton(sender: AnyObject) {
        
        attachImage()
        
    }
    
    
    
    @IBAction func postButtonTapped(sender: AnyObject) {
        
        print(currentUserLocation)
        
        if currentUserLocation?.latitude == nil || currentUserLocation?.longitude == nil {
            
            //TODO: Redirect to settings pane
            let alert = UIAlertController(title: "Location Access Denied", message: "Please turn your Location Access ON to get feed around you", preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) -> Void in
                
                
                let url = NSURL(string: UIApplicationOpenSettingsURLString)
                
                UIApplication.sharedApplication().openURL(url!)
                
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
            
        }else if composeTextView.text == nil {
            
            DisplayAert("Empty Post", errorMessage: "Please enter text")
            
        }else {
            
            self.postDetails.locationCoordinates = currentUserLocation
            self.postDetails.postText = composeTextView.text
            self.postDetails.uploadPost()
        }
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //setting view controller's title
        self.title = "Compose"
        
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
                print("Stopped updating location")
                //Stop updating location once the view is appeared.
                locationManager.stopUpdatingLocation()
                
            }
        }

    }
   

}

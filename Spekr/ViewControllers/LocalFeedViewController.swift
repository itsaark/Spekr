//
//  LocalFeedViewController.swift
//  Spekr
//
//  Created by Arjun Kodur on 12/24/15.
//  Copyright © 2015 Arjun Kodur. All rights reserved.
//

import UIKit
import CoreLocation
import Parse

class LocalFeedViewController: UIViewController, CLLocationManagerDelegate {
    
    //Displaying error/alert message through Alert
    func DisplayAert(title:String, errorMessage:String){
        
        let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    //Obtaining current user location details
    var currentUserLocation: PFGeoPoint? = nil
    let locationManager = CLLocationManager()
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationCoordinates:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locationCoordinates.latitude) \(locationCoordinates.longitude)")
        
        currentUserLocation?.latitude = locationCoordinates.latitude
        currentUserLocation?.longitude = locationCoordinates.longitude
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        //TODO: Reload the view
        if status == .AuthorizedWhenInUse {
         
            print("Status Changed")
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initial request for Location Access
        self.locationManager.requestWhenInUseAuthorization()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {


        //Setting right bar button item
        let composeButtonImage = UIImage(named: "Compose")
        
        let composeButton = UIBarButtonItem(image: composeButtonImage, style: .Plain, target: self, action: "segueFunction")
        
        self.tabBarController?.navigationItem.rightBarButtonItem = composeButton
        
        
        //Setting View controller's title
        self.tabBarController?.navigationItem.title = "Local Feed"
        
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
                
                presentViewController(alert, animated: true, completion: nil)
                
            case .AuthorizedAlways, .AuthorizedWhenInUse:
                print("Stopped updating location")
                //Stop updating location once the view is appeared.
                locationManager.stopUpdatingLocation()
                
            }
        }
        

    }
    
    
    //Segue function to navigate to Compose view controller from right bar button item
    func segueFunction(){
        
        performSegueWithIdentifier("JumpToComposeVC", sender: UIBarButtonItem())
        
    }

    
    //Customizing the back bar button item
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.tabBarController?.navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    
}

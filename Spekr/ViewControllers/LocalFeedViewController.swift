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

class LocalFeedViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate{
    
    var postDetails: [PostDetails] = []
    
    
    @IBOutlet weak var moveSliderLabel: UILabel!
    
    @IBOutlet weak var distanceSliderValue: UISlider!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func sliderMoved(sender: AnyObject) {
        
        //Move slider label will disappear
        moveSliderLabel.hidden = true
        
        if currentUserLocation != nil {
            
        ParseHelper.timelineRequestForCurrentPost("locationCoordinates", geoPoint: currentUserLocation!, radius: Double(distanceSliderValue.value)) { (result:[PFObject]?, error: NSError?) -> Void in
            
            self.postDetails = result as? [PostDetails] ?? []
            print(self.postDetails)
            self.tableView.reloadData()

        }
      }
    }
    
    // Segue to load LocalFeed after successful post from Compose View Controller
    @IBAction func unwindToLocalFeed(segue: UIStoryboardSegue) {}
    
    //Displaying error/alert message through Alert
    func DisplayAert(title:String, errorMessage:String){
        
        let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    //Obtaining current user location details
    var currentUserLocation: PFGeoPoint?
    let locationManager = CLLocationManager()
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        for location in locations {
            
            currentUserLocation = PFGeoPoint(location: location)
        }
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
        
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.delegate = self
        
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
            //TODO: Redirect to settings pane
            let alert = UIAlertController(title: "Location Access Denied", message: "Please turn your Location Access ON to get feed around you", preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) -> Void in
                
                
                let url = NSURL(string: UIApplicationOpenSettingsURLString)
                
                UIApplication.sharedApplication().openURL(url!)
                
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)

        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
        //Check for location services
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
                
            case .NotDetermined, .Restricted, .Denied:
                
                //TODO: Redirect to settings pane
                let alert = UIAlertController(title: "Location Access Denied", message: "Please turn your Location Access ON for Spekr App get feed around you", preferredStyle: .Alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) -> Void in
                    
                    
                    let url = NSURL(string: UIApplicationOpenSettingsURLString)
                    
                    UIApplication.sharedApplication().openURL(url!)
                    
                }))
                
                self.presentViewController(alert, animated: true, completion: nil)
                
            case .AuthorizedAlways, .AuthorizedWhenInUse:
                
                //Stop updating location once the currentUserLocation is not nil.
                
                if currentUserLocation != nil {
                locationManager.stopUpdatingLocation()
                print("Stopped updating location")
                    
                }
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
        
        if (segue.identifier == "JumpToDetailCellVC"){
            
            let destinationVC = segue.destinationViewController as! DetailCellViewController
            
            let selectedRow = tableView.indexPathForSelectedRow?.row
            
            print("wow\(postDetails[selectedRow!])")
            
            destinationVC.currentObject = postDetails[selectedRow!] as PFObject
        }
    }
    
    
    //User taps a cell and a segue is performed to a detail view controller
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
         performSegueWithIdentifier("JumpToDetailCellVC", sender: self)
        
        //Deselects the seltected cell
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

    }
    
    

}

extension LocalFeedViewController: UITableViewDataSource {
    
    
    //Number of rows in section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return postDetails.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //Check if a post has image file and set the TableViewCell accordingly
        if postDetails[indexPath.row].imageFile == nil {
        
            let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
        
            cell.postTextView.text = postDetails[indexPath.row].postText
        
            let user = postDetails[indexPath.row].objectForKey("username") as! PFUser
            
            //Fetching displayName & displayImage of the user
            user.fetchIfNeededInBackgroundWithBlock { (obj: PFObject?, error: NSError?) -> Void in
            
                if obj != nil {
                    
                    let fetchedUser = obj as! PFUser
                    let username = fetchedUser["displayName"] as! String
                    cell.userName.text = username
                
                    //Fetching displayImage
                    let userDisplayImageFile = fetchedUser["displayImage"] as! PFFile
                    userDisplayImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                    
                        if error == nil {
                        
                            //Converting displayImage to UIImage
                            let userDisplayImage = UIImage(data: imageData!)
                            cell.userDisplayImage.image = userDisplayImage
                            cell.userDisplayImage.layer.cornerRadius = 27
                            cell.userDisplayImage.clipsToBounds = true
                        }
                    })
                }
            }
            
            return cell
        }
        else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("PostCellWithImage") as! PostWithImageTableViewCell
            
            cell.postTextView.text = postDetails[indexPath.row].postText
            
            let postImageFile = postDetails[indexPath.row].imageFile
            
            postImageFile?.getDataInBackgroundWithBlock({ (postImageData: NSData?, error: NSError?) -> Void in
                
                if error == nil {
                    
                    let postImage = UIImage(data: postImageData!)
                    
                    cell.postImage.image = postImage
                }
            })
            
            let user = postDetails[indexPath.row].objectForKey("username") as! PFUser
            
            user.fetchIfNeededInBackgroundWithBlock { (obj: PFObject?, error: NSError?) -> Void in
                
                if obj != nil {
                    let fetchedUser = obj as! PFUser
                    let username = fetchedUser["displayName"] as! String
                    
                    cell.userName.text = username // This Works FINE
                    
                    let userDisplayImageFile = fetchedUser["displayImage"] as! PFFile
                    
                    userDisplayImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                        
                        if error == nil {
                            
                            let userDisplayImage = UIImage(data: imageData!)
                            
                            cell.userDisplayImage.image = userDisplayImage
                            
                            cell.userDisplayImage.layer.cornerRadius = 27
                            
                            cell.userDisplayImage.clipsToBounds = true
                        }
                    })
                    
                }
            }          
            
            return cell
        }
    }
    
}


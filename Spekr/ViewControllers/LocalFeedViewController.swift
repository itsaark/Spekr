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
import Foundation
import PermissionScope
import SDWebImage
import ReachabilitySwift


class LocalFeedViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UIApplicationDelegate{
    
    var postDetails: [PostDetails] = []
    
    let alertView = SweetAlert()
    
    //Calender Declaration
    let gregorianCal =  NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    
    //Obtaining current user location details
    let locationManager = CLLocationManager()
    var currentUserLocation: PFGeoPoint?
    
    let permissionPane = PermissionScope()
    
    var reachability: Reachability?
    
    
    dynamic func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable() {
            if reachability.isReachableViaWiFi() {
                //print("Reachable via WiFi")
            } else {
                //print("Reachable via Cellular")
            }
        } else {
            //print("Not reachable")
            dispatch_async(dispatch_get_main_queue()){
                
                self.alertView.showAlert("No Internet!", subTitle: "No working Internet connection is found.", style: AlertStyle.Warning, buttonTitle: "OK")
                
            }
            
            reachability.stopNotifier()
            NSNotificationCenter.defaultCenter().removeObserver(self, name: ReachabilityChangedNotification, object: reachability)
        }
    }
    
    @IBOutlet weak var moveSliderLabel: UILabel!
    
    @IBOutlet weak var distanceSliderValue: UISlider!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func sliderMoved(sender: AnyObject) {
        
        //Move slider label will disappear
        moveSliderLabel.hidden = true
        
        if currentUserLocation != nil {
            
            ParseHelper.timelineRequestForCurrentPost("locationCoordinates", geoPoint: currentUserLocation!, radius: Double(distanceSliderValue.value)) { (result:[PFObject]?, error: NSError?) -> Void in
            
            self.postDetails = result as? [PostDetails] ?? []
            //print(self.postDetails)
            self.tableView.reloadData()

            }
        }else {
            
            // Redirect to location settings pane
            let alert = UIAlertController(title: "Location Access Denied", message: "Please turn your Location Access ON to get feed around you", preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) -> Void in
                
                
                let url = NSURL(string: UIApplicationOpenSettingsURLString)
                
                UIApplication.sharedApplication().openURL(url!)
                
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)

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
    
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        for location in locations {
            
            currentUserLocation = PFGeoPoint(location: location)
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        //TODO: Reload the view
        if status == .AuthorizedWhenInUse {
         
            locationManager.startUpdatingLocation()
        }
    }
    

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        distanceSliderValue.continuous = false
        
        //Initial request for Location Access
        //self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.delegate = self
        
        tableView.estimatedRowHeight = 60.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.delegate = self
        
        
        //Requesting Location access and Notification permission using PermissionScope
        permissionPane.addPermission(LocationWhileInUsePermission(), message: "We use this to fetch local feed around you")
        permissionPane.addPermission(NotificationsPermission(notificationCategories: nil), message: "We use this to update you about people who loved your post")
        
        //Customising permission pane
        permissionPane.headerLabel.text = "Hey, Guys!"
        permissionPane.closeButtonTextColor = UIColor(red: 96, green: 59, blue: 156)
        permissionPane.permissionButtonBorderColor = UIColor(red: 96, green: 59, blue: 156)
        permissionPane.permissionButtonTextColor = UIColor(red: 96, green: 59, blue: 156)
        permissionPane.authorizedButtonColor = UIColor(red: 2, green: 208, blue: 78)
        
        permissionPane.show(
            { finished, results in
                //print("got results \(results)")
                
            },
            cancelled: { results in
                //print("thing was cancelled")
            }
        )
        
        
    }
    
    func checkForLocation() {
        switch PermissionScope().statusLocationInUse() {
        case .Unknown:
            // ask
            PermissionScope().requestLocationInUse()
        case .Unauthorized, .Disabled:
            // bummer
            return
        case .Authorized:
            // thanks!
            return
        }
    }
    
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //Makes toolbar disappear
        self.navigationController?.toolbarHidden = true
        
        //Setting View controller's title
        self.navigationItem.title = "Local Feed"
        
        //Reload Tableview
        self.tableView.reloadData()

        //Setting right bar button item
        let composeButtonImage = UIImage(named: "Compose")
        
        let composeButton = UIBarButtonItem(image: composeButtonImage, style: .Plain, target: self, action: "showComposeViewController")
        
        self.navigationItem.rightBarButtonItem = composeButton
        
        
        //Check for location services
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
                 
            case .AuthorizedAlways, .AuthorizedWhenInUse:
                //print("Access")
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
                locationManager.startUpdatingLocation()
            
            default:
                print("No Access")

            }
        } else {
            //TODO: Redirect to settings pane
            
        }
        
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "reachabilityChanged:",
            name: ReachabilityChangedNotification,
            object: reachability)
        
        do{
            try reachability!.startNotifier()
            
        }catch{
            print("could not start reachability notifier")
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
        //Check for location services
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
                
            case .NotDetermined, .Restricted, .Denied:
                
                //TODO: Redirect to settings pane
                print("Denied")
                
            case .AuthorizedAlways, .AuthorizedWhenInUse:
                
                //Stop updating location once the currentUserLocation is not nil.
                
                if currentUserLocation != nil {
                locationManager.stopUpdatingLocation()
                //print("Stopped updating location")
                    
                }
            }
        }
        

    }
    
    func showComposeViewController(){
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let composeViewController = storyBoard.instantiateViewControllerWithIdentifier("composeViewController") as! ComposeViewController
        self.presentViewController(composeViewController, animated: true, completion: nil)
    }
    
    
    //Segue function to navigate to Compose view controller from right bar button item
    func segueFunction(){
        
        performSegueWithIdentifier("JumpToComposeVC", sender: UIBarButtonItem())
        
    }

    
    //Customizing the back bar button item
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        
        if (segue.identifier == "JumpToDetailCellWithImageVC"){
            
            let destinationViewController = segue.destinationViewController as! DetailCellWithImageViewController
            
            let selectedRow = tableView.indexPathForSelectedRow?.section
            
            //print("wow\(postDetails[selectedRow!])")
            
            destinationViewController.currentObject = postDetails[selectedRow!] as PostDetails
        }
        else if (segue.identifier == "JumpToDetailCellVC"){
            
            let destinationViewController = segue.destinationViewController as! DetailCellViewController
            
            let selectedRow = tableView.indexPathForSelectedRow?.section
            
            destinationViewController.currentObject = postDetails[selectedRow!] as PostDetails
            
        }
    }
    
    
    //User taps a cell and a segue is performed to a detail view controller
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if postDetails[indexPath.section].objectForKey("imageFile") == nil {
            
            performSegueWithIdentifier("JumpToDetailCellVC", sender: self)
            
        }else {
            
            performSegueWithIdentifier("JumpToDetailCellWithImageVC", sender: self)
        }
        
        //Deselects the seltected cell
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

    }
    

}

extension LocalFeedViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        //Setting placeholder image
        if postDetails.count == 0{
            let image = UIImage(named: "LocalFeedPlaceHolder")
            
            let imageView = UIImageView(image: image)
            //imageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)
            imageView.frame = self.tableView.frame
            imageView.contentMode = UIViewContentMode.ScaleAspectFit

            self.tableView.backgroundView = imageView
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            return 0
            
        } else {
            //Hiding the background before the view loads
            self.tableView.backgroundView?.hidden = true
            return postDetails.count

        }
        
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
        
        cell.userDisplayImage.layer.cornerRadius = 22.5
        cell.userDisplayImage.clipsToBounds = true
    }
    
    //Footer color
    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        
         view.tintColor = UIColor(red: 238, green: 238, blue: 242)
    }
    
    //Footer height
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 20
    }
    
    //Number of rows in section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return 1
    }
    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        
//        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
//        
//        
//        if postDetails[indexPath.section].doesUserLikePost(PFUser.currentUser()!) {
//            
//            cell.likeButton.selected = true
//        }else{
//            cell.likeButton.selected = false
//        }
//    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
            //TODO: Use custom cell for this task later.
        
        
            //print("\(indexPath.section): \(postDetails[indexPath.section].likes.value)")
        
            let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
            
            cell.layer.cornerRadius = 30
            cell.layer.masksToBounds = true
            postDetails[indexPath.section].fetchLikes()

            cell.likeButton.selected = postDetails[indexPath.section].doesUserLikePost(PFUser.currentUser()!)
        
            cell.postTextLabel.text = postDetails[indexPath.section].postText
            
            let createdAtDate = postDetails[indexPath.section].createdAt
            
            //Getting date components from NSDate
            let dateComponents = gregorianCal.components([NSCalendarUnit.Era, NSCalendarUnit.Year, NSCalendarUnit.Month,NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second, NSCalendarUnit.Nanosecond], fromDate: createdAtDate!)
            
            let postedDate = gregorianCal.dateWithEra(dateComponents.era, year: dateComponents.year, month: dateComponents.month, day: dateComponents.day, hour: dateComponents.hour, minute: dateComponents.minute, second: dateComponents.second, nanosecond: dateComponents.nanosecond)
            
            //calling relative time property from Date Format
            let postedRelativeTime = postedDate?.relativeTime
            
            cell.timeStamp.text = postedRelativeTime
        
        
            let user = postDetails[indexPath.section].objectForKey("username") as! PFUser
            
            //Fetching displayName & displayImage of the user
            user.fetchIfNeededInBackgroundWithBlock { (obj: PFObject?, error: NSError?) -> Void in
            
                if obj != nil {
                    
                    let fetchedUser = obj as! PFUser
                    let userName = fetchedUser["displayName"] as! String
                
                    //Fetching displayImage
                    if let userDisplayImageFile = fetchedUser["displayImage"] as! PFFile? {
                        
                        let imageUrl = NSURL(string: userDisplayImageFile.url!)
                        cell.userDisplayImage.sd_setImageWithURL(imageUrl)
                        cell.userDisplayImage.layer.cornerRadius = 22.5
                        cell.userDisplayImage.clipsToBounds = true
                    }else{
                        
                        cell.userDisplayImage.setImageWithString(userName)
                        cell.userDisplayImage.layer.cornerRadius = 22.5
                        cell.userDisplayImage.clipsToBounds = true
                    }
                    
                }
            }
            
            return cell
    }
    
    
}


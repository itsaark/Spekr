//
//  WorldFeedViewController.swift
//  Spekr
//
//  Created by Arjun Kodur on 1/26/16.
//  Copyright © 2016 Arjun Kodur. All rights reserved.
//



import UIKit
import CoreLocation
import Parse
import Foundation
import SDWebImage
import ReachabilitySwift

class WorldFeedViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UIApplicationDelegate{
    
    var postDetails: [PostDetails] = []
    
    
    let alertView = SweetAlert()

    
    //Stuff related to refresh control
    var refreshLoadingView : UIView!
    var refreshColorView : UIView!
    var compass_background : UIImageView!
    var compass_spinner : UIImageView!
    
    
    var refreshControl:UIRefreshControl!
    
    var todaysLikesArray = [Int]()
    var isRefreshIconsOverlap = false
    var isRefreshAnimating = false
    var likesMedianValue: Int?
    
    
    //Calender Declaration
    let gregorianCal =  NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    

    
    @IBOutlet weak var tableView: UITableView!
    
    
    //Displaying error/alert message through Alert
    func DisplayAert(title:String, errorMessage:String){
        
        let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
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
    
    //Scroll refresh function
    func refresh(){

        
        // -- DO SOMETHING AWESOME (... or just wait 3 seconds) --
        // This is where you'll make requests to an API, reload data, or process information

        
        ParseHelper.requestForWorldFeed(likesMedianValue!) { (posts: [PFObject]?, error: NSError?) -> Void in
            
            self.postDetails = posts as? [PostDetails] ?? []
            self.tableView.reloadData()
        }
        let delayInSeconds = 3.0
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            // When done requesting/reloading/processing invoke endRefreshing, to close the control
            self.refreshControl!.endRefreshing()
        }
        // -- FINISHED SOMETHING AWESOME, WOO! --
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        // Get the current size of the refresh controller
        var refreshBounds = self.refreshControl!.bounds
        
        // Distance the table has been pulled >= 0
        let pullDistance = max(0.0, -self.refreshControl!.frame.origin.y)
        
        // Half the width of the table
        let midX = self.tableView.frame.size.width / 2.0
        
        // Calculate the width and height of our graphics
        let compassHeight = self.compass_background.bounds.size.height
        let compassHeightHalf = compassHeight / 2.0
        
        let compassWidth = self.compass_background.bounds.size.width
        let compassWidthHalf = compassWidth / 2.0
        
        let spinnerHeight = self.compass_spinner.bounds.size.height
        let spinnerHeightHalf = spinnerHeight / 2.0
        
        let spinnerWidth = self.compass_spinner.bounds.size.width
        let spinnerWidthHalf = spinnerWidth / 2.0
        
        // Calculate the pull ratio, between 0.0-1.0
        let pullRatio = min( max(pullDistance, 0.0), 100.0) / 100.0
        
        // Set the Y coord of the graphics, based on pull distance
        let compassY = pullDistance / 2.0 - compassHeightHalf
        let spinnerY = pullDistance / 2.0 - spinnerHeightHalf
        
        // Calculate the X coord of the graphics, adjust based on pull ratio
        var compassX = (midX + compassWidthHalf) - (compassWidth * pullRatio)
        var spinnerX = (midX - spinnerWidth - spinnerWidthHalf) + (spinnerWidth * pullRatio)
        
        // When the compass and spinner overlap, keep them together
        if (fabsf(Float(compassX - spinnerX)) < 1.0) {
            self.isRefreshIconsOverlap = true
        }
        
        // If the graphics have overlapped or we are refreshing, keep them together
        if (self.isRefreshIconsOverlap || self.refreshControl!.refreshing) {
            compassX = midX - compassWidthHalf
            spinnerX = midX - spinnerWidthHalf
        }
        
        // Set the graphic's frames
        var compassFrame = self.compass_background.frame
        compassFrame.origin.x = compassX
        compassFrame.origin.y = compassY
        
        var spinnerFrame = self.compass_spinner.frame
        spinnerFrame.origin.x = spinnerX
        spinnerFrame.origin.y = spinnerY
        
        self.compass_background.frame = compassFrame
        self.compass_spinner.frame = spinnerFrame
        
        // Set the encompassing view's frames
        refreshBounds.size.height = pullDistance
        
        self.refreshColorView.frame = refreshBounds
        self.refreshLoadingView.frame = refreshBounds
        
        // If we're refreshing and the animation is not playing, then play the animation
        if (self.refreshControl!.refreshing && !self.isRefreshAnimating) {
            self.animateRefreshView()
        }
        

    }
    
    func animateRefreshView() {

        // In Swift, static variables must be members of a struct or class
        struct ColorIndex {
            static var colorIndex = 0
        }
        
        // Flag that we are animating
        self.isRefreshAnimating = true
        
        UIView.animateWithDuration(Double(0.3), delay: Double(0.0), options: UIViewAnimationOptions.CurveLinear, animations: {
                // Rotate the spinner by M_PI_2 = PI/2 = 90 degrees
                self.compass_spinner.transform = CGAffineTransformRotate(self.compass_spinner.transform, CGFloat(M_PI_2))
                
                // Background color
                self.refreshColorView!.backgroundColor = UIColor(red: 238, green: 238, blue: 242)
            
            },
            completion: { finished in
                // If still refreshing, keep spinning, else reset
                if (self.refreshControl!.refreshing) {
                    self.animateRefreshView()
                }else {
                    self.resetAnimation()
                }
            }
        )
    }
    
    func resetAnimation() {

        
        // Reset our flags and }background color
        self.isRefreshAnimating = false
        self.isRefreshIconsOverlap = false
        self.refreshColorView.backgroundColor = UIColor.clearColor()
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        tableView.estimatedRowHeight = 60.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        
        // Programmatically inserting a UIRefreshControl
        self.refreshControl = UIRefreshControl()
        
        
        // Setup the loading view, which will hold the moving graphics
        self.refreshLoadingView = UIView(frame: self.refreshControl!.bounds)
        self.refreshLoadingView.backgroundColor = UIColor.clearColor()
        
        // Setup the color view, which will display the rainbowed background
        self.refreshColorView = UIView(frame: self.refreshControl!.bounds)
        self.refreshColorView.backgroundColor = UIColor.clearColor()
        self.refreshColorView.alpha = 0.30
        
        // Create the graphic image views
        compass_background = UIImageView(image: UIImage(named: "compass_background.png"))
        self.compass_spinner = UIImageView(image: UIImage(named: "compass_spinner.png"))
        
        // Add the graphics to the loading view
        self.refreshLoadingView.addSubview(self.compass_background)
        self.refreshLoadingView.addSubview(self.compass_spinner)
        
        // Clip so the graphics don't stick out
        self.refreshLoadingView.clipsToBounds = true;
        
        // Hide the original spinner icon
        self.refreshControl!.tintColor = UIColor.clearColor()
        
        // Add the loading and colors views to our refresh control
        self.refreshControl!.addSubview(self.refreshColorView)
        self.refreshControl!.addSubview(self.refreshLoadingView)
        
        // Initalize flags
        self.isRefreshIconsOverlap = false
        self.isRefreshAnimating = false
        
        // When activated, invoke our refresh function
        self.refreshControl?.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        
        tableView.addSubview(self.refreshControl)
        

    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        
        //Makes toolbar disappear
        self.navigationController?.toolbarHidden = true
        
        //Setting View controller's title
        self.navigationItem.title = "World Feed"
        
        //Reload Tableview
        self.tableView.reloadData()
        
        //Get median value from cloud
        PFCloud.callFunctionInBackground("LikesMedian", withParameters: nil) { (value: AnyObject?, error: NSError?) -> Void in
            
            if error == nil {
                
                if let medianValue = value as? Int{
                    
                    //print(medianValue)
                    self.likesMedianValue = medianValue
                    
                }else{
                    
                    self.likesMedianValue = 0

                }
                
            }else{
                
                self.likesMedianValue = 0
            }
        }
        
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: ReachabilityChangedNotification, object: reachability)
        
        do{
            try reachability!.startNotifier()
            
        }catch{
            
            print("could not start reachability notifier")
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
        
        //        print(postDetails[indexPath.section].likes.value)
        //        print("current user: \(PFUser.currentUser()!)")
        
    }
    
    
}

extension WorldFeedViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        //Setting placeholder image
        if postDetails.count == 0{
            let image = UIImage(named: "WorldFeedPlaceHolder")
            
            let imageView = UIImageView(image: image)
            //imageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)
            imageView.frame = self.tableView.frame
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
            
            self.tableView.backgroundView = imageView
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            return 0
            
        } else {

            //Hiding the background before the view loads
            UIView.animateWithDuration(0.3, animations: { self.tableView.backgroundView?.alpha = 0.0}, completion: { finished in
                self.tableView.backgroundView?.hidden = true
            })
            return postDetails.count
            
        }
        
        
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
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
        
        cell.userDisplayImage.layer.cornerRadius = 22.5
        cell.userDisplayImage.clipsToBounds = true
    }
    
    
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
                //cell.userName.text = username
                
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
    
    //Currently inactive function
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if (maximumOffset - currentOffset <= -40) {
            
            //Query 10 more posts from Prase
        }
    }
    
    
}
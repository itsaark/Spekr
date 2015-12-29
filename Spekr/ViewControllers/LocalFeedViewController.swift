//
//  LocalFeedViewController.swift
//  Spekr
//
//  Created by Arjun Kodur on 12/24/15.
//  Copyright © 2015 Arjun Kodur. All rights reserved.
//

import UIKit

class LocalFeedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {


        
        let composeButtonImage = UIImage(named: "Compose")
        
        let composeButton = UIBarButtonItem(image: composeButtonImage, style: .Plain, target: self, action: "segueFunction")
        
        
        self.tabBarController?.navigationItem.rightBarButtonItem = composeButton
        
        self.tabBarController?.navigationItem.title = "Local Feed"
        
        
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func segueFunction(){
        
        performSegueWithIdentifier("JumpToComposeVC", sender: UIBarButtonItem())
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.tabBarController?.navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    
}

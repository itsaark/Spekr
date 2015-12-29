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


        //Setting right bar button item
        let composeButtonImage = UIImage(named: "Compose")
        
        let composeButton = UIBarButtonItem(image: composeButtonImage, style: .Plain, target: self, action: "segueFunction")
        
        self.tabBarController?.navigationItem.rightBarButtonItem = composeButton
        
        
        //Setting View controller's title
        self.tabBarController?.navigationItem.title = "Local Feed"
        
        
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
